#[cfg(test)]
mod EntryPointTests {
    use manager::manager::Manager;
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
        assert(Manager::has_permit_until(account, 'right') == 1111, 'Incorrect timestamp');
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
        assert(Manager::has_permit_until(account, right) == timestamp, 'Incorrect timestamp');
        assert(Manager::has_valid_permit(account, right), 'Permit not working');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right() {
        let owner = _deploy();
        let right = 'MINT';
        let manager_right = 'MINT_MANAGER';
        assert(Manager::manager_rights(right) == 0x0, 'Manager right init wrong');
        Manager::bind_manager_right(right, manager_right);
        assert(Manager::manager_rights(right) == manager_right, 'Manager right set wrong');
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
        assert(Manager::manager_rights(right) == manager_right, 'Manager right set wrong');
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
