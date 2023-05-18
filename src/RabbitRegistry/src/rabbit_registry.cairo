/// storage:

// _rabbits: LegacyMap<u64, Rabbit>, /// rabbit.id -> rabbit
// _total_rabbits: u64,
// _burn_log: LegacyMap<u64, felt252>, /// slot index -> rabbit.msg chunk
// _burn_pointer: u64, /// pointer to the next rabbit slot

/// events:
// #[event]
// fn RabbitBurned(_hole_id: u64, _burner: ContractAddress, _global_index: u64, _user_index: u64) {}

/// structs:
// #[derive(Serde, Drop)]
// struct Rabbit {
//     burner: ContractAddress,
//     timestamp: u64,
//     m_start: u64,
//     m_end: u64,
//     hole_id: u64,
// }

/// storage impl:
// impl RabbitStorageAccess of StorageAccess<Rabbit> {
//     fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<Rabbit> {
//         Result::Ok(
//             Rabbit {
//                 burner: Felt252TryIntoContractAddress::try_into(
//                     storage_read_syscall(
//                         address_domain, storage_address_from_base_and_offset(base, 0_u8)
//                     )?
//                 )
//                     .unwrap(),
//                 timestamp: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 1_u8)
//                 )?
//                     .try_into()
//                     .unwrap(),
//                 m_start: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 2_u8)
//                 )?
//                     .try_into()
//                     .unwrap(),
//                 m_end: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 3_u8)
//                 )?
//                     .try_into()
//                     .unwrap(),
//                 hole_id: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 4_u8)
//                 )?
//                     .try_into()
//                     .unwrap(),
//             }
//         )
//     }

//     fn write(
//         address_domain: u32, base: StorageBaseAddress, value: Rabbit
//     ) -> SyscallResult::<()> {
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 0_u8),
//             value.burner.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 1_u8),
//             value.timestamp.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 2_u8),
//             value.m_start.into()
//         )?;
//         storage_write_syscall(
//             address_domain, storage_address_from_base_and_offset(base, 3_u8), value.m_end.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 4_u8),
//             value.hole_id.into()
//         )
//     }
// }

/// methods:
// fn burn_rabbit(hole_id_: u64, msg_array_: Array<felt252>) -> u64 {
//     let burner = get_caller_address();
//     ///  @dev Logic for burning rabbit
//     let (global_burn_depth, user_burn_depth) = _burn_rabbit(hole_id_, burner, msg_array_);
//     /// @dev Burn 1 of caller's RBITS
//     // _burn(burner, 1.into());
//     /// @dev Fire event
//     RabbitBurned(hole_id_, burner, global_burn_depth, user_burn_depth);
//     global_burn_depth
// }

// fn _inc_user_rabbits(_address: ContractAddress, _rabbit_id: u64) -> u64 {
//     let mut _user_rabbits_total = 
//     let mut _user = _user_stats::read(_address);
//     let new_depth = _user.rabbits + 1_u64;
//     _user.rabbits = new_depth;
//     _user_stats::write(_address, _user);
//     _user_rabbits::write((_address, new_depth), _rabbit_id);
//     new_depth
// }
// fn _burn(address_: ContractAddress, amount_: u256) {
//     IRbitsDispatcher {
//         contract_address: _RBITS_ADDRESS::read()
//     }.burn(owner: address_, amount: amount_);
// }

// fn _burn_to_log(_msg_array: Array<felt252>) -> (u64, u64) {
//     let x32: u32 = _msg_array.len();
//     let xFelt: felt252 = x32.into();
//     let m_len: u64 = xFelt.try_into().unwrap();
//     let m_start: u64 = _burn_pointer::read();
//     let m_end: u64 = m_start + m_len;
//     let mut _i64: u64 = 0_u64;
//     loop {
//         if _i64 >= m_len {
//             break ();
//         }
//         let _bp = m_start + _i64;
//         let _iFelt: felt252 = _i64.into();
//         let _i32: u32 = _iFelt.try_into().unwrap();
//         _burn_log::write(_bp, *_msg_array.at(_i32));
//         _i64 += 1_u64;
//     };
//     _burn_pointer::write(m_end);
//     (m_start, m_end)
// }

// fn _burn_rabbit(
//     hole_id_: u64, burner_: ContractAddress, msg_array_: Array<felt252>
// ) -> (u64, u64) {
//     /// @dev Check if hole exists
//     assert(_holes::read(hole_id_).depth > 0_u64, 'RBITS::Hole does not exist');
//     /// @dev Increment total burns
//     let total_rabbits_new = _total_rabbits::read() + 1_u64;
//     _total_rabbits::write(total_rabbits_new);
//     /// @dev Increment hole depth
//     let mut hole = _holes::read(hole_id_);
//     hole.depth += 1_u64;
//     _holes::write(hole_id_, hole);
//     /// @dev Write rabbit to log
//     let (m_start, m_end) = _burn_to_log(msg_array_);
//     /// @dev Create rabbit and write to storage
//     let mut rabbit = Rabbit {
//         burner: burner_, timestamp: get_block_timestamp(), m_start, m_end, hole_id: hole_id_, 
//     };
//     _rabbits::write(total_rabbits_new, rabbit);
//     /// @dev Increment user burns and write to user storage
//     let user_rabbits_new = HoleRegistryImpl::inc_user_rabbits(burner_, total_rabbits_new);
//     /// @dev Place rabbit in hole
//     _the_rabbit_hole::write((hole_id_, hole.depth), total_rabbits_new);

//     (total_rabbits_new, user_rabbits_new)
// }

/// @dev Increment user rabbits
// _inc_user_rabbits(burner_, rabbit_id_)
// do this in raabbit registryt


