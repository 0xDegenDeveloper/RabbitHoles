// use rabbitholes::manager::contract::{
//     manager, IManager, IManagerDispatcher, IManagerDispatcherTrait
// };
// // use rabbitholes::{manager};

// // #[starknet::interface]
// // trait IManager<TContractState> {
// //     /// read
// //     fn MANAGER_PERMIT(self: @TContractState) -> felt252;
// //     fn owner(self: @TContractState) -> ContractAddress;
// //     fn has_permit_until(self: @TContractState, account: ContractAddress, permit: felt252) -> u64;
// //     fn has_valid_permit(self: @TContractState, account: ContractAddress, permit: felt252) -> bool;
// //     fn manager_permits(self: @TContractState, permit: felt252) -> felt252;
// //     /// write
// //     fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
// //     fn renounce_ownership(ref self: TContractState);
// //     fn set_permit(
// //         ref self: TContractState, account: ContractAddress, permit: felt252, timestamp: u64
// //     );
// //     fn set_sudo_permit(ref self: TContractState, permit: felt252, sudo_permit: felt252);
// // }

// #[test]
// fn hi() {
//     assert(1 == 1, 'broke');
// }

// mod manager_integration_tests {
//     use super::{manager, IManager, IManagerDispatcher, IManagerDispatcherTrait};
//     // use core::result::ResultTrait;
//     // use core::traits::Into;
//     use starknet::syscalls::deploy_syscall;
//     use starknet::{ContractAddress, contract_address_const, get_caller_address};
//     use starknet::class_hash::Felt252TryIntoClassHash;

//     use starknet::testing::{set_caller_address, set_contract_address, set_block_timestamp};
//     use debug::PrintTrait;
//     use array::ArrayTrait;
//     use traits::{Into, TryInto};
//     use option::OptionTrait;
//     use result::ResultTrait;

//     #[test]
//     fn test_deploy() {
//         let Manager = deploy_manager();
//     // let manager: ContractAddress = Manager.owner();
//     // assert(Manager.owner() == contract_address_const::<'owner'>(), 'broke');
//     }

//     fn deploy_manager() -> IManagerDispatcher {
//         let owner: ContractAddress = contract_address_const::<'owner'>();
//         let mut calldata = ArrayTrait::new();

//         'hi'.print();
//         //    IManager::TEST_CLASS_HASH.try_into().print();

//         set_contract_address(owner);
//         calldata.append(owner.into());

//         let mut x = manager::IManagerImpl::owner('hi');
//         // let y: felt252 = x.into();

//         // x.print();
//         // y.print();

//         // let class_hash = Felt252TryIntoClassHash::try_into(
//         //     manager::contract::manager::TEST_CLASS_HASH
//         // )
//         //     .unwrap();

//         // class_hash.print();

//         let (manager_address, _) = deploy_syscall(
//             manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
//         )
//             .unwrap();
//         IManagerDispatcher { contract_address: manager_address }
//     }
// }


