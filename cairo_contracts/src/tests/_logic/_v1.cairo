use array::ArrayTrait;
use clone::Clone;
use debug::PrintTrait;
use option::OptionTrait;
use rabbitholes::{
    core::{
        manager::{Manager, IManager, IManagerDispatcherTrait, IManagerDispatcher},
        erc20::{ERC20, IERC20, IERC20DispatcherTrait, IERC20Dispatcher},
        registry::{Registry, IRegistry, IRegistryDispatcherTrait, IRegistryDispatcher},
    },
    logic::{
        v1::{
            RabbitholesV1, IRabbitholesV1, IRabbitholesV1DispatcherTrait, IRabbitholesV1Dispatcher
        },
    },
    tests::_core::{_registry::{get_rabbit}}
};
use result::ResultTrait;
use starknet::{
    testing::{set_caller_address, set_contract_address, set_block_timestamp},
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    contract_address_const, get_caller_address
};
use traits::{Into, TryInto};

/// helper
fn deploy_suite() -> (
    IManagerDispatcher,
    IERC20Dispatcher,
    IRegistryDispatcher,
    IRabbitholesV1Dispatcher,
    IERC20Dispatcher
) {
    let owner = contract_address_const::<'owner'>();
    let mut calldata = ArrayTrait::new();
    set_contract_address(owner);
    calldata.append(owner.into());

    let (manager_address, _) = deploy_syscall(
        Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();
    calldata.append(manager_address.into());
    calldata.append('RabbitHoles');
    calldata.append('RBITS');
    calldata.append(6_u8.into());
    calldata.append(1000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());

    let (rbits_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    let irbits = IERC20Dispatcher { contract_address: rbits_address };

    irbits.toggle_burning();
    irbits.toggle_minting();

    calldata = ArrayTrait::new();
    calldata.append(manager_address.into());

    let (registry_address, _) = deploy_syscall(
        Registry::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    let iregistry = IRegistryDispatcher { contract_address: registry_address };

    iregistry.toggle_hole_creation();
    iregistry.toggle_rabbit_creation();

    calldata = ArrayTrait::new();
    calldata.append(manager_address.into());
    calldata.append('Test');
    calldata.append('TST');
    calldata.append(6_u8.into());
    calldata.append(2000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());

    let (dig_token_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();
    calldata.append(manager_address.into());
    calldata.append(rbits_address.into());
    calldata.append(registry_address.into());
    calldata.append(dig_token_address.into());
    calldata.append(10_u128.into());
    calldata.append(0_u128.into());
    calldata.append(20_u128.into());
    calldata.append(0_u128.into());
    calldata.append(5000_u16.into());

    let (v1_address, _) = deploy_syscall(
        RabbitholesV1::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    (
        IManagerDispatcher {
            contract_address: manager_address
            }, irbits, iregistry, IRabbitholesV1Dispatcher {
            contract_address: v1_address
            }, IERC20Dispatcher {
            contract_address: dig_token_address
        }
    )
}

/// tests
#[test]
#[available_gas(4000000)]
fn constructor() {
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    assert(V1.TOGGLE_DIGGING_PERMIT() == 'TOGGLE_DIGGING_PERMIT', 'Wrong TOGGLE_DIGGING_PERMIT');
    assert(V1.TOGGLE_BURNING_PERMIT() == 'TOGGLE_BURNING_PERMIT', 'Wrong TOGGLE_BURNING_PERMIT');
    assert(V1.SET_DIG_FEE_PERRMIT() == 'SET_DIG_FEE_PERRMIT', 'Wrong SET_DIG_FEE_PERRMIT');
    assert(V1.SET_DIG_REWARD_PERRMIT() == 'SET_DIG_REWARD_PERRMIT', 'Wrong SET_DIG_REWARD_PERRMIT');
    assert(V1.SET_DIG_TOKEN_PERMIT() == 'SET_DIG_TOKEN_PERMIT', 'Wrong SET_DIG_TOKEN_PERMIT');
    assert(V1.WITHDRAW_PERMIT() == 'WITHDRAW_PERMIT', 'Wrong WITHDRAW_PERMIT');
    assert(V1.MANAGER_ADDRESS() == Manager.contract_address, 'Wrong MANAGER_ADDRESS');
    assert(V1.RBITS_ADDRESS() == Rbits.contract_address, 'Wrong RBITS_ADDRESS');
    assert(V1.REGISTRY_ADDRESS() == Registry.contract_address, 'Wrong REGISTRY_ADDRESS');
    assert(V1.dig_token_address() == DigToken.contract_address, 'Wrong dig_token_address');
    assert(V1.dig_fee() == 10, 'Wrong dig_fee');
    assert(V1.dig_reward() == 20, 'Wrong dig_reward');
    assert(V1.digger_bps() == 5000, 'Wrong digger_bps');
}

/// sudo
#[test]
#[available_gas(8000000)]
fn sudo_functions_as_owner() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    assert(V1.is_digging() == false, 'Wrong is_digging');
    assert(V1.is_burning() == false, 'Wrong is_burning');
    assert(V1.dig_fee() == 10, 'Wrong dig_fee');
    assert(V1.dig_reward() == 20, 'Wrong dig_reward');
    assert(V1.dig_token_address() == DigToken.contract_address, 'Wrong dig_token_address');
    assert(V1.digger_bps() == 5000, 'Wrong digger_bps');
    V1.toggle_digging();
    V1.toggle_burning();
    V1.set_dig_fee(111);
    V1.set_dig_reward(222);
    V1.set_dig_token(Rbits.contract_address);
    V1.set_digger_bps(666);
    Rbits.transfer(V1.contract_address, 333);
    assert(Rbits.balance_of(V1.contract_address) == 333, 'Wrong Rbits balance');
    V1.withdraw(333, anon);
    assert(V1.is_digging() == true, 'Wrong is_digging');
    assert(V1.is_burning() == true, 'Wrong is_burning');
    assert(V1.dig_fee() == 111, 'Wrong dig_fee');
    assert(V1.dig_reward() == 222, 'Wrong dig_reward');
    assert(V1.dig_token_address() == Rbits.contract_address, 'Wrong dig_token_address');
    assert(V1.digger_bps() == 666, 'Wrong digger_bps');
    assert(Rbits.balance_of(anon) == 333, 'Wrong anon balance');
    assert(Rbits.balance_of(V1.contract_address) == 0, 'Wrong Rbits balance');
}

#[test]
#[available_gas(10000000)]
fn sudo_functions_with_permit() {
    let anon = contract_address_const::<'anon'>();
    let manager = contract_address_const::<'manager'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    assert(V1.is_digging() == false, 'Wrong is_digging');
    assert(V1.is_burning() == false, 'Wrong is_burning');
    assert(V1.dig_fee() == 10, 'Wrong dig_fee');
    assert(V1.dig_reward() == 20, 'Wrong dig_reward');
    assert(V1.dig_token_address() == DigToken.contract_address, 'Wrong dig_token_address');
    assert(V1.digger_bps() == 5000, 'Wrong digger_bps');
    Manager.set_permit(manager, V1.TOGGLE_DIGGING_PERMIT(), 123);
    Manager.set_permit(manager, V1.TOGGLE_BURNING_PERMIT(), 123);
    Manager.set_permit(manager, V1.SET_DIG_FEE_PERRMIT(), 123);
    Manager.set_permit(manager, V1.SET_DIG_REWARD_PERRMIT(), 123);
    Manager.set_permit(manager, V1.SET_DIG_TOKEN_PERMIT(), 123);
    Manager.set_permit(manager, V1.SET_DIGGER_BPS_PERMIT(), 123);
    Manager.set_permit(manager, V1.WITHDRAW_PERMIT(), 123);
    Rbits.transfer(V1.contract_address, 333);
    set_contract_address(manager);
    V1.toggle_digging();
    V1.toggle_burning();
    V1.set_dig_fee(111);
    V1.set_dig_reward(222);
    V1.set_dig_token(Rbits.contract_address);
    V1.set_digger_bps(666);
    assert(Rbits.balance_of(V1.contract_address) == 333, 'Wrong Rbits balance');
    V1.withdraw(333, anon);
    assert(V1.is_digging() == true, 'Wrong is_digging');
    assert(V1.is_burning() == true, 'Wrong is_burning');
    assert(V1.dig_fee() == 111, 'Wrong dig_fee');
    assert(V1.dig_reward() == 222, 'Wrong dig_reward');
    assert(V1.dig_token_address() == Rbits.contract_address, 'Wrong dig_token_address');
    assert(V1.digger_bps() == 666, 'Wrong digger_bps');
    assert(Rbits.balance_of(anon) == 333, 'Wrong anon balance');
    assert(Rbits.balance_of(V1.contract_address) == 0, 'Wrong Rbits balance');
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_toggle_burning() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.toggle_digging();
}
#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_toggle_digging() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.toggle_burning();
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_set_dig_fee() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.set_dig_fee(111);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_set_dig_reward() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.set_dig_reward(222);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_set_dig_token() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.set_dig_token(Rbits.contract_address);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_set_digger_bps() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.set_digger_bps(666);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Rabbitholes: invalid permit', 'ENTRYPOINT_FAILED'))]
fn sudo_no_permit_withdraw() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    set_contract_address(anon);
    V1.withdraw(333, anon);
}

#[test]
#[available_gas(8000000)]
fn dig_hole() {
    let anon = contract_address_const::<'anon'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    Manager.set_permit(V1.contract_address, Registry.CREATE_HOLE_PERMIT(), 123);
    Manager.set_permit(V1.contract_address, Rbits.MINT_PERMIT(), 123);
    DigToken.transfer(anon, 100);
    V1.toggle_digging();
    set_contract_address(anon);
    DigToken.approve(V1.contract_address, 100);
    assert(DigToken.balance_of(anon) == 100, 'Wrong DigToken balance0');
    assert(Rbits.balance_of(anon) == 0, 'Wrong Rbits balance0');
    V1.dig_hole('title');
    assert(DigToken.balance_of(anon) == 90, 'Wrong DigToken balance');
    assert(Rbits.balance_of(anon) == 20, 'Wrong Rbits balance');
    assert(DigToken.balance_of(V1.contract_address) == 10, 'Wrong V1 balance');
    let mut ids = ArrayTrait::<ContractAddress>::new();
    ids.append(anon);
    assert(*Registry.get_user_stats(ids).at(0).holes == 1, 'Wrong hole id');
}

#[test]
#[available_gas(10000000)]
fn burn_rabbit() {
    let anon = contract_address_const::<'anon'>();
    let digger = contract_address_const::<'digger'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    Manager.set_permit(V1.contract_address, Registry.CREATE_RABBIT_PERMIT(), 123);
    Manager.set_permit(V1.contract_address, Rbits.BURN_PERMIT(), 123);
    Registry.create_hole('title', digger);
    V1.toggle_burning();
    Rbits.transfer(anon, 100);
    set_contract_address(anon);
    Rbits.approve(V1.contract_address, 100);
    assert(Rbits.balance_of(anon) == 100, 'Wrong Rbits balance0');
    let mut msg = ArrayTrait::<felt252>::new();
    msg.append('hello');
    msg.append('world');
    V1.burn_rabbit(msg, 1);
    assert(Rbits.balance_of(anon) == 98, 'Wrong Rbits anon balance');
    assert(Rbits.balance_of(digger) == 1, 'Wrong digger balance');
    let mut ids = ArrayTrait::<ContractAddress>::new();
    ids.append(anon);
    ids.append(digger);
    let stats = Registry.get_user_stats(ids);
    let stats_anon = *stats.at(0);
    let stats_digger = *stats.at(1);
    assert(stats_digger.holes == 1, 'Wrong hole id');
    assert(stats_anon.rabbits == 1, 'Wrong rabbit id');
    assert(stats_anon.depth == 2, 'Wrong depth');
}

#[test]
#[available_gas(32000000)]
fn burn_rabbit_intense() {
    let anon = contract_address_const::<'anon'>();
    let digger = contract_address_const::<'digger'>();
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    Manager.set_permit(V1.contract_address, Registry.CREATE_RABBIT_PERMIT(), 123);
    Manager.set_permit(V1.contract_address, Rbits.BURN_PERMIT(), 123);
    Registry.create_hole('title', digger);
    V1.toggle_burning();
    V1.set_digger_bps(3333);
    Rbits.transfer(anon, 100);
    set_contract_address(anon);
    Rbits.approve(V1.contract_address, 100);
    assert(Rbits.balance_of(anon) == 100, 'Wrong Rbits balance0');
    let mut msg = ArrayTrait::<felt252>::new();
    /// 20x
    {
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
        msg.append('hi');
    };
    V1.burn_rabbit(msg, 1);
    assert(Rbits.balance_of(anon) == 80, 'Wrong Rbits anon balance');
    assert(Rbits.balance_of(digger) == 6, 'Wrong digger balance');
    let mut ids = ArrayTrait::<ContractAddress>::new();
    ids.append(anon);
    ids.append(digger);
    let stats = Registry.get_user_stats(ids);
    let stats_anon = *stats.at(0);
    let stats_digger = *stats.at(1);
    let mut ids = ArrayTrait::<u64>::new();
    ids.append(1);
    let hole = *Registry.get_holes(ids.clone()).at(0);
    let rabbit = get_rabbit(Registry, 1);
    assert(hole.depth == 20, 'Wrong depth');
    assert(hole.digs == 1, 'Wrong # of digs');
    assert(rabbit.burner == anon, 'Wrong burner');
    let m = rabbit.msg;
    assert(m.len() == 20, 'Wrong msg len');
    let mut i = 0_u32;
    loop {
        if (i >= 20) {
            break ();
        }
        assert(*m.at(i) == 'hi', 'Wrong msg chunk');
        i += 1;
    };
    assert(stats_digger.holes == 1, 'Wrong hole id');
    assert(stats_anon.rabbits == 1, 'Wrong rabbit id');
    assert(stats_anon.depth == 20, 'Wrong depth');
}

