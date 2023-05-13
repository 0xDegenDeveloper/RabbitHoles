// mimic managerial contract
trait IManager {
    /// Ownable ///
    fn owner() -> starknet::ContractAddress;
    fn transfer_ownership(new_owner: starknet::ContractAddress);
    fn renounce_ownership();
    /// Permit Control ///
    fn has_valid_permit(account: starknet::ContractAddress, right: felt252) -> bool;
    fn has_permit_until(account: starknet::ContractAddress, right: felt252) -> u64;
    fn set_permit(account: starknet::ContractAddress, right: felt252, timestamp: u64);
    fn bind_manager_right(right: felt252, manager_right: felt252);
}

#[contract]
mod Manager {
    use super::IManager;
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::contract_address_const;

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;

    /// Storage ///
    struct Storage {
        // owner of the contract
        _owner: ContractAddress,
        // address -> permission hash/sig (e.g. keccak('MINT')) -> timestamp
        _permissions: LegacyMap<(ContractAddress, felt252), u64>,
        // permission hash/sig (e.g. keccak('mint')) -> manager hash/sig right (e.g. keccak('MINT MANAGER'))
        _manager_rights: LegacyMap<felt252, felt252>,
        // universal rights (change name here)
        _ZERO_RIGHT: felt252,
        _MANAGER_RIGHT: felt252,
    }

    /// Events ///
    #[event]
    fn OwnershipTransferred(previous_owner: ContractAddress, new_owner: ContractAddress) {}

    #[event]
    fn PermitIssued(
        updator: ContractAddress, updatee: ContractAddress, right: felt252, timestamp: u64
    ) {}

    #[event]
    fn ManagerRightBinded(
        manager: ContractAddress, managed_right: felt252, manager_right: felt252
    ) {}

    /// Implementation ///
    impl ManagerImpl of IManager {
        fn owner() -> ContractAddress {
            _owner::read()
        }

        fn transfer_ownership(new_owner: ContractAddress) {
            let prev_owner = _owner::read();
            _transfer_ownership(new_owner);
            OwnershipTransferred(prev_owner, new_owner);
        }

        fn renounce_ownership() {
            let prev_owner = _owner::read();
            let new_owner = contract_address_const::<0>(); //0.try_into().unwrap();
            _transfer_ownership(new_owner);
            OwnershipTransferred(prev_owner, new_owner);
        }

        fn has_permit_until(account: ContractAddress, right: felt252) -> u64 {
            _permissions::read((account, right))
        }

        fn has_valid_permit(account: ContractAddress, right: felt252) -> bool {
            if (account == _owner::read()) {
                return true;
            }
            if (has_permit_until(account, right) > get_block_timestamp()) {
                return true;
            }
            false
        }

        fn set_permit(account: ContractAddress, right: felt252, timestamp: u64) {
            _permissions::write((account, right), timestamp);
            PermitIssued(get_caller_address(), account, right, timestamp);
        }

        fn bind_manager_right(right: felt252, manager_right: felt252) {
            _manager_rights::write(right, manager_right);
            ManagerRightBinded(get_caller_address(), right, manager_right);
        }
    }

    /// Constructor ///
    #[constructor]
    fn constructor(owner_: ContractAddress) {
        _owner::write(owner_);
        _ZERO_RIGHT::write(0x0);
        _MANAGER_RIGHT::write('MANAGER');
    }

    /// View Functions ///
    #[view]
    fn owner() -> ContractAddress {
        ManagerImpl::owner()
    }

    #[view]
    fn has_permit_until(account: ContractAddress, right: felt252) -> u64 {
        ManagerImpl::has_permit_until(account, right)
    }

    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        ManagerImpl::has_valid_permit(account, right)
    }

    #[view]
    fn manager_rights(right: felt252) -> felt252 {
        _manager_rights::read(right)
    }

    #[view] 
    fn MANAGER_RIGHT() -> felt252 {
        _MANAGER_RIGHT::read()
    }

    #[view]
    fn ZERO_RIGHT() -> felt252 {
        _ZERO_RIGHT::read()
    }

    /// External Functions ///

    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        _only_owner();
        assert(new_owner != contract_address_const::<0>(), 'Manager: Incorrect renouncement');
        ManagerImpl::transfer_ownership(new_owner);
    }

    #[external]
    fn renounce_ownership() {
        _only_owner();
        ManagerImpl::renounce_ownership();
    }

    #[external]
    fn set_permit(account: ContractAddress, right: felt252, timestamp: u64) {
        assert(right != _ZERO_RIGHT::read(), 'Manager: Setting Zero Right');
        assert(
            has_valid_permit(get_caller_address(), _manager_rights::read(right)),
            'Manager: Invalid Permit'
        );

        ManagerImpl::set_permit(account, right, timestamp);
    }

    #[external]
    fn bind_manager_right(right: felt252, manager_right: felt252) {
        assert(
            has_valid_permit(get_caller_address(), _MANAGER_RIGHT::read()),
            'Manager: Invalid Permit'
        );

        ManagerImpl::bind_manager_right(right, manager_right);
    }

    /// Internal Functions ///
    fn _only_owner() {
        assert(get_caller_address() == _owner::read(), 'Manager: Caller not owner');
    }

    fn _transfer_ownership(new_owner: ContractAddress) {
        _owner::write(new_owner);
    }
}

#[cfg(test)]
mod ImplTests {
    use super::Manager;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_block_timestamp;
    use starknet::get_caller_address;
    use debug::PrintTrait;

    #[test]
    #[available_gas(2000000)]
    fn owner() {
        assert(Manager::owner() == contract_address_const::<0>(), 'Owner init wrong');
        let owner = _deploy();
        assert(Manager::owner() == owner, 'Owner not set');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_ownership() {
        let owner = _deploy();
        let new_owner = contract_address_const::<2>();
        Manager::ManagerImpl::transfer_ownership(new_owner);
        assert(Manager::ManagerImpl::owner() == new_owner, 'Owner not swapped');
    /// @dev: Test event fired
    }

    #[test]
    #[available_gas(2000000)]
    fn renounce_ownership() {
        let owner = _deploy();
        let zero_addr = contract_address_const::<0>();
        Manager::ManagerImpl::renounce_ownership();
        assert(Manager::ManagerImpl::owner() == zero_addr, 'Owner not zeroed');
    /// @dev: Test event fired
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit_and_has_permit_until() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        let right = 'test';
        let timestamp = 111;
        assert(Manager::ManagerImpl::has_permit_until(account, right) == 0, 'Permit init wrong');
        Manager::ManagerImpl::set_permit(account, right, timestamp);
        assert(
            Manager::ManagerImpl::has_permit_until(account, right) == timestamp, 'Permit set wrong'
        );
        Manager::ManagerImpl::set_permit(account, right, 0);
        assert(
            Manager::ManagerImpl::has_permit_until(account, right) == 0, 'Permit set wrong'
        );
    /// @dev: Test event fired
    }

    #[test]
    #[available_gas(2000000)]
    fn has_valid_permit_owner() {
        let owner = _deploy();
        let right = 'anything';
        assert(Manager::ManagerImpl::has_valid_permit(owner, right), 'Owner not permitted');
    }

    #[test]
    #[available_gas(2000000)]
    fn has_valid_permit() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        let right = 'anything';
        assert(!Manager::ManagerImpl::has_valid_permit(account, right), 'Permit faked');
        Manager::ManagerImpl::set_permit(account, right, 111);
        assert(Manager::ManagerImpl::has_valid_permit(account, right), 'Permit not set');
        set_block_timestamp(110);
        assert(Manager::ManagerImpl::has_valid_permit(account, right), 'Permit expired early');
        set_block_timestamp(111);
        assert(!Manager::ManagerImpl::has_valid_permit(account, right), 'Permit deadline broken');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right() {
        let owner = _deploy();
        let right = 'mint';
        let manager_right = 'mint_manager';
        assert(Manager::manager_rights(right) == 0x0, 'Manager right init wrong');
        Manager::ManagerImpl::bind_manager_right(right, manager_right);
        assert(Manager::manager_rights(right) == manager_right, 'Manager right not set');
    /// @dev: Test event fired
    }

    /// Helpers ///
    fn _deploy() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<1>();
        set_caller_address(owner);
        Manager::constructor(owner);
        owner
    }
}

#[cfg(test)]
mod InternalTests {
    use super::Manager;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_block_timestamp;
    use starknet::get_caller_address;
    use debug::PrintTrait;

    /// IMPL TESTS ///
    #[test]
    #[available_gas(2000000)]
    fn _only_owner_yes() {
        let owner = _deploy();
        Manager::_only_owner();
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner',))]
    fn _only_owner_no() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        set_caller_address(account);
        Manager::_only_owner();
    }

    #[test]
    #[available_gas(2000000)]
    fn _transfer_ownership() {
        let owner = _deploy();
        assert(Manager::owner() == owner, 'Owner init wrong');
        let new_owner = contract_address_const::<2>();
        Manager::_transfer_ownership(new_owner);
        assert(Manager::owner() == new_owner, 'Owner not swapped');
    }

    /// Helpers ///
    fn _deploy() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<1>();
        set_caller_address(owner);
        Manager::constructor(owner);
        owner
    }
}

#[cfg(test)]
mod EntryPointTests {
    use super::Manager;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_block_timestamp;
    use starknet::get_caller_address;
    use debug::PrintTrait;

    #[test]
    #[available_gas(2000000)]
    fn owner() {
        let owner = _deploy();
        assert(Manager::owner() == owner, 'Owner not set');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_ownership() {
        let owner = _deploy();
        let new_owner = contract_address_const::<2>();
        _transfer_ownership_from_to(owner, new_owner);
        assert(Manager::owner() == new_owner, 'Owner not swapped');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner', ))]
    fn transfer_ownership_non_owner() {
        let owner = _deploy();
        let not_owner = contract_address_const::<2>();
        _transfer_ownership_from_to(not_owner, not_owner);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Incorrect renouncement', ))]
    fn transfer_ownership_to_zero() {
        let owner = _deploy();
        let zero_addr = contract_address_const::<0>();
        _transfer_ownership_from_to(owner, zero_addr);
    }

    #[test]
    #[available_gas(2000000)]
    fn renounce_ownership() {
        let owner = _deploy();
        let zero_addr = contract_address_const::<0>();
        Manager::renounce_ownership();
        assert(Manager::owner() == zero_addr, 'Owner not zeroed');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner', ))]
    fn renounce_ownership_non_owner() {
        let owner = _deploy();
        set_caller_address(contract_address_const::<2>());
        Manager::renounce_ownership();
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        _set_permit_from_for(owner, account, 'right', 1111);
        assert(
            Manager::has_permit_until(account, 'right') == 1111, 'Incorrect timestamp'
        );
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Setting Zero Right', ))]
    fn set_permit_with_zero() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        let right = 0x0;
        let timestamp = 1111;
        _set_permit_from_for(owner, account, right, timestamp);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', ))]
    fn set_permit_as_non_manager() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        let right = 'MINT';
        let timestamp = 1111;
        _set_permit_from_for(account, account, right, timestamp);
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit_as_manager() {
        let owner = _deploy();
        let new_manager = contract_address_const::<2>();
        let anon = contract_address_const::<3>();

        let manager_right = 'MINT_MANAGER';
        let right = 'MINT';
        let timestamp = 1111;

        /// Set manager permit & bind right (MINT -> MINT_MANAGER)
        _set_permit_from_for(owner, new_manager, manager_right, timestamp);
        Manager::bind_manager_right(right, manager_right);
        assert(!Manager::has_valid_permit(anon, right), 'Should not have permit');
        assert(Manager::has_permit_until(anon, right) == 0, 'Incorrect timestamp');
        assert(
            Manager::has_valid_permit(new_manager, manager_right), 'Manager: Should have permit'
        );
        assert(
            Manager::has_permit_until(new_manager, manager_right) == timestamp,
            'Manager: Incorrect timestamp'
        );
        _set_permit_from_for(new_manager, anon, right, timestamp);
        assert(Manager::has_valid_permit(anon, right), 'Manager: Should not have permit');
        assert(Manager::has_permit_until(anon, right) == timestamp, 'Manager: Incorrect timestamp');
    }

    #[test]
    #[available_gas(2000000)]
    fn has_permit_until_AND_has_valid_permit() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        let right = 'MINT';
        let timestamp = 1111;
        assert(Manager::has_permit_until(account, right) == 0, 'Permit init wrong');
        assert(!Manager::has_valid_permit(account, right), 'Permit init wrong');
        _set_permit_from_for(owner, account, right, timestamp);
        assert(
            Manager::has_permit_until(account, right) == timestamp, 'Incorrect timestamp'
        );
        assert(
            Manager::has_valid_permit(account, right), 'Permit not working'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right() {
        let owner = _deploy();
        let right = 'MINT';
        let manager_right = 'MINT_MANAGER';
         assert(
            Manager::manager_rights(right) == 0x0, 'Manager right init wrong'
        );
        Manager::bind_manager_right(right, manager_right);
        assert(
            Manager::manager_rights(right) == manager_right, 'Manager right set wrong'
        );
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', ))]
    fn bind_manager_right_no_permit() {
        let owner = _deploy();
        let anon = contract_address_const::<2>();
        let right = 'MINT';
        let manager_right = 'MINT_MANAGER';
        set_caller_address(anon);
        Manager::bind_manager_right(right, manager_right);
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right_with_permit() {
        let owner = _deploy();
        let anon = contract_address_const::<2>();
        let right = 'MINT';
        let manager_right = 'MINT_MANAGER';
        _set_permit_from_for(owner, anon, Manager::MANAGER_RIGHT(), 1111);
        set_caller_address(anon);
        Manager::bind_manager_right(right, manager_right);
        assert(
            Manager::manager_rights(right) == manager_right, 'Manager right set wrong'
        );
    }

    /// Helpers ///
    fn _set_permit_from_for(
        from: ContractAddress, for: ContractAddress, right: felt252, timestamp: u64
    ) {
        set_caller_address(from);
        Manager::set_permit(for, right, timestamp);
    }

    fn _deploy() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<1>();
        set_caller_address(owner);
        Manager::constructor(owner);
        owner
    }

    fn _transfer_ownership_from_to(from: ContractAddress, to: ContractAddress) {
        set_caller_address(from);
        Manager::transfer_ownership(to);
    }
}

