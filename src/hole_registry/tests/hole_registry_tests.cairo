#[cfg(test)]
mod EntryPoint {
    use hole_registry::hole_registry::HoleRegistry;
    use hole_registry::hole_registry::IHoleRegistryDispatcher;
    use hole_registry::hole_registry::IHoleRegistryDispatcherTrait;
    use rbits::rbits::Rbits;
    use rbits::rbits::IRbitsDispatcher;
    use rbits::rbits::IRbitsDispatcherTrait;
    use manager::manager::Manager;
    use manager::manager::IManagerDispatcher;
    use manager::manager::IManagerDispatcherTrait;

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


    fn deploy_suite() -> (IManagerDispatcher, IRbitsDispatcher, IHoleRegistryDispatcher) {
        set_block_timestamp(12345);
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let mut calldata = ArrayTrait::new();
        calldata.append(owner.into());

        let (manager_address, _) = deploy_syscall(
            Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let Manager = IManagerDispatcher { contract_address: manager_address };

        let mut calldata = ArrayTrait::new();
        let init_supply_low = 1000_u128;
        let init_supply_high = 0_u128;
        calldata.append(init_supply_low.into());
        calldata.append(init_supply_high.into());
        calldata.append(owner.into());
        calldata.append(manager_address.into());

        let (rbits_address, _) = deploy_syscall(
            Rbits::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let Rbits = IRbitsDispatcher { contract_address: rbits_address };

        let mut calldata = ArrayTrait::new();
        let dig_fee_low = 111_u128;
        let dig_fee_high = 0_u128;
        let dig_reward_low = 222_u128;
        let dig_reward_high = 0_u128;
        let dig_token_address = rbits_address;

        calldata.append(dig_fee_low.into());
        calldata.append(dig_fee_high.into());
        calldata.append(dig_reward_low.into());
        calldata.append(dig_reward_high.into());
        calldata.append(dig_token_address.into());
        calldata.append(rbits_address.into());
        calldata.append(manager_address.into());

        let (hole_registry_address, _) = deploy_syscall(
            HoleRegistry::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let HoleRegistry = IHoleRegistryDispatcher { contract_address: hole_registry_address };

        Manager.set_permit(HoleRegistry.contract_address, Rbits.MINT_RBITS(), 99999);

        (Manager, Rbits, HoleRegistry)
    }

    #[test]
    #[available_gas(2000000)]
    fn constructor() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        assert(HoleRegistry.DIG_HOLES() == 'DIG HOLES', 'Incorrect DIG HOLES');
        assert(HoleRegistry.PLACE_RABBITS() == 'PLACE RABBITS', 'Incorrect PLACE RABBITS');

        assert(HoleRegistry.dig_fee() == 111_u256, 'Incorrect dig fee');
        assert(HoleRegistry.dig_reward() == 222_u256, 'Incorrect dig reward');
        assert(
            HoleRegistry.dig_token_address() == Rbits.contract_address,
            'Incorrect dig token address'
        );
        assert(HoleRegistry.RBITS_ADDRESS() == Rbits.contract_address, 'Incorrect RBITS address');
        assert(
            HoleRegistry.MANAGER_ADDRESS() == Manager.contract_address, 'Incorrect MANAGER address'
        );
    }

    #[test]
    #[available_gas(10000000)]
    fn dig_hole() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        let digger = contract_address_const::<'digger'>();
        let title = 'title';

        Rbits.transfer(digger, 1000_u256);
        set_contract_address(digger);
        Rbits.approve(HoleRegistry.contract_address, 1000_u256);
        let global_id = HoleRegistry.dig_hole(title);

        assert(global_id == 1_u64, 'Incorrect hole id');
        assert(global_id == HoleRegistry.total_holes(), 'Incorrect totla holes');
        assert(
            Rbits.balance_of(digger) == 1000_u256
                - HoleRegistry.dig_fee()
                + HoleRegistry.dig_reward(),
            'Incorrect balance'
        );
        let hole = HoleRegistry.get_hole(global_id);
        assert(hole.digger == digger, 'Incorrect digger');
        assert(hole.title == title, 'Incorrect title');
        assert(hole.timestamp == 12345_u64, 'Incorrect dig time');
        assert(hole.depth == 1_u64, 'Incorrect depth');
        assert(HoleRegistry.get_hole_id(title) == 1_u64, 'Hole id not mapped');
        assert(HoleRegistry.user_stats(digger) == 1_u64, 'Incorrect user hole count');
        assert(HoleRegistry.get_hole_digger(1_u64) == digger, 'Incorrect hole digger');
        let holes = HoleRegistry.user_holes(digger, 0, 1);
        assert(*holes[0] == 1_u64 & holes.len() == 1_u32, 'Incorrect user holes');
    /// ** test event
    }

    #[test]
    #[available_gas(10000000)]
    fn dig_hole_permitted_yes() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        let digger = contract_address_const::<'digger'>();
        let anon = contract_address_const::<'anon'>();
        let title = 'title';

        Manager.set_permit(digger, HoleRegistry.DIG_HOLES(), 99999);

        Rbits.transfer(digger, 1000_u256);
        set_contract_address(digger);
        let global_id = HoleRegistry.dig_hole_permitted(title, anon);

        assert(global_id == 1_u64, 'Incorrect hole id');
        assert(global_id == HoleRegistry.total_holes(), 'Incorrect totla holes');
        assert(Rbits.balance_of(digger) == 1000_u256, 'Incorrect balance');
        assert(Rbits.balance_of(anon) == 0_u256, 'Incorrect balance');

        let hole = HoleRegistry.get_hole(global_id);
        assert(hole.digger == anon, 'Incorrect digger');
        assert(hole.title == title, 'Incorrect title');
        assert(hole.timestamp == 12345_u64, 'Incorrect dig time');
        assert(hole.depth == 1_u64, 'Incorrect depth');
        assert(HoleRegistry.get_hole_id(title) == 1_u64, 'Hole id not mapped');
        assert(HoleRegistry.user_stats(anon) == 1_u64, 'Incorrect user hole count');
        let holes = HoleRegistry.user_holes(anon, 0, 1);
        assert(*holes[0] == 1_u64 & holes.len() == 1_u32, 'Incorrect user holes');
    /// ** test event
    }

    #[test]
    #[available_gas(10000000)]
    #[should_panic(expected: ('HoleRegistry: Caller non digger', 'ENTRYPOINT_FAILED'))]
    fn dig_hole_permitted_no() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        let digger = contract_address_const::<'digger'>();
        let anon = contract_address_const::<'anon'>();
        let title = 'title';
        set_contract_address(digger);
        let global_id = HoleRegistry.dig_hole_permitted(title, anon);
    }

    #[test]
    #[available_gas(10000000)]
    fn place_rabbit_in_hole() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        let digger = contract_address_const::<'digger'>();
        let anon = contract_address_const::<'anon'>();
        let title = 'title';

        Manager.set_permit(digger, HoleRegistry.DIG_HOLES(), 99999);
        Manager.set_permit(anon, HoleRegistry.PLACE_RABBITS(), 99999);

        Rbits.transfer(digger, 1000_u256);
        set_contract_address(digger);
        let global_id = HoleRegistry.dig_hole_permitted(title, anon);

        set_contract_address(anon);
        HoleRegistry.place_rabbit_in_hole(global_id, 111_u64, anon);

        assert(
            HoleRegistry.the_rabbit_hole(global_id, 2_u64) == 111_u64, 'Incorrect rabbit in hole'
        );

        assert(HoleRegistry.get_hole(global_id).depth == 2_u64, 'Incorrect depth');
    }

    #[test]
    #[available_gas(10000000)]
    #[should_panic(expected: ('HoleRegistry: Caller non leaver', 'ENTRYPOINT_FAILED'))]
    fn place_rabbit_in_hole_no_permit() {
        let (Manager, Rbits, HoleRegistry) = deploy_suite();
        let digger = contract_address_const::<'digger'>();
        let anon = contract_address_const::<'anon'>();
        let title = 'title';

        Manager.set_permit(digger, HoleRegistry.DIG_HOLES(), 99999);
        Rbits.transfer(digger, 1000_u256);
        set_contract_address(digger);
        let global_id = HoleRegistry.dig_hole_permitted(title, anon);

        set_contract_address(anon);
        HoleRegistry.place_rabbit_in_hole(global_id, 1_u64, anon);
    }
}

#[cfg(test)]
mod Internal {
    use hole_registry::hole_registry::HoleRegistry;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_block_timestamp;
    use debug::PrintTrait;
    use array::ArrayTrait;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use result::ResultTrait;

    fn _deploy() -> ContractAddress {
        let deployer = contract_address_const::<1>();
        set_caller_address(deployer);
        HoleRegistry::constructor(111_u256, 222_u256, deployer, deployer, deployer);
        deployer
    }

    #[test]
    #[available_gas(2000000)]
    fn _initializer() {
        let deployer = _deploy();
        assert(HoleRegistry::dig_fee() == 111_u256, 'Incorrect dig fee');
        assert(HoleRegistry::dig_reward() == 222_u256, 'Incorrect rabbit price');
        assert(HoleRegistry::dig_token_address() == deployer, 'Incorrect fee token');
        assert(HoleRegistry::RBITS_ADDRESS() == deployer, 'Incorrect rbits addr');
    }

    fn _dig_hole_helper(title_: felt252, from_: ContractAddress) -> (u64, u64) {
        set_block_timestamp(123);
        HoleRegistry::_dig_hole(title_, from_)
    }

    #[test]
    #[available_gas(2000000)]
    fn _dig_hole() {
        let deployer = _deploy();
        _dig_hole_helper('title', deployer);
        _dig_hole_helper('title2', deployer);
        let (global_depth, user_depth) = _dig_hole_helper('title3', deployer);
        assert(global_depth == 3_u64, 'Incorrect global depth');
        assert(user_depth == 3_u64, 'Incorrect user depth');
        // assert()
        let user_stats = HoleRegistry::user_stats(deployer);
        let ex_hole = HoleRegistry::Hole {
            title: 'title', depth: 1_u64, timestamp: 123_u64, digger: deployer, 
        };
        let ex_hole2 = HoleRegistry::Hole {
            title: 'title2', depth: 1_u64, timestamp: 123_u64, digger: deployer, 
        };
        let ex_hole3 = HoleRegistry::Hole {
            title: 'title3', depth: 1_u64, timestamp: 123_u64, digger: deployer, 
        };
        assert(ex_hole.title == HoleRegistry::get_hole(1_u64).title, 'Incorrect hole');
        assert(ex_hole2.timestamp == HoleRegistry::get_hole(2_u64).timestamp, 'Incorrect hole');
        assert(ex_hole3.digger == HoleRegistry::get_hole(2_u64).digger, 'Incorrect hole');
        assert(HoleRegistry::get_hole_id('title') == 1_u64, 'Incorrect hole id');
        assert(HoleRegistry::get_hole_id('title2') == 2_u64, 'Incorrect hole id');
        assert(HoleRegistry::get_hole_id('title3') == 3_u64, 'Incorrect hole id');
        assert(user_stats == 3_u64, 'Incorrect user holes count');
        assert(HoleRegistry::total_holes() == 3_u64, 'Incorrect holes count');
        let arr = HoleRegistry::user_holes(deployer, 2, 222222);
        assert(*arr[0] == 2_u64, 'Incorrect user holes');
        assert(*arr[1] == 3_u64, 'Incorrect user holes');
        assert(arr.len() == 2_u32, 'Incorrect user holes len');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Hole already exists', ))]
    fn _dig_hole_again() {
        let deployer = _deploy();

        _dig_hole_helper('title', deployer);
        _dig_hole_helper('title', deployer);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Invalid digger address', ))]
    fn _dig_hole_from_zero() {
        let deployer = _deploy();
        let z = contract_address_const::<0>();

        _dig_hole_helper('title', z);
    }

    #[test]
    #[available_gas(2000000)]
    fn _place_rabbit_in_hole() {
        let deployer = _deploy();
        _dig_hole_helper('title', deployer);
        HoleRegistry::_place_rabbit_in_hole(1_u64, 1_u64, deployer);
        HoleRegistry::_place_rabbit_in_hole(1_u64, 2_u64, deployer);
        let hole = HoleRegistry::get_hole(1_u64);
        assert(hole.depth == 3_u64, 'Incorrect depth');
        let user_stats = HoleRegistry::user_stats(deployer);
        /// holes' 1st slot (index) is empty, it shows the hole is dug
        assert(HoleRegistry::the_rabbit_hole(1_u64, 2_u64) == 1_u64, 'Incorrect rabbit 1');
        assert(HoleRegistry::the_rabbit_hole(1_u64, 3_u64) == 2_u64, 'Incorrect rabbit 2');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Invalid hole id', ))]
    fn _place_rabbit_in_z_hole() {
        let deployer = _deploy();
        HoleRegistry::_place_rabbit_in_hole(0_u64, 1_u64, deployer);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Invalid rabbit id', ))]
    fn _place_z_rabbit_in_hole() {
        let deployer = _deploy();
        HoleRegistry::_place_rabbit_in_hole(1_u64, 0_u64, deployer);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('Invalid burner address', ))]
    fn _place_rabbit_in_hole_from_zero() {
        let deployer = _deploy();
        let z = contract_address_const::<0>();
        HoleRegistry::_place_rabbit_in_hole(1_u64, 1_u64, z);
    }

    #[test]
    #[available_gas(2000000)]
    fn _inc_user_holes() {
        let deployer = _deploy();
        let user_stats = HoleRegistry::user_stats(deployer);
        assert(user_stats == 0_u64, 'Incorrect user holes count');
        HoleRegistry::_inc_user_holes(deployer, 333_u64);
        HoleRegistry::_inc_user_holes(deployer, 444_u64);
        HoleRegistry::_inc_user_holes(deployer, 555_u64);
        let user_stats = HoleRegistry::user_stats(deployer);
        assert(user_stats == 3_u64, 'Incorrect user holes count');
        let arr = HoleRegistry::user_holes(deployer, 0_u64, 3_u64);
        assert(*arr[0] == 333_u64, 'Incorrect user holes1');
        assert(*arr[1] == 444_u64, 'Incorrect user holes2');
        assert(*arr[2] == 555_u64, 'Incorrect user holes3');
        assert(arr.len() == 3_u32, 'Incorrect user holes len');
    }
}

