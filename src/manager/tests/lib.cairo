#[abi]
trait IManager {
    fn MANAGER() -> felt252;
    fn owner() -> starknet::ContractAddress;
    fn transfer_ownership(new_owner: starknet::ContractAddress);
    fn renounce_ownership();
    fn has_valid_permit(account: starknet::ContractAddress, right: felt252) -> bool;
    fn has_permit_until(account: starknet::ContractAddress, right: felt252) -> u64;
    fn set_permit(account: starknet::ContractAddress, right: felt252, timestamp: u64);
    fn bind_manager_right(right: felt252, manager_right: felt252);
    fn manager_rights(right: felt252) -> felt252;
}

#[cfg(test)]
mod EntryPoint {
    use manager::manager::Manager;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;

    use starknet::syscalls::deploy_syscall;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_contract_address;
    use starknet::testing::set_block_timestamp;
    use starknet::get_caller_address;

    use debug::PrintTrait;
    use array::ArrayTrait;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use result::ResultTrait;

    #[test]
    #[available_gas(2000000)]
    fn owner() {
        let Manager = deploy_manager();
        assert(Manager.owner() == contract_address_const::<123>(), 'Owner init wrong');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_ownership() {
        let Manager = deploy_manager();
        let new_owner = contract_address_const::<1234>();
        _transfer_ownership_from_to(Manager, Manager.owner(), new_owner);
        assert(Manager.owner() == new_owner, 'Owner not swapped');
    /// @dev: test event
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner', 'ENTRYPOINT_FAILED'))]
    fn transfer_ownership_non_owner() {
        let Manager = deploy_manager();
        let not_owner = contract_address_const::<666>();
        _transfer_ownership_from_to(Manager, not_owner, not_owner);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Incorrect renouncement', 'ENTRYPOINT_FAILED'))]
    fn transfer_ownership_to_zero() {
        let Manager = deploy_manager();
        let zero_addr = contract_address_const::<0>();
        _transfer_ownership_from_to(Manager, Manager.owner(), zero_addr);
    }

    #[test]
    #[available_gas(2000000)]
    fn renounce_ownership() {
        let Manager = deploy_manager();
        let zero_addr = contract_address_const::<0>();
        set_contract_address(Manager.owner());
        Manager.renounce_ownership();
        assert(Manager.owner() == zero_addr, 'Owner not zeroed');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Caller not owner', 'ENTRYPOINT_FAILED'))]
    fn renounce_ownership_non_owner() {
        let Manager = deploy_manager();
        set_contract_address(contract_address_const::<666>());
        Manager.renounce_ownership();
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit() {
        let Manager = deploy_manager();
        let account = contract_address_const::<555>();

        /// Check account has no permit
        assert(Manager.has_permit_until(account, 'right') == 0, 'Incorrect timestamp');
        assert(!Manager.has_valid_permit(account, 'right'), 'False permit');

        /// Set permit
        _set_permit_from_for(Manager, Manager.owner(), account, 'right', 123);

        /// Check account has permit
        assert(Manager.has_permit_until(account, 'right') == 123, 'Incorrect timestamp');
        assert(Manager.has_valid_permit(account, 'right'), 'Broken permit');

        /// Check permit expires
        set_block_timestamp(124);
        assert(!Manager.has_valid_permit(account, 'right'), 'Permit should expire');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Setting Zero Right', 'ENTRYPOINT_FAILED'))]
    fn set_permit_with_zero() {
        let Manager = deploy_manager();
        let account = contract_address_const::<666>();
        _set_permit_from_for(Manager, Manager.owner(), account, 0x0, 123);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', 'ENTRYPOINT_FAILED'))]
    fn set_permit_as_non_manager() {
        let Manager = deploy_manager();
        let account = contract_address_const::<666>();
        _set_permit_from_for(Manager, account, account, 'right', 123);
    }

    #[test]
    #[available_gas(2000000)]
    fn set_permit_as_manager() {
        let Manager = deploy_manager();
        let manager = contract_address_const::<'manager'>();
        let anon = contract_address_const::<'anon'>();

        /// Check anon has no permit
        assert(!Manager.has_valid_permit(anon, 'MINT'), 'Should not have permit');
        assert(Manager.has_permit_until(anon, 'MINT') == 0, 'Incorrect timestamp');

        /// Assign manager & bind right (MINT -> MINT_MANAGER)
        _set_permit_from_for(Manager, Manager.owner(), manager, 'MINT MANAGER', 123);
        Manager.bind_manager_right('MINT', 'MINT MANAGER');

        /// Set permit as manager
        _set_permit_from_for(Manager, manager, anon, 'MINT', 123);

        /// Check anon has permit
        assert(Manager.has_valid_permit(anon, 'MINT'), 'Should not have permit');
        assert(Manager.has_permit_until(anon, 'MINT') == 123, 'Incorrect timestamp');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right() {
        let Manager = deploy_manager();
        assert(Manager.manager_rights('MINT') == 0x0, 'Manager right init wrong');
        set_contract_address(Manager.owner());
        Manager.bind_manager_right('MINT', 'MINT MANAGER');
        assert(Manager.manager_rights('MINT') == 'MINT MANAGER', 'Manager right set wrong');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Manager: Invalid Permit', 'ENTRYPOINT_FAILED'))]
    fn bind_manager_right_no_permit() {
        let Manager = deploy_manager();
        let anon = contract_address_const::<'anon'>();
        set_contract_address(anon);
        Manager.bind_manager_right('MINT', 'MINT_MANAGER');
    }

    #[test]
    #[available_gas(2000000)]
    fn bind_manager_right_with_permit() {
        let owner = _deploy();
        let Manager = deploy_manager();
        let mananger = contract_address_const::<'manager'>();
        _set_permit_from_for(Manager, Manager.owner(), mananger, Manager.MANAGER(), 1111);
        set_contract_address(mananger);
        Manager.bind_manager_right('MINT', 'MINT MANAGER');
        assert(Manager.manager_rights('MINT') == 'MINT MANAGER', 'Manager right set wrong');
    }

    /// Helpers ///
    fn deploy_manager() -> IManagerDispatcher {
        /// setup
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let mut calldata = ArrayTrait::new();
        calldata.append(owner.into());

        let (manager_address, _) = deploy_syscall(
            Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();
        IManagerDispatcher { contract_address: manager_address }
    }


    fn _set_permit_from_for(
        Manager: IManagerDispatcher,
        from: ContractAddress,
        for: ContractAddress,
        right: felt252,
        timestamp: u64
    ) {
        set_contract_address(from);
        Manager.set_permit(for, right, timestamp);
    }

    fn _deploy() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<1>();
        set_caller_address(owner);
        Manager::constructor(owner);
        owner
    }

    fn _transfer_ownership_from_to(
        Manager: IManagerDispatcher, from: ContractAddress, to: ContractAddress
    ) {
        set_contract_address(from);
        Manager.transfer_ownership(to);
    }
}

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

