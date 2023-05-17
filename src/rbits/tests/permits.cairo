// /// @dev: Need to figure out contract addresses with testing

#[cfg(test)]
mod EntryPoint {
    use manager::manager::Manager;
    use manager::manager::IManagerDispatcher;
    use manager::manager::IManagerDispatcherTrait;
    use rbits::rbits::Rbits;
    use rbits::rbits::IERC20Dispatcher;
    use rbits::rbits::IERC20DispatcherTrait;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_contract_address;
    use starknet::syscalls::deploy_syscall;
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::testing::set_caller_address;
    use starknet::get_caller_address;

    use debug::PrintTrait;
    use array::ArrayTrait;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use result::ResultTrait;

    fn deploy_suite() -> (IManagerDispatcher, IERC20Dispatcher) {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let mut calldata = ArrayTrait::new();
        calldata.append(owner.into());

        let (manager_address, _) = deploy_syscall(
            Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let mut calldata = ArrayTrait::new();
        // let init, owner, mananger
        let init_supply_low = 123_u128;
        let init_supply_high = 0_u128;
        calldata.append(init_supply_low.into());
        calldata.append(init_supply_high.into());
        calldata.append(owner.into());
        calldata.append(manager_address.into());

        let (rbits_address, _) = deploy_syscall(
            Rbits::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        (
            IManagerDispatcher {
                contract_address: manager_address
                }, IERC20Dispatcher {
                contract_address: rbits_address
            }
        )
    }

    #[test]
    #[available_gas(2000000)]
    fn mint_owner() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();

        Rbits.mint(anon, 1_u256);
        assert(Rbits.balance_of(anon) == 1_u256, 'Mints wrong amount');
    }

    #[test]
    #[available_gas(2000000)]
    fn burn_owner() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();
        Rbits.burn(Manager.owner(), 1_u256);
        assert(Rbits.balance_of(Manager.owner()) == 122_u256, 'Burns wrong amount');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('RBITS: Caller non minter', 'ENTRYPOINT_FAILED'))]
    fn mint_no_permit() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();
        set_contract_address(anon);
        Rbits.mint(anon, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('RBITS: Caller non burner', 'ENTRYPOINT_FAILED'))]
    fn burn_no_permit() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();
        set_contract_address(anon);
        Rbits.burn(Manager.owner(), 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn mint_with_permit() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();
        Manager.set_permit(anon, Rbits.RBITS_MINT(), 999);
        set_contract_address(anon);
        Rbits.mint(anon, 1_u256);
        assert(Rbits.balance_of(anon) == 1_u256, 'Mints wrong amount');
    }

    #[test]
    #[available_gas(2000000)]
    fn burn_with_permit() {
        let (Manager, Rbits) = deploy_suite();
        let anon = contract_address_const::<'anon'>();
        Manager.set_permit(anon, Rbits.RBITS_BURN(), 999);
        set_contract_address(anon);
        Rbits.burn(Manager.owner(), 122_u256);
        assert(Rbits.balance_of(Manager.owner()) == 1_u256, 'Mints wrong amount');
    }

    #[test]
    #[available_gas(2000000)]
    fn mint_with_delegated_permit() {
        let (Manager, Rbits) = deploy_suite();
        let manager = contract_address_const::<'manager'>();
        let anon = contract_address_const::<'anon'>();

        let right = Rbits.RBITS_MINT();
        let manager_right = 'RBITS MINT MANAGER';

        Manager.set_permit(manager, manager_right, 999);
        Manager.bind_manager_right(right, manager_right);

        set_contract_address(manager);
        Manager.set_permit(anon, right, 999);

        set_contract_address(anon);
        Rbits.mint(anon, 1_u256);
        assert(Rbits.balance_of(anon) == 1_u256, 'Mints wrong amount');
    }

    #[test]
    #[available_gas(2000000)]
    fn burn_with_delegated_permit() {
        let (Manager, Rbits) = deploy_suite();
        let manager = contract_address_const::<'manager'>();
        let anon = contract_address_const::<'anon'>();

        let right = Rbits.RBITS_BURN();
        let manager_right = 'RBITS BURN MANAGER';

        Manager.set_permit(manager, manager_right, 999);
        Manager.bind_manager_right(right, manager_right);

        set_contract_address(manager);
        Manager.set_permit(anon, right, 999);

        set_contract_address(anon);
        Rbits.burn(Manager.owner(), 122_u256);
        assert(Rbits.balance_of(Manager.owner()) == 1_u256, 'Mints wrong amount');
    }
}

