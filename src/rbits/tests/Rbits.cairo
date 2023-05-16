#[cfg(test)]
mod EntryPoint {
    use rbits::rbits::Rbits;
    use manager::manager::Manager;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::get_caller_address;
    use starknet::testing::set_contract_address;
    use starknet::get_contract_address;

    use debug::PrintTrait;

    fn _deploy() -> ContractAddress {
        let addr = _deploy_manager();
        let owner = contract_address_const::<1>();

        let init_supply = 123_u256;
        set_caller_address(owner);
        Rbits::constructor(init_supply, owner, addr);
        owner
    }

    fn _deploy_manager() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<1>();
        let addr = contract_address_const::<11>();
        set_caller_address(owner);
        Manager::constructor(owner);
        Manager::_set_address(addr);
        // Manager::get_contract_address().print();
        Manager::_address()
    }

    #[test]
    #[available_gas(2000000)]
    fn mint() {}

    #[test]
    #[available_gas(2000000)]
    // #[should_panic(expected: ('RBITS: Caller non minter', ))]
    fn mint_no_permit() {
        let deployer = _deploy();
        set_caller_address(contract_address_const::<11>());
        Rbits::mint(deployer, 1_u256);
    }
// #[test]
// #[available_gas(2000000)]
// fn burn() {}

// #[test]
// #[available_gas(2000000)]
// #[should_panic(expected: ('RBITS: Caller non burner', ))]
// fn burn_no_permit() {
//     let deployer = _deploy();
//     Rbits::burn(deployer, 123_u256);
// }
}

#[cfg(test)]
mod Internals {
    use rbits::rbits::Rbits;
    use starknet::contract_address_const;
}
