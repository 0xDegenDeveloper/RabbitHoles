// #[cfg(test)]
// mod ImplTests {
//     use manager::manager::Manager;
//     use starknet::ContractAddress;
//     use starknet::contract_address_const;
//     use starknet::testing::set_caller_address;
//     use starknet::testing::set_block_timestamp;
//     use starknet::get_caller_address;
//     use debug::PrintTrait;

//     #[test]
//     #[available_gas(2000000)]
//     fn owner() {
//         assert(Manager::owner() == contract_address_const::<0>(), 'Owner init wrong');
//         let owner = _deploy();
//         assert(Manager::owner() == owner, 'Owner not set');
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn transfer_ownership() {
//         let owner = _deploy();
//         let new_owner = contract_address_const::<2>();
//         Manager::ManagerImpl::transfer_ownership(new_owner);
//         assert(Manager::ManagerImpl::owner() == new_owner, 'Owner not swapped');
//     /// @dev: Test event fired
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn renounce_ownership() {
//         let owner = _deploy();
//         let zero_addr = contract_address_const::<0>();
//         Manager::ManagerImpl::renounce_ownership();
//         assert(Manager::ManagerImpl::owner() == zero_addr, 'Owner not zeroed');
//     /// @dev: Test event fired
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn set_permit_and_has_permit_until() {
//         let owner = _deploy();
//         let account = contract_address_const::<2>();
//         let right = 'test';
//         let timestamp = 111;
//         assert(Manager::ManagerImpl::has_permit_until(account, right) == 0, 'Permit init wrong');
//         Manager::ManagerImpl::set_permit(account, right, timestamp);
//         assert(
//             Manager::ManagerImpl::has_permit_until(account, right) == timestamp, 'Permit set wrong'
//         );
//         Manager::ManagerImpl::set_permit(account, right, 0);
//         assert(Manager::ManagerImpl::has_permit_until(account, right) == 0, 'Permit set wrong');
//     /// @dev: Test event fired
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn has_valid_permit_owner() {
//         let owner = _deploy();
//         let right = 'anything';
//         assert(Manager::ManagerImpl::has_valid_permit(owner, right), 'Owner not permitted');
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn has_valid_permit() {
//         let owner = _deploy();
//         let account = contract_address_const::<2>();
//         let right = 'anything';
//         assert(!Manager::ManagerImpl::has_valid_permit(account, right), 'Permit faked');
//         Manager::ManagerImpl::set_permit(account, right, 111);
//         assert(Manager::ManagerImpl::has_valid_permit(account, right), 'Permit not set');
//         set_block_timestamp(110);
//         assert(Manager::ManagerImpl::has_valid_permit(account, right), 'Permit expired early');
//         set_block_timestamp(111);
//         assert(!Manager::ManagerImpl::has_valid_permit(account, right), 'Permit deadline broken');
//     }

//     #[test]
//     #[available_gas(2000000)]
//     fn bind_manager_right() {
//         let owner = _deploy();
//         let right = 'mint';
//         let manager_right = 'mint_manager';
//         assert(Manager::manager_rights(right) == 0x0, 'Manager right init wrong');
//         Manager::ManagerImpl::bind_manager_right(right, manager_right);
//         assert(Manager::manager_rights(right) == manager_right, 'Manager right not set');
//     /// @dev: Test event fired
//     }

//     /// Helpers ///
//     fn _deploy() -> ContractAddress {
//         let owner: ContractAddress = contract_address_const::<1>();
//         set_caller_address(owner);
//         Manager::constructor(owner);
//         owner
//     }
// }


