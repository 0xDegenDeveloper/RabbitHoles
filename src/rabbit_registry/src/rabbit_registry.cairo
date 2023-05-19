use starknet::ContractAddress;

#[abi]
trait IRbits {
    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn burn(owner: ContractAddress, amount: u256);
}

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

#[abi]
trait IHoleRegistry {
    #[view]
    fn total_holes() -> u64;
    #[view]
    fn get_hole_digger(hole_id_: u64) -> ContractAddress;
    #[external]
    fn place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress);
}

#[abi]
trait IRabbitRegistry {
    fn ADD_RABBITS_STORAGE() -> felt252;
    fn BURN_RABBITS() -> felt252;
    fn HOLE_REGISTRY_ADDRESS() -> ContractAddress;
    fn MANAGER_ADDRESS() -> ContractAddress;
    fn RBITS_ADDRESS() -> ContractAddress;
    fn total_rabbits() -> u64;
    fn burn_logs_total() -> u64;
    fn burn_logs(id_: u64) -> ContractAddress;
    fn burn_logs_record(id_: u64) -> u64;
    fn user_stats(user_: ContractAddress) -> u64;
    fn user_rabbits(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64>;
    fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>);
    fn burn_rabbit(hole_id_: u64, msg_: Array<felt252>) -> u64;
    fn add_rabbit_storage(address_: ContractAddress, id_of_first_rabbit_: u64);
// fn burn_rabbit_permitted(hole_id_: u64, msg_: Array<felt252>, burner_: ContractAddress) -> u64;
}

#[abi]
trait IRabbitStorage {
    fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>);
    fn store_rabbit(
        rabbit_id_: u64,
        hole_id_: u64,
        msg_: Array<felt252>,
        this_burn_log_id_: u64,
        burner_: ContractAddress
    );
}

#[contract]
mod RabbitRegistry {
    use super::IRbits;
    use super::IRbitsDispatcher;
    use super::IRbitsDispatcherTrait;
    use super::IManager;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;
    use super::IHoleRegistry;
    use super::IHoleRegistryDispatcher;
    use super::IHoleRegistryDispatcherTrait;
    use super::IRabbitRegistry;
    use super::IRabbitRegistryDispatcher;
    use super::IRabbitRegistryDispatcherTrait;
    use super::IRabbitStorage;
    use super::IRabbitStorageDispatcher;
    use super::IRabbitStorageDispatcherTrait;

    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::ContractAddressIntoFelt252;
    use starknet::get_block_timestamp;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::StorageAccess;
    use starknet::storage_address_from_base_and_offset;
    use starknet::StorageBaseAddress;
    use starknet::SyscallResult;
    use starknet::storage_read_syscall;
    use starknet::storage_write_syscall;
    use array::ArrayTrait;
    use traits::Into;
    use integer::u256;
    use integer::u256_from_felt252;
    use traits::TryInto;
    use option::OptionTrait;
    use zeroable::Zeroable;

    struct Storage {
        /// 
        _HOLE_REGISTRY_ADDRESS: ContractAddress,
        _MANAGER_ADDRESS: ContractAddress,
        _RBITS_ADDRESS: ContractAddress,
        _BURN_RABBITS: felt252,
        _ADD_RABBITS_STORAGE: felt252,
        _total_rabbits: u64,
        ///
        _burn_logs_total: u64,
        _burn_logs: LegacyMap<u64, ContractAddress>,
        /// burn_log_id -> max rabbit_id inside  (RS 1 holds data for rabbits 1-10000, RS 2 holds data for rabbits 10001-20000, etc.)
        _burn_logs_record: LegacyMap<u64, u64>, /// index -> max rabbit_id inside
        ///
        _user_stats: LegacyMap<ContractAddress, u64>, /// addr -> total rabbits
        _user_rabbits: LegacyMap<(ContractAddress, u64), u64>, /// addr -> index -> rabbit.id
        _user_stats_depth: LegacyMap<ContractAddress, u64>, /// addr -> total rabbit lens
    }

    // events:
    #[event]
    fn RabbitBurned(
        _hole_id: u64, _burner: ContractAddress, _global_index: u64, _user_index: u64
    ) {}

    #[constructor]
    fn constructor(
        HOLE_REGISTRY_ADDRESS_: ContractAddress,
        MANAGER_ADDRESS_: ContractAddress,
        RBITS_ADDRESS_: ContractAddress
    ) {
        _BURN_RABBITS::write('BURN RABBITS');
        _ADD_RABBITS_STORAGE::write('ADD RABBITS STORAGE');
        _HOLE_REGISTRY_ADDRESS::write(HOLE_REGISTRY_ADDRESS_);
        _MANAGER_ADDRESS::write(MANAGER_ADDRESS_);
        _RBITS_ADDRESS::write(RBITS_ADDRESS_);
    }

    #[derive(Serde, Drop)]
    struct Rabbit {
        burner: ContractAddress,
        timestamp: u64,
        m_start: u64,
        m_end: u64,
        hole_id: u64,
        burn_log_id: u64,
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
                    burn_log_id: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 5_u8)
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
            )?;
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, 5_u8),
                value.burn_log_id.into()
            )
        }
    }


    impl RabbitRegistryImpl of IRabbitRegistry {
        fn BURN_RABBITS() -> felt252 {
            _BURN_RABBITS::read()
        }

        fn ADD_RABBITS_STORAGE() -> felt252 {
            _ADD_RABBITS_STORAGE::read()
        }

        fn HOLE_REGISTRY_ADDRESS() -> ContractAddress {
            _HOLE_REGISTRY_ADDRESS::read()
        }

        fn MANAGER_ADDRESS() -> ContractAddress {
            _MANAGER_ADDRESS::read()
        }

        fn RBITS_ADDRESS() -> ContractAddress {
            _RBITS_ADDRESS::read()
        }

        fn total_rabbits() -> u64 {
            _total_rabbits::read()
        }

        fn burn_logs_total() -> u64 {
            _burn_logs_total::read()
        }

        fn burn_logs(id_: u64) -> ContractAddress {
            _burn_logs::read(id_)
        }

        fn burn_logs_record(id_: u64) -> u64 {
            _burn_logs_record::read(id_)
        }

        fn user_stats(user_: ContractAddress) -> u64 {
            _user_stats::read(user_)
        }

        fn user_rabbits(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64> {
            let mut start = start_;
            if (start == 0_u64) {
                start = 1_u64;
            }
            let mut len = step_;
            let max = _user_stats::read(user_);
            if (step_ + start > max) {
                len = max - start + 1_u64;
            }
            let mut _arr = ArrayTrait::new();
            let mut i = 0;
            loop {
                if (i >= len) {
                    break ();
                }
                _arr.append(_user_rabbits::read((user_, start + i)));
                i += 1_u64;
            };
            _arr
        }

        fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>) {
            let id = _find_burn_log_index(rabbit_id_);
            let addr = _burn_logs::read(id);
            IRabbitStorageDispatcher { contract_address: addr }.get_rabbit(rabbit_id_)
        }

        fn burn_rabbit(hole_id_: u64, msg_: Array<felt252>) -> u64 {
            let burner = get_caller_address();
            let (glob, user) = _burn_rabbit(hole_id_, burner, msg_);
            RabbitBurned(hole_id_, burner, glob, user);
            glob
        }

        fn add_rabbit_storage(address_: ContractAddress, id_of_first_rabbit_: u64) {
            let new_log_id = _burn_logs_total::read() + 1_u64;
            _burn_logs_total::write(new_log_id);
            _burn_logs::write(new_log_id, address_);
            _burn_logs_record::write(new_log_id, id_of_first_rabbit_);
        //// event
        }
    }

    /// Reads ///
    #[view]
    fn HOLE_REGISTRY_ADDRESS() -> ContractAddress {
        RabbitRegistryImpl::HOLE_REGISTRY_ADDRESS()
    }

    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress {
        RabbitRegistryImpl::MANAGER_ADDRESS()
    }

    #[view]
    fn ADD_RABBITS_STORAGE() -> felt252 {
        RabbitRegistryImpl::ADD_RABBITS_STORAGE()
    }

    #[view]
    fn burn_logs_record(id_: u64) -> u64 {
        _burn_logs_record::read(id_)
    }

    #[view]
    fn burn_logs(id_: u64) -> ContractAddress {
        _burn_logs::read(id_)
    }

    #[view]
    fn burn_logs_total() -> u64 {
        _burn_logs_total::read()
    }

    #[view]
    fn RBITS_ADDRESS() -> ContractAddress {
        RabbitRegistryImpl::RBITS_ADDRESS()
    }
    /// Write ///
    #[external]
    fn add_rabbit_storage(storage_address_: ContractAddress, id_of_first_rabbit_: u64) {
        RabbitRegistryImpl::add_rabbit_storage(storage_address_, id_of_first_rabbit_);
    }

    #[external]
    fn burn_rabbit(hole_id_: u64, msg_: Array<felt252>) -> u64 {
        RabbitRegistryImpl::burn_rabbit(hole_id_, msg_)
    /// event
    }

    /// Internals ///
    fn _hole_exists(hole_id_: u64) {
        assert(hole_id_ > 0_u64, 'Incorrect hole id');
        assert(
            hole_id_ <= IHoleRegistryDispatcher {
                contract_address: _HOLE_REGISTRY_ADDRESS::read()
            }.total_holes(),
            'Hole not dug yet'
        );
    }

    fn _get_hole_digger(hole_id_: u64) -> ContractAddress {
        IHoleRegistryDispatcher {
            contract_address: _HOLE_REGISTRY_ADDRESS::read()
        }.get_hole_digger(hole_id_)
    }

    fn _burn_rabbit(
        hole_id_: u64, burner_: ContractAddress, msg_arr_: Array<felt252>
    ) -> (u64, u64) {
        /// @dev check hole exists
        _hole_exists(hole_id_);
        /// @dev increment total rabbits
        let global_burn_depth = _total_rabbits::read() + 1_u64;
        _total_rabbits::write(global_burn_depth);
        /// @dev increment user rabbits and add rabbit to user_rabbits
        let user_burn_index = _user_stats::read(burner_) + 1_u64;
        _user_stats::write(burner_, user_burn_index);
        _user_rabbits::write((burner_, user_burn_index), global_burn_depth);
        /// @dev cast u32 -> u64 
        let depth_felt: felt252 = msg_arr_.len().into();
        let depth: u64 = depth_felt.try_into().unwrap();
        /// @dev increment user burn depth (size of all burned rabbits)
        let user_burn_depth = _user_stats_depth::read(burner_) + depth;
        _user_stats_depth::write(burner_, user_burn_depth);
        /// @dev burn rabbit to log
        _burn_to_log(hole_id_, global_burn_depth, burner_, msg_arr_);
        /// @dev burn and transfer rbits
        let digger = _get_hole_digger(hole_id_);
        let amount_felt: felt252 = depth.into();
        let amount_256: u256 = u256_from_felt252(amount_felt);
        let digger = _get_hole_digger(hole_id_);
        _burn_and_transfer_rbits(burner_, digger, amount_256);
        (global_burn_depth, user_burn_depth)
    }

    fn _burn_to_log(
        hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress, msg_arr_: Array<felt252>
    ) {
        /// @dev increments hole depth and adds rabbit to hole mapping
        IHoleRegistryDispatcher {
            contract_address: _HOLE_REGISTRY_ADDRESS::read()
        }.place_rabbit_in_hole(hole_id_, rabbit_id_, burner_);
        /// @dev store rabbit in burn log contract
        let id = _find_burn_log_index(rabbit_id_);
        let addr = _burn_logs::read(id);
        IRabbitStorageDispatcher {
            contract_address: addr
        }.store_rabbit(rabbit_id_, hole_id_, msg_arr_, id, burner_);
    }


    fn _burn_and_transfer_rbits(burner_: ContractAddress, digger_: ContractAddress, amount_: u256) {
        let Rbits = IRbitsDispatcher { contract_address: _RBITS_ADDRESS::read() };
        let reward = amount_ / 2_u256;
        let to_burn = amount_ - reward;
        assert(reward + to_burn <= amount_, 'Cost overflow');

        Rbits.burn(burner_, to_burn);
        Rbits.transfer_from(burner_, digger_, 1_u256);
    }

    /// @dev finds the storage contract holding rabbit_id_
    fn _find_burn_log_index(rabbit_id_: u64) -> u64 {
        assert(rabbit_id_ > 0_u64, 'Invalid rabbit_id');
        assert(rabbit_id_ <= _total_rabbits::read(), 'Invalid rabbit_id');
        let mut i = 0_u64;
        loop {
            /// @dev rabbit_id_ is inside an active RS
            if (i >= _burn_logs_total::read()) {
                break ();
            }
            /// @dev rabbit_id_ is inside a disabled RS
            let this_logs_max = _burn_logs_record::read(i);
            if (rabbit_id_ <= this_logs_max) {
                i -= 1_u64;
                break ();
            };
            i += 1_u64;
        };
        i
    }

    fn _has_valid_permit(account_: ContractAddress, right_: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _MANAGER_ADDRESS::read()
        }.has_valid_permit(account_, right_)
    }
}
