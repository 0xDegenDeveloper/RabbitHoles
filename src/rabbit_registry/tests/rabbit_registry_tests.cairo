#[cfg(test)]
mod Internal {
    use rabbit_registry::rabbit_registry::RabbitRegistry;
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
        RabbitRegistry::constructor(deployer, deployer, deployer);
        deployer
    }

    #[test]
    #[available_gas(2000000)]
    fn _initializer() {
        let deployer = _deploy();
    }

    // fn _dig_hole_helper(title_: felt252, from_: ContractAddress) -> (u64, u64) {
    //     set_block_timestamp(123);
    //     HoleRegistry::_dig_hole(title_, from_)
    // }

    #[test]
    #[available_gas(2000000)]
    fn _add_burn_log() { // let deployer = _deploy();
    // RabbitRegistry::_add_burn_log(deployer, 1111_u64);

    // assert(RabbitRegistry::burn_logs_total() == 1_u64, 'Incorrect burn_logs_total');
    // assert(RabbitRegistry::burn_logs(1_u64) == deployer, 'Incorrect log addr');
    // assert(RabbitRegistry::burn_logs_record(1_u64) == 1111_u64, 'Incorrect rabbit start');
    }
}
