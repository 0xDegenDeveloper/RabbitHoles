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

#[cfg(test)]
mod Internals {
    use rbits::rbits::Rbits;
    use starknet::contract_address_const;

    #[test]
    #[available_gas(2000000)]
    fn _approve() {
        let a = contract_address_const::<1>();
        let b = contract_address_const::<2>();
        Rbits::_approve(a, b, 1_u256);
        assert(Rbits::allowance(a, b) == 1_u256, 'Incorrect allowance');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: approve from 0', ))]
    fn _approve_from_zero() {
        let z = contract_address_const::<0>();
        let x = contract_address_const::<1>();
        Rbits::_approve(z, x, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: approve to 0', ))]
    fn _approve_to_zero() {
        let z = contract_address_const::<0>();
        let x = contract_address_const::<1>();
        Rbits::_approve(x, z, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn _transfer() {
        let a = contract_address_const::<1>();
        let b = contract_address_const::<2>();
        assert(Rbits::balance_of(a) == 0_u256, 'Incorrect balance');
        assert(Rbits::balance_of(b) == 0_u256, 'Incorrect balance');
        Rbits::_mint(a, 10_u256);
        assert(Rbits::balance_of(a) == 10_u256, 'Incorrect balance');
        Rbits::_transfer(a, b, 1_u256);
        assert(Rbits::balance_of(a) == 9_u256, 'Incorrect balance');
        assert(Rbits::balance_of(b) == 1_u256, 'Incorrect balance');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: transfer from 0', ))]
    fn _transfer_from_zero() {
        let a = contract_address_const::<0>();
        let b = contract_address_const::<1>();
        Rbits::_transfer(a, b, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: transfer to 0', ))]
    fn _transfer_to_zero() {
        let a = contract_address_const::<1>();
        let b = contract_address_const::<0>();
        Rbits::_transfer(a, b, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn _spend_allowance_unlimited() {
        let unlimited = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256;
        let a = contract_address_const::<1>();
        let b = contract_address_const::<2>();
        Rbits::_approve(a, b, unlimited);
        Rbits::_spend_allowance(a, b, 1_u256);
        assert(Rbits::allowance(a, b) == unlimited, 'Incorrect allowance');
    }

    #[test]
    #[available_gas(2000000)]
    fn _spend_allowance() {
        let a = contract_address_const::<1>();
        let b = contract_address_const::<2>();
        Rbits::_approve(a, b, 10_u256);
        Rbits::_spend_allowance(a, b, 1_u256);
        assert(Rbits::allowance(a, b) == 9_u256, 'Incorrect allowance');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: mint to 0', ))]
    fn _mint_to_zero() {
        let z = contract_address_const::<0>();
        Rbits::_mint(z, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn _mint() {
        let a = contract_address_const::<1>();
        assert(Rbits::balance_of(a) == 0_u256, 'Incorrect balance');
        Rbits::_mint(a, 1_u256);
        assert(Rbits::balance_of(a) == 1_u256, 'Incorrect balance');
        assert(Rbits::total_supply() == 1_u256, 'Incorrect total supply');
    /// @dev: test event
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('ERC20: burn from 0', ))]
    fn _burn_from_zero() {
        let z = contract_address_const::<0>();
        Rbits::_burn(z, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn _burn() {
        let a = contract_address_const::<1>();
        Rbits::_mint(a, 10_u256);
        Rbits::_burn(a, 2_u256);
        assert(Rbits::balance_of(a) == 8_u256, 'Incorrect balance');
        assert(Rbits::total_supply() == 8_u256, 'Incorrect total supply');
    /// @dev: test event
    }
}
