#[contract]
mod Manager {
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::contract_address_const;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::get_contract_address;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;

    /// Storage ///
    struct Storage {
        /// @dev owner of contract, set up multisig ?
        _owner: ContractAddress,
        /// @dev manager permit
        _MANAGER: felt252,
        /// @dev address -> permission -> timestamp
        _permissions: LegacyMap<(ContractAddress, felt252), u64>,
        /// @dev right -> manager_right (i.e 'MINT' -> 'MINT MANAGER')
        _manager_rights: LegacyMap<felt252, felt252>,
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
        _MANAGER::write('MANAGER');
        _owner::write(owner_);
    }

    /// Internal ///
    fn _only_owner() {
        assert(get_caller_address() == _owner::read(), 'Manager: Caller not owner');
    }

    fn _transfer_ownership(new_owner: ContractAddress) {
        _owner::write(new_owner);
    }

    /// Read ///
    #[view]
    fn MANAGER() -> felt252 {
        _MANAGER::read()
    }

    #[view]
    fn owner() -> ContractAddress {
        _owner::read()
    }

    #[view]
    fn has_permit_until(account: ContractAddress, right: felt252) -> u64 {
        _permissions::read((account, right))
    }

    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        if (account == _owner::read()) {
            return true;
        }
        if (has_permit_until(account, right) > get_block_timestamp()) {
            return true;
        }
        false
    }

    #[view]
    fn manager_rights(right: felt252) -> felt252 {
        _manager_rights::read(right)
    }

    /// Write ///
    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        _only_owner();
        assert(new_owner != contract_address_const::<0>(), 'Manager: Incorrect renouncement');
        let prev_owner = _owner::read();
        _transfer_ownership(new_owner);
        OwnershipTransferred(prev_owner, new_owner);
    }

    #[external]
    fn renounce_ownership() {
        _only_owner();
        let prev_owner = _owner::read();
        let new_owner = contract_address_const::<0>(); //0.try_into().unwrap();
        _transfer_ownership(new_owner);
        OwnershipTransferred(prev_owner, new_owner);
    }

    #[external]
    fn set_permit(account_: ContractAddress, right_: felt252, timestamp_: u64) {
        assert(right_ != 0x0, 'Manager: Setting Zero Right');
        assert(
            has_valid_permit(get_caller_address(), _manager_rights::read(right_)),
            'Manager: Invalid Permit'
        );
        _permissions::write((account_, right_), timestamp_);
        PermitIssued(get_caller_address(), account_, right_, timestamp_);
    }

    #[external]
    fn bind_manager_right(right_: felt252, manager_right_: felt252) {
        assert(has_valid_permit(get_caller_address(), _MANAGER::read()), 'Manager: Invalid Permit');
        _manager_rights::write(right_, manager_right_);
        ManagerRightBinded(get_caller_address(), right_, manager_right_);
    }
}
