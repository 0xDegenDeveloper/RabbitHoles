use starknet::ContractAddress;

#[abi]
trait IERC20 {
    #[view]
    fn balance_of(account: ContractAddress) -> u256;
    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn mint(recipient: ContractAddress, amount: u256);
    #[external]
    fn burn(owner: ContractAddress, amount: u256);
}

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

trait IHoleRegistry {
    fn dig_hole(title_: felt252) -> u64;
    fn burn_rabbit(hole_id_: u64, msg_array_: Array<felt252>) -> u64;
}

trait IUserStats {
    fn add_hole(_address: ContractAddress, _hole_id: u64) -> u64;
    fn add_rabbit(_address: ContractAddress, _rabbit_id: u64) -> u64;
}

#[contract]
mod Rbits {
    use super::IERC20;
    use super::IManager;
    use super::IHoleRegistry;
    use super::IUserStats;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;
    use super::IERC20Dispatcher;
    use super::IERC20DispatcherTrait;
    use array::ArrayTrait;
    use starknet::ContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::get_block_timestamp;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::StorageAccess;
    use starknet::StorageBaseAddress;
    use starknet::SyscallResult;
    use starknet::storage_read_syscall;
    use starknet::storage_write_syscall;
    use starknet::storage_address_from_base_and_offset;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use zeroable::Zeroable;

    struct Storage {
        _dig_fee: u256, /// fee for digging a hole
        _dig_reward: u256, /// reward for digging a hole
        _dig_token_address: ContractAddress, /// address of the token used for digging fee
        ///
        _holes: LegacyMap<u64, Hole>, /// hole.id -> hole
        _rabbits: LegacyMap<u64, Rabbit>, /// rabbit.id -> rabbit
        ///
        _total_holes: u64,
        _total_rabbits: u64,
        _hole_title_to_id: LegacyMap<felt252, u64>, /// hole.title -> hole.id
        ///
        _burn_log: LegacyMap<u64, felt252>, /// slot index -> rabbit.msg chunk
        _burn_pointer: u64, /// pointer to the next rabbit slot
        ///
        _the_rabbit_hole: LegacyMap<(u64, u64), u64>, /// hole.id -> index -> rabbit.id
        ///
        _user_stats: LegacyMap<ContractAddress,
        UserStats>, // user.address -> user.stats (.holes, .rabbits)
        _user_holes: LegacyMap<(ContractAddress, u64), u64>, // user.address, index -> hole.id
        _user_rabbits: LegacyMap<(ContractAddress, u64), u64>, // user.address, index -> rabbit.id
        ///
        _manager_address: ContractAddress, /// address of the manager contract (minters/burners)
        _rbits_address: ContractAddress, /// address of the RBITS token
    }

    /// Events ///
    #[event]
    fn HoleDug(_title: felt252, _digger: ContractAddress, _global_index: u64, _user_index: u64) {}

    #[event]
    fn RabbitBurned(
        _hole_id: u64, _burner: ContractAddress, _global_index: u64, _user_index: u64
    ) {}

    /// Structs ///
    #[derive(Drop, Serde)]
    struct UserStats {
        holes: u64,
        rabbits: u64,
    }

    #[derive(Drop, Copy, Serde)]
    struct Hole {
        digger: ContractAddress,
        timestamp: u64,
        depth: u64,
        title: felt252,
    }

    #[derive(Serde, Drop)]
    struct Rabbit {
        burner: ContractAddress,
        timestamp: u64,
        m_start: u64,
        m_end: u64,
        hole_id: u64,
    }

    /// Constructor ///
    #[constructor]
    fn constructor(
        dig_fee_: u256,
        dig_reward_: u256,
        dig_token_address_: ContractAddress,
        rbits_address_: ContractAddress
    ) {
        _initializer(dig_fee_, dig_reward_, dig_token_address_, rbits_address_);
    }

    /// Implementations ///
    impl HoleRegistryImpl of IHoleRegistry {
        fn dig_hole(title_: felt252) -> u64 {
            /// @dev Check if hole already exists
            assert(_hole_title_to_id::read(title_) == 0_u64, 'RBITS::Hole already exists');

            let digger = get_caller_address();
            let this_address = get_contract_address();
            let dig_fee: u256 = _dig_fee::read();
            // global_depth, user_depth = _dig_hole()
            let (global_depth, user_depth) = _dig_hole(title_, digger);

            _take_dig_fee(digger);

            _mint(digger, _dig_reward::read());
            HoleDug(title_, digger, _total_holes::read(), _user_stats::read(digger).holes);
            global_depth
        }

        fn burn_rabbit(hole_id_: u64, msg_array_: Array<felt252>) -> u64 {
            /// @dev Check if hole exists
            assert(_holes::read(hole_id_).depth > 0_u64, 'RBITS::Hole does not exist');

            let burner = get_caller_address();

            /// @dev Check if caller can afford to burn an RBIT
            // assert(balance_of(burner) > 0.into(), 'RBITS::No RBITS to burn');

            ///  @dev Logic for burning rabbit
            let (global_burn_depth, user_burn_depth) = _burn_rabbit(hole_id_, burner, msg_array_);

            /// @dev Burn 1 of caller's RBITS
            // _burn(burner, 1.into());

            /// @dev Fire event
            RabbitBurned(hole_id_, burner, global_burn_depth, user_burn_depth);
            global_burn_depth
        }
    }

    impl UserStatsImpl of IUserStats {
        fn add_hole(_address: ContractAddress, _hole_id: u64) -> u64 {
            let mut _user = _user_stats::read(_address);
            let new_depth = _user.holes + 1_u64;
            _user.holes = new_depth;
            _user_stats::write(_address, _user);
            _user_holes::write((_address, new_depth), _hole_id);
            new_depth
        }

        fn add_rabbit(_address: ContractAddress, _rabbit_id: u64) -> u64 {
            let mut _user = _user_stats::read(_address);
            let new_depth = _user.rabbits + 1_u64;
            _user.rabbits = new_depth;
            _user_stats::write(_address, _user);
            _user_rabbits::write((_address, new_depth), _rabbit_id);
            new_depth
        }
    }

    /// StorageAccess Implementation ///
    impl UserStatsStorageAccess of StorageAccess<UserStats> {
        fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<UserStats> {
            Result::Ok(
                UserStats {
                    holes: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 0_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    rabbits: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?
                        .try_into()
                        .unwrap(),
                }
            )
        }

        fn write(
            address_domain: u32, base: StorageBaseAddress, value: UserStats
        ) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 0_u8), value.holes.into()
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 1_u8),
                value.rabbits.into()
            )
        }
    }

    impl HoleStorageAccess of StorageAccess<Hole> {
        fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<Hole> {
            Result::Ok(
                Hole {
                    digger: Felt252TryIntoContractAddress::try_into(
                        storage_read_syscall(
                            address_domain, storage_address_from_base_and_offset(base, 0_u8)
                        )?
                    )
                        .unwrap(),
                    timestamp: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    depth: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 2_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    title: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 3_u8)
                    )?,
                }
            )
        }

        fn write(
            address_domain: u32, base: StorageBaseAddress, value: Hole
        ) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 0_u8),
                value.digger.into()
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 1_u8),
                value.timestamp.into()
            )?;
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 2_u8), value.depth.into()
            )?;
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 3_u8), value.title
            )
        }
    }

    impl RabbitStorageAccess of StorageAccess<Rabbit> {
        fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<Rabbit> {
            Result::Ok(
                Rabbit {
                    burner: Felt252TryIntoContractAddress::try_into(
                        storage_read_syscall(
                            address_domain, storage_address_from_base_and_offset(base, 0_u8)
                        )?
                    )
                        .unwrap(),
                    timestamp: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    m_start: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 2_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    m_end: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 3_u8)
                    )?
                        .try_into()
                        .unwrap(),
                    hole_id: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 4_u8)
                    )?
                        .try_into()
                        .unwrap(),
                }
            )
        }

        fn write(
            address_domain: u32, base: StorageBaseAddress, value: Rabbit
        ) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 0_u8),
                value.burner.into()
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 1_u8),
                value.timestamp.into()
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 2_u8),
                value.m_start.into()
            )?;
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 3_u8), value.m_end.into()
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 4_u8),
                value.hole_id.into()
            )
        }
    }

    /// Read ///

    /// Write ///

    /// Internals ///
    fn _initializer(
        dig_fee_: u256,
        dig_reward_: u256,
        dig_token_address_: ContractAddress,
        rbits_address_: ContractAddress
    ) {
        _dig_fee::write(dig_fee_);
        _dig_reward::write(dig_reward_);
        _dig_token_address::write(dig_token_address_);
        _rbits_address::write(rbits_address_);
    }

    fn _has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _manager_address::read()
        }.has_valid_permit(account, right)
    }

    fn _take_dig_fee(digger_: ContractAddress) {
        let this_address = get_contract_address();
        IERC20Dispatcher {
            contract_address: _dig_token_address::read()
        }.transfer_from(sender: digger_, recipient: this_address, amount: _dig_fee::read());
    }

    fn _mint(address_: ContractAddress, amount_: u256) {
        IERC20Dispatcher {
            contract_address: _rbits_address::read()
        }.mint(recipient: address_, amount: amount_);
    }

    fn _burn(address_: ContractAddress, amount_: u256) {
        IERC20Dispatcher {
            contract_address: _rbits_address::read()
        }.burn(owner: address_, amount: amount_);
    }

    fn _dig_hole(title_: felt252, digger_: ContractAddress) -> (u64, u64) {
        let global_depth = _total_holes::read() + 1_u64;
        let hole = Hole {
            digger: digger_, timestamp: get_block_timestamp(), depth: 1_u64, title: title_, 
        };
        _total_holes::write(global_depth);
        _holes::write(global_depth, hole);
        _hole_title_to_id::write(title_, global_depth);
        (global_depth, UserStatsImpl::add_hole(digger_, global_depth))
    }

    fn _burn_to_log(_msg_array: Array<felt252>) -> (u64, u64) {
        let x32: u32 = _msg_array.len();
        let xFelt: felt252 = x32.into();
        let m_len: u64 = xFelt.try_into().unwrap();
        let m_start: u64 = _burn_pointer::read();
        let m_end: u64 = m_start + m_len;
        let mut _i64: u64 = 0_u64;
        loop {
            if _i64 >= m_len {
                break ();
            }
            let _bp = m_start + _i64;
            let _iFelt: felt252 = _i64.into();
            let _i32: u32 = _iFelt.try_into().unwrap();
            _burn_log::write(_bp, *_msg_array.at(_i32));
            _i64 += 1_u64;
        };
        _burn_pointer::write(m_end);
        (m_start, m_end)
    }

    fn _burn_rabbit(
        hole_id_: u64, burner_: ContractAddress, msg_array_: Array<felt252>
    ) -> (u64, u64) {
        /// @dev Increment total burns
        let total_rabbits_new = _total_rabbits::read() + 1_u64;
        _total_rabbits::write(total_rabbits_new);
        /// @dev Increment hole depth
        let mut hole = _holes::read(hole_id_);
        hole.depth += 1_u64;
        _holes::write(hole_id_, hole);
        /// @dev Write rabbit to log
        let (m_start, m_end) = _burn_to_log(msg_array_);
        /// @dev Create rabbit and write to storage
        let mut rabbit = Rabbit {
            burner: burner_, timestamp: get_block_timestamp(), m_start, m_end, hole_id: hole_id_, 
        };
        _rabbits::write(total_rabbits_new, rabbit);
        /// @dev Increment user burns and write to user storage
        let user_rabbits_new = UserStatsImpl::add_rabbit(burner_, total_rabbits_new);
        /// @dev Place rabbit in hole
        _the_rabbit_hole::write((hole_id_, hole.depth), total_rabbits_new);

        (total_rabbits_new, user_rabbits_new)
    }
}
