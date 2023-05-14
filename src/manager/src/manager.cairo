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

    /// Constructor ///
    #[constructor]
    fn constructor(owner_: ContractAddress) {
        _owner::write(owner_);
        _ZERO_RIGHT::write(0x0);
        _MANAGER_RIGHT::write('MANAGER');
    }

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
