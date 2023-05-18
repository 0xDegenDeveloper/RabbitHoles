#[cfg(test)]
mod EntryPoint {
    use rbits::rbits::Rbits;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::get_caller_address;

    fn _deploy() -> ContractAddress {
        let deployer = contract_address_const::<1>();
        let manager = contract_address_const::<10>();
        let init_supply = 123_u256;
        set_caller_address(deployer);
        Rbits::constructor(init_supply, deployer, manager);
        deployer
    }

    #[test]
    #[available_gas(2000000)]
    fn constructor() {
        let deployer = _deploy();
        assert(Rbits::balance_of(deployer) == 123_u256, 'Incorrect balance');
        assert(Rbits::total_supply() == 123_u256, 'Incorrect total supply');
        assert(Rbits::name() == 'RabbitHoles', 'Incorrect name');
        assert(Rbits::symbol() == 'RBITS', 'Incorrect symbol');
        assert(Rbits::decimals() == 18_u8, 'Incorrect decimals');
    }

    #[test]
    #[available_gas(2000000)]
    fn total_supply() {
        assert(Rbits::total_supply() == 0_u256, 'Incorrect total supply');
        let deployer = _deploy();
        assert(Rbits::total_supply() == 123_u256, 'Incorrect total supply');
        Rbits::_burn(deployer, 1_u256);
        assert(Rbits::total_supply() == 122_u256, 'Incorrect total supply');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer() {
        let deployer = _deploy();
        let recipient = contract_address_const::<2>();
        Rbits::transfer(recipient, 1_u256);
        assert(Rbits::balance_of(deployer) == 122_u256, 'Incorrect balance');
        assert(Rbits::balance_of(recipient) == 1_u256, 'Incorrect balance');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_from() {
        let deployer = _deploy();
        let recipient = contract_address_const::<2>();
        let spender = contract_address_const::<3>();
        Rbits::approve(spender, 1_u256);
        set_caller_address(spender);
        Rbits::transfer_from(deployer, recipient, 1_u256);
        assert(Rbits::balance_of(deployer) == 122_u256, 'Incorrect balance');
        assert(Rbits::balance_of(recipient) == 1_u256, 'Incorrect balance');
        assert(Rbits::balance_of(spender) == 0_u256, 'Incorrect balance');
        assert(Rbits::allowance(deployer, spender) == 0_u256, 'Incorrect allowance');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('u256_sub Overflow', ))]
    fn transfer_from_overflow() {
        let deployer = _deploy();
        let recipient = contract_address_const::<2>();
        let spender = contract_address_const::<3>();
        Rbits::approve(spender, 1_u256);
        set_caller_address(spender);
        Rbits::transfer_from(deployer, recipient, 1_u256);
        assert(Rbits::allowance(deployer, spender) == 0_u256, 'Incorrect allowance');
        Rbits::transfer_from(deployer, recipient, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_from_unlimited() {
        let deployer = _deploy();
        let recipient = contract_address_const::<2>();
        let spender = contract_address_const::<3>();
        let unlimited = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256;
        Rbits::approve(spender, unlimited);
        set_caller_address(spender);
        Rbits::transfer_from(deployer, recipient, 1_u256);
        assert(Rbits::allowance(deployer, spender) == unlimited, 'Incorrect allowance');
    }
}
