use array::ArrayTrait;
use debug::PrintTrait;
use option::OptionTrait;
use rabbitholes::core::manager::{Manager, IManager, IManagerDispatcherTrait, IManagerDispatcher};
use result::ResultTrait;
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::{ContractAddress, contract_address_const, get_caller_address};
use starknet::syscalls::deploy_syscall;
use starknet::testing::{set_caller_address, set_contract_address, set_block_timestamp};
use traits::{Into, TryInto};

/// Helpers ///
fn deploy_manager() -> IManagerDispatcher {
    let owner: ContractAddress = contract_address_const::<'owner'>();
    let mut calldata = ArrayTrait::new();
    set_contract_address(owner);
    calldata.append(owner.into());

    let (manager_address, _) = deploy_syscall(
        Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    IManagerDispatcher { contract_address: manager_address }
}

fn _set_permit_from_for(
    Manager: IManagerDispatcher,
    from: ContractAddress,
    for: ContractAddress,
    permit: felt252,
    timestamp: u64
) {
    set_contract_address(from);
    Manager.set_permit(for, permit, timestamp);
}

fn _transfer_ownership_from_to(
    Manager: IManagerDispatcher, from: ContractAddress, to: ContractAddress
) {
    set_contract_address(from);
    Manager.transfer_ownership(to);
}

/// Deployment
#[test]
#[available_gas(3000000)]
fn constructor() {
    let Manager = deploy_manager();
    assert(Manager.owner().into() == 'owner', 'Owner fail');
    assert(Manager.MANAGER_PERMIT() == 'MANAGER', 'MANAGER_PERMIT fail')
}

/// Ownable
#[test]
#[available_gas(2000000)]
fn transfer_ownership_as_owner() {
    let Manager = deploy_manager();
    let new_owner = contract_address_const::<1234>();
    _transfer_ownership_from_to(Manager, Manager.owner(), new_owner);
    assert(Manager.owner() == new_owner, 'Owner not swapped');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: caller not owner', 'ENTRYPOINT_FAILED'))]
fn transfer_ownership_as_anon() {
    let Manager = deploy_manager();
    let not_owner = contract_address_const::<666>();
    _transfer_ownership_from_to(Manager, not_owner, not_owner);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: false renouncement', 'ENTRYPOINT_FAILED'))]
fn transfer_ownership_to_zero() {
    let Manager = deploy_manager();
    let zero_addr = contract_address_const::<0>();
    _transfer_ownership_from_to(Manager, Manager.owner(), zero_addr);
}


#[test]
#[available_gas(2000000)]
fn renounce_ownership() {
    let Manager = deploy_manager();
    let zero_addr = contract_address_const::<0>();
    set_contract_address(Manager.owner());
    Manager.renounce_ownership();
    assert(Manager.owner() == zero_addr, 'Owner not zeroed');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: caller not owner', 'ENTRYPOINT_FAILED'))]
fn renounce_ownership_as_anon() {
    let Manager = deploy_manager();
    set_contract_address(contract_address_const::<666>());
    Manager.renounce_ownership();
}

/// Managerial
#[test]
#[available_gas(2000000)]
fn set_permit_as_owner() {
    let Manager = deploy_manager();
    let account = contract_address_const::<555>();
    /// Check account has no permit
    assert(Manager.has_permit_until(account, 'permit') == 0, 'Incorrect timestamp');
    assert(!Manager.has_valid_permit(account, 'permit'), 'False permit');
    /// Set permit
    _set_permit_from_for(Manager, Manager.owner(), account, 'permit', 123);
    /// Check account has permit
    assert(Manager.has_permit_until(account, 'permit') == 123, 'Incorrect timestamp');
    assert(Manager.has_valid_permit(account, 'permit'), 'Broken permit');
    /// Check permit expires
    set_block_timestamp(124);
    assert(!Manager.has_valid_permit(account, 'permit'), 'Permit should expire');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: invalid sudo permit', 'ENTRYPOINT_FAILED'))]
fn set_permit_as_anon() {
    let Manager = deploy_manager();
    let account = contract_address_const::<666>();
    _set_permit_from_for(Manager, account, account, 'permit', 123);
}

#[test]
#[available_gas(2000000)]
fn set_permit_as_manager() {
    let Manager = deploy_manager();
    let manager = contract_address_const::<'manager'>();
    let anon = contract_address_const::<'anon'>();
    /// Check anon has no permit
    assert(!Manager.has_valid_permit(anon, 'MINT'), 'Should not have permit');
    assert(Manager.has_permit_until(anon, 'MINT') == 0, 'Incorrect timestamp');
    /// Assign manager & set sudo permit (MINT -> MINT_MANAGER)
    _set_permit_from_for(Manager, Manager.owner(), manager, 'MINT MANAGER', 123);
    Manager.set_sudo_permit('MINT', 'MINT MANAGER');
    /// Set permit as manager
    _set_permit_from_for(Manager, manager, anon, 'MINT', 123);
    /// Check anon has permit
    assert(Manager.has_valid_permit(anon, 'MINT'), 'Should not have permit');
    assert(Manager.has_permit_until(anon, 'MINT') == 123, 'Incorrect timestamp');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: Setting zeroed permit', 'ENTRYPOINT_FAILED'))]
fn set_permit_with_zero() {
    let Manager = deploy_manager();
    let account = contract_address_const::<666>();
    _set_permit_from_for(Manager, Manager.owner(), account, 0x0, 123);
}

#[test]
#[available_gas(2000000)]
fn set_sudo_permit_as_owner() {
    let Manager = deploy_manager();
    assert(Manager.manager_permits('MINT') == 0x0, 'Manager permit init wrong');
    set_contract_address(Manager.owner());
    Manager.set_sudo_permit('MINT', 'MINT MANAGER');
    assert(Manager.manager_permits('MINT') == 'MINT MANAGER', 'Manager permit set wrong');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Manager: Caller non manager', 'ENTRYPOINT_FAILED'))]
fn set_sudo_permit_as_anon() {
    let Manager = deploy_manager();
    set_contract_address(contract_address_const::<'anon'>());
    Manager.set_sudo_permit('MINT', 'MINT MANAGER');
}

#[test]
#[available_gas(2000000)]
fn set_sudo_permit_as_manager() {
    let Manager = deploy_manager();
    let mananger = contract_address_const::<'manager'>();
    _set_permit_from_for(Manager, Manager.owner(), mananger, Manager.MANAGER_PERMIT(), 1111);
    set_contract_address(mananger);
    Manager.set_sudo_permit('MINT', 'MINT MANAGER');
    assert(Manager.manager_permits('MINT') == 'MINT MANAGER', 'Manager permit set wrong');
}

