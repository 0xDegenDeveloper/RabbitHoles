use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;
use rabbitholes::{
    core::erc20::{ERC20, IERC20, IERC20DispatcherTrait, IERC20Dispatcher},
    core::manager::{Manager, IManager, IManagerDispatcherTrait, IManagerDispatcher},
    tests::_core::_manager::{_set_permit_from_for}
};
use result::ResultTrait;
use starknet::{
    testing::{set_caller_address, set_contract_address, set_block_timestamp},
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    contract_address_const, get_caller_address
};
use traits::{Into, TryInto};

fn deploy_suite() -> (IManagerDispatcher, IERC20Dispatcher) {
    let owner = contract_address_const::<'owner'>();
    let mut calldata = ArrayTrait::new();
    set_contract_address(owner);
    calldata.append(owner.into());

    let (manager_address, _) = deploy_syscall(
        Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();
    let mut calldata = ArrayTrait::new();

    calldata.append('RabbitHoles'.into());
    calldata.append('RBITS'.into());
    calldata.append(6_u8.into());
    calldata.append(123_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());
    calldata.append(manager_address.into());

    let (rbits_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
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
fn constructor() {
    let (Manager, Rbits) = deploy_suite();
    assert(Rbits.name() == 'RabbitHoles', 'Incorrect name');
    assert(Rbits.symbol() == 'RBITS', 'Incorrect symbol');
    assert(Rbits.decimals() == 6_u8, 'Incorrect decimals');
    assert(Rbits.balance_of(Manager.owner()) == 123_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 123_u256, 'Incorrect supply');
    assert(Rbits.manager_address() == Manager.contract_address, 'Incorrect manager address');
    assert(Rbits.SUDO_MINT() == 'SUDO_MINT', 'Incorrect SUDO_MINT');
    assert(Rbits.SUDO_BURN() == 'SUDO_BURN', 'Incorrect SUDO_BURN');
}

#[test]
#[available_gas(2000000)]
fn allowances() {
    let (Manager, Rbits) = deploy_suite();
    let spender = contract_address_const::<'spender'>();
    assert(Rbits.allowance(Manager.owner(), spender) == 0_u256, 'Incorrect allowance');
    set_contract_address(Manager.owner());
    Rbits.increase_allowance(spender, 2_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == 2_u256, 'Incorrect allowance');
    Rbits.decrease_allowance(spender, 1_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == 1_u256, 'Incorrect allowance');
    Rbits.approve(spender, 3_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == 3_u256, 'Incorrect allowance');
}

#[test]
#[available_gas(2000000)]
fn transfer() {
    let (Manager, Rbits) = deploy_suite();
    let to = contract_address_const::<'to'>();
    Rbits.transfer(to, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 122_u256, 'Incorrect balance');
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
}

#[test]
#[available_gas(2000000)]
fn transfer_from() {
    let (Manager, Rbits) = deploy_suite();
    let to = contract_address_const::<'to'>();
    let spender = contract_address_const::<'spender'>();
    Rbits.approve(spender, 1_u256);
    set_contract_address(spender);
    Rbits.transfer_from(Manager.owner(), to, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 122_u256, 'Incorrect balance');
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
    assert(Rbits.balance_of(spender) == 0_u256, 'Incorrect balance');
    assert(Rbits.allowance(Manager.owner(), spender) == 0_u256, 'Incorrect allowance');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('ERC20: insufficient allowance', 'ENTRYPOINT_FAILED'))]
fn transfer_from_no_allowance() {
    let (Manager, Rbits) = deploy_suite();
    let recipient = contract_address_const::<222>();
    let spender = contract_address_const::<333>();
    Rbits.increase_allowance(spender, 1_u256);
    Rbits.increase_allowance(spender, 1_u256);
    set_contract_address(spender);
    Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
    Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == 0_u256, 'Incorrect allowance');
    Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
}

#[test]
#[available_gas(2000000)]
fn transfer_from_unlimited_allowance() {
    let (Manager, Rbits) = deploy_suite();
    let recipient = contract_address_const::<222>();
    let spender = contract_address_const::<333>();
    let unlimited = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256;
    Rbits.approve(spender, unlimited);
    set_contract_address(spender);
    Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == unlimited, 'Incorrect allowance');
}

#[test]
#[available_gas(2000000)]
fn sudo_mint_as_owner() {
    let (Manager, Rbits) = deploy_suite();
    let recipient = contract_address_const::<222>();
    Rbits.sudo_mint(recipient, 1_u256);
    assert(Rbits.balance_of(recipient) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_mint_as_anon() {
    set_block_timestamp(12345);
    let (Manager, Rbits) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Rbits.sudo_mint(Manager.owner(), 1_u256);
}

#[test]
#[available_gas(2000000)]
fn sudo_mint_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let manager = contract_address_const::<'manager'>();
    let to = contract_address_const::<'to'>();
    _set_permit_from_for(Manager, Manager.owner(), manager, Rbits.SUDO_MINT(), 1000000);
    Rbits.sudo_mint(to, 1_u256);
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(2000000)]
fn sudo_mint_manager() {
    let (Manager, Rbits) = deploy_suite();
    let owner = Manager.owner();
    let manager = contract_address_const::<111>();
    let anon = contract_address_const::<'anon'>();
    let to = contract_address_const::<'to'>();
    /// Give manager MINT_MANAGER and MANANGER permits
    _set_permit_from_for(Manager, owner, manager, Manager.MANAGER_PERMIT(), 1000000);
    _set_permit_from_for(Manager, owner, manager, 'MINT_MANAGER', 1000000);
    /// Manager binds SUDO_MINT permit to MINT_MANAGER permit
    set_contract_address(manager);
    Manager.set_sudo_permit(Rbits.SUDO_MINT(), 'MINT_MANAGER');
    /// Manager sets SUDO_MINT permit for anon
    _set_permit_from_for(Manager, manager, anon, Rbits.SUDO_MINT(), 1000000);
    set_contract_address(anon);
    /// Anon has SUDO_MINT permit, granted by a manager
    Rbits.sudo_mint(to, 1_u256);
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(3000000)]
fn sudo_burn_as_owner() {
    let (Manager, Rbits) = deploy_suite();
    let user = contract_address_const::<'user'>();
    /// Owner sends tokens to user
    Rbits.transfer(user, 2_u256);
    /// User gives owner alloance
    set_contract_address(user);
    Rbits.approve(Manager.owner(), 1_u256);
    /// Owner can SUDO_BURN user's tokens
    set_contract_address(Manager.owner());
    Rbits.sudo_burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_burn_as_anon() {
    let (Manager, Rbits) = deploy_suite();
    let user = contract_address_const::<'user'>();
    let anon = contract_address_const::<'anon'>();
    /// Owner sends tokens to user
    Rbits.transfer(user, 2_u256);
    set_contract_address(user);
    /// User approves anon to spend tokens
    Rbits.approve(Manager.owner(), 1_u256);
    /// Anon cannot burn because they do not have the SUDO_BURN permit
    set_contract_address(anon);
    Rbits.sudo_burn(user, 1_u256);
}

#[test]
#[available_gas(3000000)]
fn sudo_burn_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let user = contract_address_const::<'user'>();
    /// Owner sends tokens to user
    Rbits.transfer(user, 2_u256);
    /// User approves anon to spend tokens
    set_contract_address(user);
    Rbits.approve(anon, 1_u256);
    /// Owner gives anon SUDO_BURN permit
    _set_permit_from_for(Manager, Manager.owner(), anon, Rbits.SUDO_BURN(), 1000000);
    /// Anon can burn tokens
    set_contract_address(anon);
    Rbits.sudo_burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(3000000)]
fn sudo_burn_as_manager() {
    let (Manager, Rbits) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let manager0 = contract_address_const::<'manager0'>();
    let manager = contract_address_const::<'manager'>();
    let user = contract_address_const::<'user'>();
    /// Owner sends tokens to user
    Rbits.transfer(user, 2_u256);
    set_contract_address(user);
    /// User approves anon to spend tokens
    Rbits.approve(anon, 1_u256);
    /// Owner gives manager0 MANAGER permit
    _set_permit_from_for(Manager, Manager.owner(), manager0, Manager.MANAGER_PERMIT(), 1000000);
    /// Manager0 binds SUDO_BURN to BURN_MANAGER
    set_contract_address(manager0);
    Manager.set_sudo_permit(Rbits.SUDO_BURN(), 'BURN_MANAGER');
    /// Manager0 grants BURN_MANAGER permit to manager
    _set_permit_from_for(Manager, Manager.owner(), manager, 'BURN_MANAGER', 1000000);
    /// Manager gives anon SUDO_BURN permit
    _set_permit_from_for(Manager, manager, anon, Rbits.SUDO_BURN(), 1000000);
    /// Anon can burn tokens
    set_contract_address(anon);
    Rbits.sudo_burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}
