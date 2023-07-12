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
    tests::_core::_manager::{_set_permit_from_for}
};
use result::ResultTrait;
use starknet::{
    testing::{set_caller_address, set_contract_address, set_block_timestamp},
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    contract_address_const, get_caller_address
};
use traits::{Into, TryInto};

/// Helpers
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
    calldata.append('RabbitHoles');
    calldata.append('RBITS');
    calldata.append(6_u8.into());
    calldata.append(1000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());
    calldata.append(manager_address.into());

    let (rbits_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();
    calldata.append(manager_address.into());

    let (registry_address, _) = deploy_syscall(
        Registry::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();
    calldata.append('Test');
    calldata.append('TST');
    calldata.append(6_u8.into());
    calldata.append(2000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());
    calldata.append(manager_address.into());

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
            }, IERC20Dispatcher {
            contract_address: rbits_address
            }, IRegistryDispatcher {
            contract_address: registry_address
            }, IRabbitholesV1Dispatcher {
            contract_address: v1_address
            }, IERC20Dispatcher {
            contract_address: dig_token_address
        }
    )
}

/// Tests
#[test]
#[available_gas(2000000)]
fn constructor() {
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();
    /// Permits
    assert(V1.TOGGLE_DIGGING_PERMIT() == 'TOGGLE_DIGGING_PERMIT', 'Wrong TOGGLE_DIGGING_PERMIT');
    assert(V1.TOGGLE_BURNING_PERMIT() == 'TOGGLE_BURNING_PERMIT', 'Wrong TOGGLE_BURNING_PERMIT');
    assert(V1.SET_DIG_FEE_PERRMIT() == 'SET_DIG_FEE_PERRMIT', 'Wrong SET_DIG_FEE_PERRMIT');
    assert(V1.SET_DIG_REWARD_PERRMIT() == 'SET_DIG_REWARD_PERRMIT', 'Wrong SET_DIG_REWARD_PERRMIT');
    assert(V1.SET_DIG_TOKEN_PERMIT() == 'SET_DIG_TOKEN_PERMIT', 'Wrong SET_DIG_TOKEN_PERMIT');
    /// Suite addresses
    assert(V1.MANAGER_ADDRESS() == Manager.contract_address, 'Wrong MANAGER_ADDRESS');
    assert(V1.RBITS_ADDRESS() == Rbits.contract_address, 'Wrong RBITS_ADDRESS');
    assert(V1.REGISTRY_ADDRESS() == Registry.contract_address, 'Wrong REGISTRY_ADDRESS');
    /// Params
    assert(V1.dig_token_address() == DigToken.contract_address, 'Wrong dig_token_address');
    assert(V1.dig_fee() == 10, 'Wrong dig_fee');
    assert(V1.dig_reward() == 20, 'Wrong dig_reward');
    assert(V1.digger_bps() == 5000, 'Wrong digger_bps');
}

/// Sudo

#[test]
#[available_gas(2000000)]
fn sudo_functions_as_owner() {
    let x = 0;
/// test all toggles/setters as owner
}

#[test]
#[available_gas(2000000)]
fn sudo_functions_with_permit() {
    let x = 0;
/// test all toggles/setters as manager
}

#[test]
#[available_gas(2000000)]
fn sudo_functions_no_permit() {
    let x = 0;
/// test all toggles/setters as anon (might need more tests for this)
}

/// Digging

#[test]
#[available_gas(2000000)]
fn dig_hole() {
    let x = 0;
/// test fee taken 
/// test reward minted
}

#[test]
#[available_gas(2000000)]
// #[should_panic(expected: ('xxx', 'ENTRYPOINT_FAILED'))]
fn dig_hole_no_approval() {}
/// Burning

/// burn_rabbit 
/// burn_rabbit_no_rbits 


