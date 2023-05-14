#[cfg(test)]
mod InternalTests {
    use manager::manager::Manager;
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
    #[should_panic(expected: ('Manager: Caller not owner', ))]
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
