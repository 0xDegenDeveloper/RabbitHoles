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
            let new_owner = 0.try_into().unwrap();
            _transfer_ownership(new_owner);
            OwnershipTransferred(prev_owner, new_owner);
        }

        /// modifier
        fn has_valid_permit(account: ContractAddress, right: felt252) -> bool {
            if (account == _owner::read()) {
                return true;
            }
            if (has_permit_until(account, right) > get_block_timestamp()) {
                return true;
            }
            false
        }

        fn has_permit_until(account: ContractAddress, right: felt252) -> u64 {
            _permissions::read((account, right))
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
        _MANAGER_RIGHT::write('MANAGER'); // to do, needs to be max felt252
    /// loop add any known manager rights here as well (minter/burner for rbits,)
    }

    /// View Functions ///

    #[view]
    fn owner() -> ContractAddress {
        ManagerImpl::owner()
    }

    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        ManagerImpl::has_valid_permit(account, right)
    }

    #[view]
    fn has_permit_until(account: ContractAddress, right: felt252) -> u64 {
        ManagerImpl::has_permit_until(account, right)
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
mod ownable_tests {
    use super::Manager;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::get_caller_address;

    use debug::PrintTrait;

    #[test]
    #[available_gas(2000000)]
    fn deployment() {
        let owner = _deploy();
        assert(Manager::owner() == owner, 'Manager: Owner not set');
        assert(owner == contract_address_const::<1>(), 'Manager: Owner not set');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_ownership_owner_caller() {
        let owner = _deploy();
        let new_owner = contract_address_const::<2>();
        _transfer_ownership_from_to(owner, new_owner);
        assert(Manager::owner() == new_owner, 'Manager: Owner not set');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner', ))]
    fn transfer_ownership_non_owner_caller() {
        let owner = _deploy();
        let not_owner = contract_address_const::<2>();
        set_caller_address(not_owner);
        Manager::transfer_ownership(not_owner);
    }

    #[test]
    #[available_gas(2000000)]
    fn renounce_ownership() {
        let owner = _deploy();
        let zero_addr = contract_address_const::<0>();
        Manager::renounce_ownership();
        assert(Manager::owner() == zero_addr, 'Manager: Owner not zeroed');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Incorrect renouncement', ))]
    fn renounce_ownership_incorrectly() {
        let owner = _deploy();
        let zero_addr = contract_address_const::<0>();
        _transfer_ownership_from_to(owner, zero_addr);
        assert(Manager::owner() == owner, 'Manager: Owner wrongly updated');
    }

    /// Helpers ///
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

#[cfg(test)]
mod manager_tests {
    /// test owner always has valid Permit
    /// test non owners dont (has_valid_permit -> false)
    /// test setting permit (has_valid_permit -> true) (timestamp matches, etc)
    /// test with time > expiry (has_valid_permit -> false)
    /// test removing permit (has_valid_permit -> false)
    /// test setting manager rights (manager can grant permits) (permit addr2 mint_manager right, they should be able to permit addr3 mint permit)
    /// test setting addr4 as a manager, they should be able to permint addr2 above
}
