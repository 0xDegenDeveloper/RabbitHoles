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
    let owner =
        contract_address_const::<0x00a138A07fde4cD66998e544665dd322E14AAC17279c6477E63f394a07476001>();
    let mut calldata = ArrayTrait::new();
    set_contract_address(owner);
    calldata.append(owner.into());

    'manager arg'.print();
    let f: felt252 = owner.into();
    f.print();

    let (manager_address, _) = deploy_syscall(
        Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();

    'rbits args'.print();
    let m: felt252 =
        contract_address_const::<0x026a60f9b16975e44c11550c2baff45ac4c52d399cdccab5532dccc73ffa3298>()
        .into();
    m.print();
    'RabbitHoles'.print();
    'RBITS'.print();
    6_u8.print();
    'u256 next'.print();
    1000000000_u128.print();
    0_u128.print();
    'receiver'.print();
    owner.print();

    calldata.append(manager_address.into());
    calldata.append('RabbitHoles');
    calldata.append('RBITS');
    calldata.append(6_u8.into());
    calldata.append(1000000000_u128.into());
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
    'registry args'.print();
    m.print();
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
    calldata.append(2000000000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());

    let (dig_token_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    calldata = ArrayTrait::new();
    'v1 args'.print();
    'manager_address'.print();
    m.print();
    'rbits_address'.print();
    contract_address_const::<0x06a3e59fce87072a652e7d67df0782e89b337b65ff50f1d8553e990dd3c95cef>()
        .print();
    'registry_address'.print();
    contract_address_const::<0x026377bcc9b973eae8500eca7f916e42a645ffd4b15146e62b69e57e958502fc>()
        .print();
    'goerli_eth_address'.print();
    contract_address_const::<0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7>()
        .print();
    'digger_bps'.print();
    5000.print();
    'dig_fee'.print();
    10000000_u128.print();
    0_u128.print();
    'dig_reward'.print();
    20000000_u128.print();
    0_u128.print();

    calldata.append(manager_address.into());
    calldata.append(rbits_address.into());
    calldata.append(registry_address.into());
    calldata.append(dig_token_address.into());
    calldata.append(5000_u16.into());
    calldata.append(10000000_u128.into());
    calldata.append(0_u128.into());
    calldata.append(20000000_u128.into());
    calldata.append(0_u128.into());

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
#[available_gas(16000000)]
fn constructor() {
    let (Manager, Rbits, Registry, V1, DigToken) = deploy_suite();

    'permits'.print();
    'MINT_PERMIT'.print();
    'BURN_PERMIT'.print();
    'CREATE_HOLE_PERMIT'.print();
    'CREATE_RABBIT_PERMIT'.print();
}
