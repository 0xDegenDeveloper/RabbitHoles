/// @dev: Need to figure out contract addresses with testing

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
        let (owner, addr) = _deploy_manager();
        let init_supply = 123_u256;
        let addrThis = contract_address_const::<333>();
        set_contract_address(addrThis);
        Rbits::constructor(init_supply, owner, addrThis);
        Rbits::constructor(init_supply, owner, addrThis);
        owner
    }

    fn _deploy_manager() -> (ContractAddress, ContractAddress) {
        let owner: ContractAddress = contract_address_const::<1>();
        let addr = contract_address_const::<111>();
        set_caller_address(owner);
        set_contract_address(addr);
        Manager::constructor(owner);
        (owner, addr)
    }
// #[test]
// #[available_gas(2000000)]
// fn mint() {
//     let owner = _deploy();
//     Manager::get_contract_address().print();
//     Rbits::get_contract_address().print();
//     Rbits::mint(owner, 1_u256);
// let balance = Rbits::balance_of(owner);
// assert_eq!(balance, amount);
}
// #[test]
// #[available_gas(2000000)]
// #[should_panic(expected: ('RBITS: Caller non minter', ))]
// fn mint_no_permit() {}

// #[test]
// #[available_gas(2000000)]
// fn burn() {}

// #[test]
// #[available_gas(2000000)]
// #[should_panic(expected: ('RBITS: Caller non burner', ))]
// fn burn_no_permit() {}
// }

#[cfg(test)]
mod Internals {
    use rbits::rbits::Rbits;
    use starknet::contract_address_const;
}
