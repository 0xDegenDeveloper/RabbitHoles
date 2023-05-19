use starknet::ContractAddress;

#[abi]
trait IManager {
    fn owner() -> starknet::ContractAddress;
}

#[abi]
trait IRbits {
    fn total_supply() -> u256;
    fn balance_of(account: ContractAddress) -> u256;
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(spender: ContractAddress, amount: u256) -> bool;
    fn burn(owner: ContractAddress, amount: u256);
}

#[cfg(test)]
mod EntryPoint {
    use manager::manager::Manager;
    use rbits::rbits::Rbits;

    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;

    use super::IRbitsDispatcher;
    use super::IRbitsDispatcherTrait;

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

    fn deploy_suite() -> (IManagerDispatcher, IRbitsDispatcher) {
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
                }, IRbitsDispatcher {
                contract_address: rbits_address
            }
        )
    }

    #[test]
    #[available_gas(2000000)]
    fn total_supply() {
        let (Manager, Rbits) = deploy_suite();
        assert(Rbits.total_supply() == 123_u256, 'Incorrect total supply');
        Rbits.burn(Manager.owner(), 1_u256);
        assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer() {
        let (Manager, Rbits) = deploy_suite();
        let recipient = contract_address_const::<222>();
        Rbits.transfer(recipient, 1_u256);
        assert(Rbits.balance_of(Manager.owner()) == 122_u256, 'Incorrect balance');
        assert(Rbits.balance_of(recipient) == 1_u256, 'Incorrect balance');
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_from() {
        let (Manager, Rbits) = deploy_suite();
        let recipient = contract_address_const::<222>();
        let spender = contract_address_const::<333>();
        Rbits.approve(spender, 1_u256);
        set_contract_address(spender);
        Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
        assert(Rbits.balance_of(Manager.owner()) == 122_u256, 'Incorrect balance');
        assert(Rbits.balance_of(recipient) == 1_u256, 'Incorrect balance');
        assert(Rbits.balance_of(spender) == 0_u256, 'Incorrect balance');
        assert(Rbits.allowance(Manager.owner(), spender) == 0_u256, 'Incorrect allowance');
    }

    #[test]
    #[available_gas(2000000)]
    #[should_panic(expected: ('u256_sub Overflow', 'ENTRYPOINT_FAILED'))]
    fn transfer_from_overflow() {
        let (Manager, Rbits) = deploy_suite();
        let recipient = contract_address_const::<222>();
        let spender = contract_address_const::<333>();
        Rbits.approve(spender, 1_u256);
        set_contract_address(spender);
        Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
        assert(Rbits.allowance(Manager.owner(), spender) == 0_u256, 'Incorrect allowance');
        Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
    }

    #[test]
    #[available_gas(2000000)]
    fn transfer_from_unlimited() {
        let (Manager, Rbits) = deploy_suite();
        let recipient = contract_address_const::<222>();
        let spender = contract_address_const::<333>();
        let unlimited = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256;
        Rbits.approve(spender, unlimited);
        set_contract_address(spender);
        Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
        assert(Rbits.allowance(Manager.owner(), spender) == unlimited, 'Incorrect allowance');
    }
}

#[cfg(test)]
mod Internals {
    use rbits::rbits::Rbits;
    use starknet::contract_address_const;
    use debug::PrintTrait;

    #[test]
    #[available_gas(2000000)]
    fn _initializer() {
        let owner = contract_address_const::<'owner'>();
        let manager = contract_address_const::<'manager'>();

        Rbits::constructor(123_u256, owner, manager);
        assert(Rbits::MINT_RBITS() == 'MINT RBITS', 'Incorrect MINT_RBITS');
        assert(Rbits::BURN_RBITS() == 'BURN RBITS', 'Incorrect BURN_RBITS');
        assert(Rbits::MANAGER_ADDRESS() == manager, 'Incorrect MANAGER_ADDRESS');

        assert(Rbits::name() == 'RabbitHoles', 'Incorrect name');
        assert(Rbits::symbol() == 'RBITS', 'Incorrect symbol');
        assert(Rbits::decimals() == 18_u8, 'Incorrect decimals');
        assert(Rbits::total_supply() == 123_u256, 'Incorrect total supply');
        assert(Rbits::balance_of(owner) == 123_u256, 'Incorrect balance');
    }

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
