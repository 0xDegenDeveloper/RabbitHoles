use array::ArrayTrait;
use integer::BoundedInt;
use debug::PrintTrait;
use option::OptionTrait;
use rabbitholes::{
    core::erc20::{ERC20, IERC20, IERC20DispatcherTrait, IERC20Dispatcher},
    core::manager::{Manager, IManager, IManagerDispatcherTrait, IManagerDispatcher},
};
use result::ResultTrait;
use starknet::{
    testing::{set_caller_address, set_contract_address, set_block_timestamp},
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    contract_address_const, get_caller_address
};
use traits::{Into, TryInto};

/// helper 
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

    calldata.append(manager_address.into());
    calldata.append('RabbitHoles'.into());
    calldata.append('RBITS'.into());
    calldata.append(6_u8.into());
    calldata.append(123_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());

    let (rbits_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    let ierc20 = IERC20Dispatcher { contract_address: rbits_address };

    ierc20.toggle_burning();
    ierc20.toggle_minting();

    (IManagerDispatcher { contract_address: manager_address }, ierc20)
}

/// tests
#[test]
#[available_gas(2000000)]
fn constructor() {
    let (Manager, Rbits) = deploy_suite();
    assert(Rbits.name() == 'RabbitHoles', 'Incorrect name');
    assert(Rbits.symbol() == 'RBITS', 'Incorrect symbol');
    assert(Rbits.decimals() == 6_u8, 'Incorrect decimals');
    assert(Rbits.balance_of(Manager.owner()) == 123_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 123_u256, 'Incorrect supply');
    assert(Rbits.MANAGER_ADDRESS() == Manager.contract_address, 'Incorrect manager address');
    assert(Rbits.SUPPLY_PERMIT() == 'SUPPLY_PERMIT', 'Incorrect SUPPLY_PERMIT');
    assert(Rbits.MINT_PERMIT() == 'MINT_PERMIT', 'Incorrect MINT_PERMIT');
    assert(Rbits.BURN_PERMIT() == 'BURN_PERMIT', 'Incorrect BURN_PERMIT');
    assert(Rbits.is_burning() == true, 'Incorrect is_burning');
    assert(Rbits.is_minting() == true, 'Incorrect is_minting');
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
fn toggle_minting() {
    let (Manager, Rbits) = deploy_suite();
    assert(Rbits.is_minting() == true, 'Incorrect is_minting');
    Rbits.toggle_minting();
    assert(Rbits.is_minting() == false, 'Incorrect is_minting');
    Rbits.toggle_minting();
    assert(Rbits.is_minting() == true, 'Incorrect is_minting');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn toggle_minting_anon() {
    let (Manager, Rbits) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Rbits.toggle_minting();
}

#[test]
#[available_gas(2000000)]
fn toggle_minting_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let manager = contract_address_const::<'manager'>();
    Manager.set_permit(manager, Rbits.SUPPLY_PERMIT(), 1000000);
    set_contract_address(manager);
    Rbits.toggle_minting();
    assert(Rbits.is_minting() == false, 'Incorrect is_minting');
    Rbits.toggle_minting();
    assert(Rbits.is_minting() == true, 'Incorrect is_minting');
}

#[test]
#[available_gas(2000000)]
fn toggle_burning() {
    let (Manager, Rbits) = deploy_suite();
    assert(Rbits.is_burning() == true, 'Incorrect is_burning');
    Rbits.toggle_burning();
    assert(Rbits.is_burning() == false, 'Incorrect is_burning');
    Rbits.toggle_burning();
    assert(Rbits.is_burning() == true, 'Incorrect is_burning');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn toggle_burning_anon() {
    let (Manager, Rbits) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Rbits.toggle_burning();
}

#[test]
#[available_gas(2000000)]
fn toggle_burning_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let manager = contract_address_const::<'manager'>();
    Manager.set_permit(manager, Rbits.SUPPLY_PERMIT(), 1000000);
    set_contract_address(manager);
    Rbits.toggle_burning();
    assert(Rbits.is_burning() == false, 'Incorrect is_burning');
    Rbits.toggle_burning();
    assert(Rbits.is_burning() == true, 'Incorrect is_burning');
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
    let unlimited: u256 = BoundedInt::max();
    Rbits.approve(spender, unlimited);
    set_contract_address(spender);
    Rbits.transfer_from(Manager.owner(), recipient, 1_u256);
    assert(Rbits.allowance(Manager.owner(), spender) == unlimited, 'Incorrect allowance');
}

#[test]
#[available_gas(2000000)]
fn mint_as_owner() {
    let (Manager, Rbits) = deploy_suite();
    let recipient = contract_address_const::<222>();
    Rbits.mint(recipient, 1_u256);
    assert(Rbits.balance_of(recipient) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn mint_as_anon() {
    set_block_timestamp(12345);
    let (Manager, Rbits) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Rbits.mint(Manager.owner(), 1_u256);
}

#[test]
#[available_gas(2000000)]
fn sudo_mint_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let manager = contract_address_const::<'manager'>();
    let to = contract_address_const::<'to'>();
    Manager.set_permit(manager, Rbits.MINT_PERMIT(), 1000000);
    Rbits.mint(to, 1_u256);
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(4000000)]
fn mint_manager() {
    let (Manager, Rbits) = deploy_suite();
    let owner = Manager.owner();
    let manager = contract_address_const::<111>();
    let anon = contract_address_const::<'anon'>();
    let to = contract_address_const::<'to'>();
    /// give manager SUDO_MINT and MANANGER permits
    Manager.set_permit(manager, Manager.SUDO_PERMIT(), 1000000);
    Manager.set_permit(manager, 'SUDO_MINT', 1000000);
    /// Manager binds MINT permit to SUDO_MINT permit
    set_contract_address(manager);
    Manager.set_sudo_permit(Rbits.MINT_PERMIT(), 'SUDO_MINT');
    /// Manager sets SUDO_MINT permit for anon
    set_contract_address(manager);
    Manager.set_permit(anon, Rbits.MINT_PERMIT(), 1000000);
    set_contract_address(anon);
    /// Anon has MINT permit, granted by a manager
    Rbits.mint(to, 1_u256);
    assert(Rbits.balance_of(to) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 124_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(3000000)]
fn burn_as_owner() {
    let (Manager, Rbits) = deploy_suite();
    let user = contract_address_const::<'user'>();
    /// owner gives user tokens
    Rbits.transfer(user, 2_u256);
    /// user gives owner alloance
    set_contract_address(user);
    Rbits.approve(Manager.owner(), 1_u256);
    /// owner can burn user's tokens
    set_contract_address(Manager.owner());
    Rbits.burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('ERC20: invalid permit', 'ENTRYPOINT_FAILED'))]
fn burn_as_anon() {
    let (Manager, Rbits) = deploy_suite();
    let user = contract_address_const::<'user'>();
    let anon = contract_address_const::<'anon'>();
    /// owner gives user tokens
    Rbits.transfer(user, 2_u256);
    set_contract_address(user);
    /// user approves anon to spend tokens
    Rbits.approve(Manager.owner(), 1_u256);
    /// anon cannot burn because they do not have the BURN permit
    set_contract_address(anon);
    Rbits.burn(user, 1_u256);
}

#[test]
#[available_gas(3000000)]
fn burn_with_permit() {
    let (Manager, Rbits) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let user = contract_address_const::<'user'>();
    /// owner gives tokens to user
    Rbits.transfer(user, 2_u256);
    /// user approves anon to spend tokens
    set_contract_address(user);
    Rbits.approve(anon, 1_u256);
    /// owner gives anon BURN permit
    set_contract_address(Manager.owner());
    Manager.set_permit(anon, Rbits.BURN_PERMIT(), 1000000);
    /// anon can burn tokens
    set_contract_address(anon);
    Rbits.burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}

#[test]
#[available_gas(8000000)]
fn burn_as_manager() {
    let (Manager, Rbits) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let manager0 = contract_address_const::<'manager0'>();
    let manager = contract_address_const::<'manager'>();
    let user = contract_address_const::<'user'>();
    /// owner gives tokens to user
    Rbits.transfer(user, 2_u256);
    /// owner gives manager0 SUDO permit
    set_contract_address(Manager.owner());
    Manager.set_permit(manager0, Manager.SUDO_PERMIT(), 1000000);
    Manager.set_permit(manager0, 'SUDO_BURN_MANAGER', 1000000);
    /// user approves anon to spend tokens
    set_contract_address(user);
    Rbits.approve(anon, 1_u256);
    /// owner gives manager0 SUDO permit
    set_contract_address(Manager.owner());
    Manager.set_permit(manager0, Manager.SUDO_PERMIT(), 1000000);
    Manager.set_permit(manager0, 'SUDO_BURN', 1000000);
    /// manager0 binds BURN to SUDO_BURN
    set_contract_address(manager0);
    Manager.set_sudo_permit(Rbits.BURN_PERMIT(), 'SUDO_BURN');
    Manager.set_sudo_permit('SUDO_BURN', 'SUDO_BURN_MANAGER');
    /// manager0 grants BURN_MANAGER permit to manager
    Manager.set_permit(manager, 'SUDO_BURN', 1000000);
    /// manager gives anon BURN permit
    set_contract_address(manager);
    Manager.set_permit(anon, Rbits.BURN_PERMIT(), 1000000);
    /// anon can burn tokens
    set_contract_address(anon);
    Rbits.burn(user, 1_u256);
    assert(Rbits.balance_of(Manager.owner()) == 121_u256, 'Incorrect balance');
    assert(Rbits.balance_of(user) == 1_u256, 'Incorrect balance');
    assert(Rbits.total_supply() == 122_u256, 'Incorrect total supply');
}
