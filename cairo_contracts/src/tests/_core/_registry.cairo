use array::ArrayTrait;
use clone::Clone;
use debug::PrintTrait;
use option::OptionTrait;
use rabbitholes::{
    core::{
        manager::{Manager, IManager, IManagerDispatcherTrait, IManagerDispatcher},
        erc20::{ERC20, IERC20, IERC20DispatcherTrait, IERC20Dispatcher},
        registry::{Registry, IRegistry, IRegistryDispatcherTrait, IRegistryDispatcher}
    },
};
use result::ResultTrait;
use starknet::{
    testing::{set_caller_address, set_contract_address, set_block_timestamp},
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    contract_address_const, get_caller_address
};
use traits::{Into, TryInto};

/// helpers
fn deploy_suite() -> (IManagerDispatcher, IERC20Dispatcher, IRegistryDispatcher) {
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
    calldata.append(123_u128.into());
    calldata.append(0_u128.into());
    calldata.append(owner.into());

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

    let iregistry = IRegistryDispatcher { contract_address: registry_address };

    iregistry.toggle_hole_creation();
    iregistry.toggle_rabbit_creation();

    (
        IManagerDispatcher {
            contract_address: manager_address
            }, IERC20Dispatcher {
            contract_address: rbits_address
        }, iregistry
    )
}

fn get_rabbit(Registry: IRegistryDispatcher, id: u64) -> Registry::RabbitHot {
    let mut ids = ArrayTrait::<u64>::new();
    ids.append(id);
    let r = Registry.get_rabbits(ids);
    Registry::RabbitHot {
        burner: *r.at(0).burner,
        hole_id: *r.at(0).hole_id,
        msg: r.at(0).msg.clone(),
        timestamp: *r.at(0).timestamp,
        index: id
    }
}

fn get_hole(Registry: IRegistryDispatcher, id: u64) -> Registry::Hole {
    let mut ids = ArrayTrait::<u64>::new();
    ids.append(id);
    let r = Registry.get_holes(ids);
    Registry::Hole {
        digger: *r.at(0).digger,
        title: r.at(0).title.clone(),
        timestamp: *r.at(0).timestamp,
        digs: *r.at(0).digs,
        depth: *r.at(0).depth,
        index: id
    }
}

/// testers
fn test_rabbit(
    Registry: IRegistryDispatcher,
    id: u64,
    burner: ContractAddress,
    msg: Array<felt252>,
    hole_id: u64,
    timestamp: u64,
    index: u64,
) {
    let rabbit = get_rabbit(Registry, id);
    assert(rabbit.burner == burner, 'Incorrect burner');
    assert(rabbit.hole_id == hole_id, 'Incorrect hole_id');
    assert(rabbit.timestamp == timestamp, 'Incorrect timestamp');
    assert(rabbit.index == index, 'Incorrect index');
    let len = rabbit.msg.clone().len();
    assert(len == msg.len(), 'Incorrect msg length');
    let mut i = 0;
    loop {
        if (i >= len) {
            break ();
        }
        assert(*rabbit.msg.clone().at(i) == *msg.at(i), 'Incorrect msg chunk');
        i += 1;
    };
}

fn test_hole(
    Registry: IRegistryDispatcher,
    id: u64,
    digger: ContractAddress,
    title: felt252,
    timestamp: u64,
    digs: u64,
    depth: u64,
) {
    let hole = get_hole(Registry, id);
    assert(hole.digger == digger, 'Incorrect digger');
    assert(hole.title == title, 'Incorrect title');
    assert(hole.timestamp == timestamp, 'Incorrect timestamp');
    assert(hole.digs == digs, 'Incorrect digs');
    assert(hole.depth == depth, 'Incorrect depth');
    assert(hole.index == id, 'Incorrect index');
    assert(Registry.title_to_id(title) == id, 'Incorrect hole id');
}

/// tests
#[test]
#[available_gas(8000000)]
fn constructor() {
    let (Manager, Rbits, Registry) = deploy_suite();
    assert(Registry.MANAGER_ADDRESS() == Manager.contract_address, 'Incorrect manager address');
    assert(Registry.CREATE_HOLE_PERMIT() == 'CREATE_HOLE_PERMIT', 'Incorrect CREATE_HOLE_PERMIT');
    assert(
        Registry.CREATE_RABBIT_PERMIT() == 'CREATE_RABBIT_PERMIT', 'Incorrect CREATE_RABBIT_PERMIT'
    );
    assert(
        Registry.TOGGLE_CREATE_PERMIT() == 'TOGGLE_CREATE_PERMIT', 'Incorrect TOGGLE_CREATE_PERMIT'
    );
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Registry: invalid permit', 'ENTRYPOINT_FAILED'))]
fn create_hole_no_permit() {
    let (Manager, Rbits, Registry) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Registry.create_hole('title', Manager.owner());
}

#[test]
#[available_gas(4000000)]
fn create_hole_with_permit() {
    let (Manager, Rbits, Registry) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    Manager.set_permit(anon, Registry.CREATE_HOLE_PERMIT(), 111);
    set_contract_address(anon);
    set_block_timestamp(110);
    Registry.create_hole('title', Rbits.contract_address);
    test_hole(Registry, 1, Rbits.contract_address, 'title', 110, 0, 0);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Registry: invalid permit', 'ENTRYPOINT_FAILED'))]
fn create_rabbit_no_permit() {
    let (Manager, Rbits, Registry) = deploy_suite();
    Registry.create_hole('title', Manager.owner());
    set_contract_address(contract_address_const::<'anon'>());
    let msg = ArrayTrait::<felt252>::new();
    Registry.create_rabbit(Manager.owner(), msg, 1);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Registry: invalid hole id', 'ENTRYPOINT_FAILED'))]
fn create_rabbit_no_hole() {
    let (Manager, Rbits, Registry) = deploy_suite();
    Registry.create_hole('title', Manager.owner());
    let msg = ArrayTrait::<felt252>::new();
    Registry.create_rabbit(Manager.owner(), msg, 2);
}

#[test]
#[available_gas(4000000)]
#[should_panic(expected: ('Registry: invalid hole id', 'ENTRYPOINT_FAILED'))]
fn create_rabbit_zero_hole() {
    let (Manager, Rbits, Registry) = deploy_suite();
    let msg = ArrayTrait::<felt252>::new();
    Registry.create_rabbit(Manager.owner(), msg, 0);
}


#[test]
#[available_gas(16000000)]
fn create_holes() {
    let (Manager, Rbits, Registry) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let anon2 = contract_address_const::<'anon2'>();
    let anon3 = contract_address_const::<'anon3'>();
    /// create holes
    set_block_timestamp(111);
    Registry.create_hole('title', anon);
    set_block_timestamp(222);
    Registry.create_hole('title2', anon);
    set_block_timestamp(333);
    Registry.create_hole('title3', anon2);
    Registry.create_hole('title4', anon2);
    set_block_timestamp(444);
    Registry.create_hole('title5', anon3);
    Registry.create_hole('title6', anon3);
    Registry.create_hole('title7', anon3);
    /// test holes
    test_hole(Registry, 1, anon, 'title', 111, 0, 0);
    test_hole(Registry, 2, anon, 'title2', 222, 0, 0);
    test_hole(Registry, 3, anon2, 'title3', 333, 0, 0);
    test_hole(Registry, 4, anon2, 'title4', 333, 0, 0);
    test_hole(Registry, 5, anon3, 'title5', 444, 0, 0);
    test_hole(Registry, 6, anon3, 'title6', 444, 0, 0);
    test_hole(Registry, 7, anon3, 'title7', 444, 0, 0);
    /// test (global) stats
    let stats = Registry.get_global_stats();
    assert(stats.holes == 7, 'Incorrect holes count');
    assert(stats.rabbits == 0, 'Incorrect rabbits count');
    assert(stats.depth == 0, 'Incorrect depth');
    /// test user stats
    let mut a = ArrayTrait::<ContractAddress>::new();
    a.append(anon);
    a.append(anon2);
    a.append(anon3);
    let sss = Registry.get_user_stats(a);
    let user_stats = *sss.at(0);
    let user_stats2 = *sss.at(1);
    let user_stats3 = *sss.at(2);

    assert(user_stats.holes == 2, 'Incorrect holes count');
    assert(user_stats.rabbits == 0, 'Incorrect rabbits count');
    assert(user_stats.depth == 0, 'Incorrect depth');

    assert(user_stats2.holes == 2, 'Incorrect holes count');
    assert(user_stats2.rabbits == 0, 'Incorrect rabbits count');
    assert(user_stats2.depth == 0, 'Incorrect depth');

    assert(user_stats3.holes == 3, 'Incorrect holes count');
    assert(user_stats3.rabbits == 0, 'Incorrect rabbits count');
    assert(user_stats3.depth == 0, 'Incorrect depth');
    /// test user holes table
    let mut indexes = ArrayTrait::<u64>::new();
    indexes.append(1);
    indexes.append(2);
    let holes = Registry.get_user_holes(anon, indexes);
    assert(holes.len() == 2, 'Incorrect holes count');
    assert(*holes.at(0).title == 'title', 'Incorrect hole title');
    assert(*holes.at(1).title == 'title2', 'Incorrect hole title');
    assert(*holes.at(0).index == 1, 'Incorrect hole index');
    assert(*holes.at(1).index == 2, 'Incorrect hole index');
}


#[test]
#[available_gas(640000000)]
fn create_rabbits() {
    let (Manager, Rbits, Registry) = deploy_suite();
    let anon = contract_address_const::<'anon'>();
    let anon2 = contract_address_const::<'anon2'>();
    let anon3 = contract_address_const::<'anon3'>();
    let burner = contract_address_const::<'burner'>();
    let burner2 = contract_address_const::<'burner2'>();
    let burner3 = contract_address_const::<'burner3'>();
    /// create holes
    Registry.create_hole('title', anon);
    Registry.create_hole('title2', anon2);
    Registry.create_hole('title3', anon3);
    Registry.create_hole('title4', anon3);
    /// create rabbits
    let mut m1 = ArrayTrait::<felt252>::new();
    let mut m2 = ArrayTrait::<felt252>::new();
    let mut m3 = ArrayTrait::<felt252>::new();
    let mut m4 = ArrayTrait::<felt252>::new();
    m1.append('hello'); // len 1
    m2.append('world'); // len 1
    m3.append('this');
    m3.append('is'); // len 2
    m4.append('a');
    m4.append('test'); // len 2
    set_block_timestamp(111); //                   // depth -> hole_id
    Registry.create_rabbit(burner, m1.clone(), 1); // 1 -> 1
    Registry.create_rabbit(burner2, m1.clone(), 2); // 1 -> 2
    Registry.create_rabbit(burner3, m1.clone(), 3); // 1 -> 3
    Registry.create_rabbit(burner3, m1.clone(), 4); // 1 -> 4
    set_block_timestamp(222);
    Registry.create_rabbit(burner, m2.clone(), 1); // 1 -> 1
    Registry.create_rabbit(burner2, m2.clone(), 2); // 1 -> 2
    Registry.create_rabbit(burner3, m2.clone(), 3); // 1 -> 3
    Registry.create_rabbit(burner3, m2.clone(), 4); // 1 -> 4
    set_block_timestamp(333);
    Registry.create_rabbit(burner, m3.clone(), 2); // 2 -> 2
    Registry.create_rabbit(burner2, m3.clone(), 1); // 2 -> 1
    Registry.create_rabbit(burner3, m3.clone(), 3); // 2 -> 3
    Registry.create_rabbit(burner3, m3.clone(), 4); // 2 -> 4
    set_block_timestamp(444);
    Registry.create_rabbit(burner, m4.clone(), 2); // 2 -> 2 
    Registry.create_rabbit(burner2, m4.clone(), 1); // 2 -> 1
    Registry.create_rabbit(burner3, m4.clone(), 3); // 2 -> 3       
    Registry.create_rabbit(burner3, m4.clone(), 4); // 2 -> 4
    /// test rabbits 
    test_rabbit(Registry, 1, burner, m1.clone(), 1, 111, 1);
    test_rabbit(Registry, 2, burner2, m1.clone(), 2, 111, 2);
    test_rabbit(Registry, 3, burner3, m1.clone(), 3, 111, 3);
    test_rabbit(Registry, 4, burner3, m1.clone(), 4, 111, 4);

    test_rabbit(Registry, 5, burner, m2.clone(), 1, 222, 5);
    test_rabbit(Registry, 6, burner2, m2.clone(), 2, 222, 6);
    test_rabbit(Registry, 7, burner3, m2.clone(), 3, 222, 7);
    test_rabbit(Registry, 8, burner3, m2.clone(), 4, 222, 8);

    test_rabbit(Registry, 9, burner, m3.clone(), 2, 333, 9);
    test_rabbit(Registry, 10, burner2, m3.clone(), 1, 333, 10);
    test_rabbit(Registry, 11, burner3, m3.clone(), 3, 333, 11);
    test_rabbit(Registry, 12, burner3, m3.clone(), 4, 333, 12);

    test_rabbit(Registry, 13, burner, m4.clone(), 2, 444, 13);
    test_rabbit(Registry, 14, burner2, m4.clone(), 1, 444, 14);
    test_rabbit(Registry, 15, burner3, m4.clone(), 3, 444, 15);
    test_rabbit(Registry, 16, burner3, m4.clone(), 4, 444, 16);

    /// test (global) stats
    let stats = Registry.get_global_stats();
    assert(stats.holes == 4, 'Incorrect holes count');
    assert(stats.rabbits == 16, 'Incorrect rabbits count');
    assert(stats.depth == 24, 'Incorrect depth');
    /// test user stats 
    let mut a = ArrayTrait::<ContractAddress>::new();
    a.append(burner);
    a.append(burner2);
    a.append(burner3);
    let sss = Registry.get_user_stats(a);
    let user_stats = *sss.at(0);
    let user_stats2 = *sss.at(1);
    let user_stats3 = *sss.at(2);
    assert(user_stats.holes == 0, 'Incorrect holes count');
    assert(user_stats2.holes == 0, 'Incorrect holes count');
    assert(user_stats3.holes == 0, 'Incorrect holes count');

    assert(user_stats.rabbits == 4, 'Incorrect rabbits count');
    assert(user_stats2.rabbits == 4, 'Incorrect rabbits count');
    assert(user_stats3.rabbits == 8, 'Incorrect rabbits count');

    assert(user_stats.depth == 6, 'Incorrect depth');
    assert(user_stats2.depth == 6, 'Incorrect depth');
    assert(user_stats3.depth == 12, 'Incorrect depth');
    /// test user rabbits table
    let mut indexes = ArrayTrait::<u64>::new();
    indexes.append(1);
    indexes.append(2);
    indexes.append(3);
    indexes.append(4);
    let rabbits = Registry.get_user_rabbits(burner, indexes.clone());
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 1, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 5, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 9, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 13, 'Incorrect hole_id');

    let rabbits = Registry.get_user_rabbits(burner2, indexes.clone());
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 2, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 6, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 10, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 14, 'Incorrect hole_id');

    indexes.append(5);
    indexes.append(6);
    indexes.append(7);
    indexes.append(8);

    let rabbits = Registry.get_user_rabbits(burner3, indexes.clone());
    assert(rabbits.len() == 8, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 3, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 4, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 7, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 8, 'Incorrect hole_id');
    assert(*rabbits.at(4).index == 11, 'Incorrect hole_id');
    assert(*rabbits.at(5).index == 12, 'Incorrect hole_id');
    assert(*rabbits.at(6).index == 15, 'Incorrect hole_id');
    assert(*rabbits.at(7).index == 16, 'Incorrect hole_id');

    /// test rabbits in hole 
    let mut indexes = ArrayTrait::<u64>::new();
    indexes.append(1);
    indexes.append(2);
    indexes.append(3);
    indexes.append(4);
    let mut rabbits = Registry.get_rabbits_in_hole(1, indexes.clone());
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 1, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 5, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 10, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 14, 'Incorrect hole_id');
    rabbits = Registry.get_rabbits_in_hole(2, indexes.clone());
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 2, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 6, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 9, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 13, 'Incorrect hole_id');
    rabbits = Registry.get_rabbits_in_hole(3, indexes.clone());
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 3, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 7, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 11, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 15, 'Incorrect hole_id');
    rabbits = Registry.get_rabbits_in_hole(4, indexes);
    assert(rabbits.len() == 4, 'Incorrect rabbits count');
    assert(*rabbits.at(0).index == 4, 'Incorrect hole_id');
    assert(*rabbits.at(1).index == 8, 'Incorrect hole_id');
    assert(*rabbits.at(2).index == 12, 'Incorrect hole_id');
    assert(*rabbits.at(3).index == 16, 'Incorrect hole_id');

    /// re-test holes
    test_hole(Registry, 1, anon, 'title', 0, 4, 6);
    test_hole(Registry, 2, anon2, 'title2', 0, 4, 6);
    test_hole(Registry, 3, anon3, 'title3', 0, 4, 6);
    test_hole(Registry, 4, anon3, 'title4', 0, 4, 6);
}

#[test]
#[available_gas(2000000)]
fn toggle_creation() {
    let (Manager, Rbits, Registry) = deploy_suite();
    assert(Registry.is_hole_creation() == true, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == true, 'Incorrect is_rabbit_creation');
    Registry.toggle_hole_creation();
    Registry.toggle_rabbit_creation();
    assert(Registry.is_hole_creation() == false, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == false, 'Incorrect is_rabbit_creation');
    Registry.toggle_hole_creation();
    Registry.toggle_rabbit_creation();
    assert(Registry.is_hole_creation() == true, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == true, 'Incorrect is_rabbit_creation');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Registry: invalid permit', 'ENTRYPOINT_FAILED'))]
fn toggle_hole_creation_anon() {
    let (Manager, Rbits, Registry) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Registry.toggle_hole_creation();
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Registry: invalid permit', 'ENTRYPOINT_FAILED'))]
fn toggle_rabbit_creation_anon() {
    let (Manager, Rbits, Registry) = deploy_suite();
    set_contract_address(contract_address_const::<'anon'>());
    Registry.toggle_rabbit_creation();
}

#[test]
#[available_gas(4000000)]
fn toggle_creation_with_permit() {
    let (Manager, Rbits, Registry) = deploy_suite();
    let manager = contract_address_const::<'manager'>();
    Manager.set_permit(manager, Registry.TOGGLE_CREATE_PERMIT(), 1000000);
    set_contract_address(manager);
    assert(Registry.is_hole_creation() == true, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == true, 'Incorrect is_rabbit_creation');
    Registry.toggle_hole_creation();
    Registry.toggle_rabbit_creation();
    assert(Registry.is_hole_creation() == false, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == false, 'Incorrect is_rabbit_creation');
    Registry.toggle_hole_creation();
    Registry.toggle_rabbit_creation();
    assert(Registry.is_hole_creation() == true, 'Incorrect is_hole_creation');
    assert(Registry.is_rabbit_creation() == true, 'Incorrect is_rabbit_creation');
}

