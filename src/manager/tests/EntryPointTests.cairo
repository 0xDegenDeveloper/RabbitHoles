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
        assert(Manager::owner() == contract_address_const::<0>(), 'Owner init wrong');
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
    /// @dev: test event
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

        /// Check account has no permit
        assert(Manager::has_permit_until(account, 'right') == 0, 'Incorrect timestamp');
        assert(!Manager::has_valid_permit(account, 'right'), 'False permit');

        /// Set permit
        _set_permit_from_for(owner, account, 'right', 123);

        /// Check account has permit
        assert(Manager::has_permit_until(account, 'right') == 123, 'Incorrect timestamp');
        assert(Manager::has_valid_permit(account, 'right'), 'Broken permit');

        /// Check permit expires
        set_block_timestamp(124);
        assert(!Manager::has_valid_permit(account, 'right'), 'Permit should expire');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Setting Zero Right', ))]
    fn set_permit_with_zero() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        _set_permit_from_for(owner, account, 0x0, 123);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', ))]
    fn set_permit_as_non_manager() {
        let owner = _deploy();
        let account = contract_address_const::<2>();
        _set_permit_from_for(account, account, 'MINT', 123);
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit_as_manager() {
        let owner = _deploy();
        let manager = contract_address_const::<2>();
        let anon = contract_address_const::<3>();

        /// Check anon has no permit
        assert(!Manager::has_valid_permit(anon, 'MINT'), 'Should not have permit');
        assert(Manager::has_permit_until(anon, 'MINT') == 0, 'Incorrect timestamp');

        /// Assign manager & bind right (MINT -> MINT_MANAGER)
        _set_permit_from_for(owner, manager, 'MINT MANAGER', 123);
        Manager::bind_manager_right('MINT', 'MINT MANAGER');

        /// Set permit as manager
        _set_permit_from_for(manager, anon, 'MINT', 123);

        /// Check anon has permit
        assert(Manager::has_valid_permit(anon, 'MINT'), 'Should not have permit');
        assert(Manager::has_permit_until(anon, 'MINT') == 123, 'Incorrect timestamp');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right() {
        let owner = _deploy();
        assert(Manager::manager_rights('MINT') == 0x0, 'Manager right init wrong');
        Manager::bind_manager_right('MINT', 'MINT MANAGER');
        assert(Manager::manager_rights('MINT') == 'MINT MANAGER', 'Manager right set wrong');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', ))]
    fn bind_manager_right_no_permit() {
        let owner = _deploy();
        let anon = contract_address_const::<2>();
        set_caller_address(anon);
        Manager::bind_manager_right('MINT', 'MINT_MANAGER');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right_with_permit() {
        let owner = _deploy();
        let mananger = contract_address_const::<2>();
        _set_permit_from_for(owner, mananger, Manager::MANAGER_RIGHT(), 1111);
        set_caller_address(mananger);
        Manager::bind_manager_right('MINT', 'MINT MANAGER');
        assert(Manager::manager_rights('MINT') == 'MINT MANAGER', 'Manager right set wrong');
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
