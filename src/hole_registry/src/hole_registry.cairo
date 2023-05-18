use starknet::ContractAddress;

#[abi]
trait IRbits {
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

#[abi]
trait IHoleRegistry {
    /// Consts/Immutables ///
    fn DIG_HOLES() -> felt252;
    fn PLACE_RABBITS() -> felt252;
    fn RBITS_ADDRESS() -> ContractAddress;
    fn MANAGER_ADDRESS() -> ContractAddress;
    /// Tokenomics ///
    fn dig_fee() -> u256;
    fn dig_reward() -> u256;
    fn dig_token_address() -> ContractAddress;
    /// Views ///
    fn get_hole(hole_id_: u64) -> HoleRegistry::Hole;
    fn get_hole_id(title_: felt252) -> u64;
    fn total_holes() -> u64;
    fn the_rabbit_hole(hole_id_: u64, index_: u64) -> u64;
    fn user_stats(user_: ContractAddress) -> u64;
    fn user_holes(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64>;
    /// External ///
    fn dig_hole(title_: felt252) -> u64;
    fn dig_hole_permitted(title_: felt252, digger_: ContractAddress) -> u64;
    fn place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress);
}

#[contract]
mod HoleRegistry {
    use super::IRbits;
    use super::IRbitsDispatcher;
    use super::IRbitsDispatcherTrait;
    use super::IManager;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;
    use super::IHoleRegistry;
    use super::IHoleRegistryDispatcher;
    use super::IHoleRegistryDispatcherTrait;
    use starknet::ContractAddress;
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
    use traits::TryInto;
    use option::OptionTrait;
    use zeroable::Zeroable;

    struct Storage {
        /// Consts/Immutables ///
        _DIG_HOLES: felt252,
        _PLACE_RABBITS: felt252,
        _MANAGER_ADDRESS: ContractAddress,
        _RBITS_ADDRESS: ContractAddress,
        /// Tokenomics ///
        _dig_fee: u256, /// fee for digging a hole
        _dig_reward: u256, /// reward for digging a hole
        _dig_token_address: ContractAddress, /// address of the token used for digging fee
        /// State ///
        _holes: LegacyMap<u64, Hole>, /// hole.id -> hole
        _total_holes: u64,
        _hole_title_to_id: LegacyMap<felt252, u64>, /// hole.title -> hole.id
        _the_rabbit_hole: LegacyMap<(u64, u64), u64>, /// hole.id -> index -> rabbit.id
        /// Users State ///
        _user_stats: LegacyMap<ContractAddress, u64>,
        _user_holes: LegacyMap<(ContractAddress, u64), u64>, // user.address, index -> hole.id
        _user_rabbits: LegacyMap<(ContractAddress, u64), u64>, // user.address, index -> rabbit.id
    }

    /// Events ///
    #[event]
    fn HoleDug(_title: felt252, _digger: ContractAddress, _global_index: u64, _user_index: u64) {}

    /// Structs ///
    #[derive(Drop, Copy, Serde)]
    struct Hole {
        digger: ContractAddress,
        timestamp: u64,
        depth: u64,
        title: felt252,
    }

    /// Constructor ///
    #[constructor]
    fn constructor(
        dig_fee_: u256,
        dig_reward_: u256,
        dig_token_address_: ContractAddress,
        RBITS_ADDRESS_: ContractAddress,
        MANAGER_ADDRESS_: ContractAddress,
    ) {
        _initializer(dig_fee_, dig_reward_, dig_token_address_, RBITS_ADDRESS_, MANAGER_ADDRESS_);
    }

    /// Implementation ///
    impl HoleRegistryImpl of IHoleRegistry {
        /// Writes ///
        fn dig_hole(title_: felt252) -> u64 {
            let digger = get_caller_address();
            _take_dig_fee(digger);
            _mint(digger, _dig_reward::read());
            let (global_depth, user_depth) = _dig_hole(title_, digger);
            HoleDug(title_, digger, global_depth, user_depth);
            global_depth
        }

        fn dig_hole_permitted(title_: felt252, digger_: ContractAddress) -> u64 {
            assert(
                _has_valid_permit(get_caller_address(), DIG_HOLES()),
                'HoleRegistry: Caller non digger'
            );
            let (global_depth, user_depth) = _dig_hole(title_, digger_);
            HoleDug(title_, digger_, global_depth, user_depth);
            global_depth
        }

        fn place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress) {
            assert(
                _has_valid_permit(get_caller_address(), PLACE_RABBITS()),
                'HoleRegistry: Caller non leaver'
            );

            _place_rabbit_in_hole(hole_id_, rabbit_id_, burner_);
        // RabbitBurned(hole_id_, burner_, rabbit_id_, user_depth);
        }

        /// Reads ///
        fn DIG_HOLES() -> felt252 {
            _DIG_HOLES::read()
        }

        fn PLACE_RABBITS() -> felt252 {
            _PLACE_RABBITS::read()
        }

        fn MANAGER_ADDRESS() -> ContractAddress {
            _MANAGER_ADDRESS::read()
        }

        fn RBITS_ADDRESS() -> ContractAddress {
            _RBITS_ADDRESS::read()
        }

        fn dig_fee() -> u256 {
            _dig_fee::read()
        }

        fn dig_reward() -> u256 {
            _dig_reward::read()
        }

        fn dig_token_address() -> ContractAddress {
            _dig_token_address::read()
        }

        fn get_hole(hole_id_: u64) -> Hole {
            _holes::read(hole_id_)
        }

        fn get_hole_id(title_: felt252) -> u64 {
            _hole_title_to_id::read(title_)
        }

        fn total_holes() -> u64 {
            _total_holes::read()
        }

        fn the_rabbit_hole(hole_id_: u64, index_: u64) -> u64 {
            _the_rabbit_hole::read((hole_id_, index_))
        }

        fn user_stats(user_: ContractAddress) -> u64 {
            _user_stats::read(user_)
        }

        fn user_holes(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64> {
            let mut start = start_;
            if (start_ == 0_u64) {
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
                _arr.append(_user_holes::read((user_, start + i)));
                i += 1_u64;
            };
            _arr
        }
    }

    /// StorageAccess Implementation ///
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

    /// Read ///
    #[view]
    fn DIG_HOLES() -> felt252 {
        HoleRegistryImpl::DIG_HOLES()
    }

    #[view]
    fn PLACE_RABBITS() -> felt252 {
        HoleRegistryImpl::PLACE_RABBITS()
    }

    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress {
        HoleRegistryImpl::MANAGER_ADDRESS()
    }

    #[view]
    fn RBITS_ADDRESS() -> ContractAddress {
        _RBITS_ADDRESS::read()
    }

    #[view]
    fn dig_fee() -> u256 {
        HoleRegistryImpl::dig_fee()
    }

    #[view]
    fn dig_reward() -> u256 {
        HoleRegistryImpl::dig_reward()
    }

    #[view]
    fn dig_token_address() -> ContractAddress {
        HoleRegistryImpl::dig_token_address()
    }


    #[view]
    fn get_hole(hole_id_: u64) -> Hole {
        HoleRegistryImpl::get_hole(hole_id_)
    }

    #[view]
    fn get_hole_id(title_: felt252) -> u64 {
        HoleRegistryImpl::get_hole_id(title_)
    }

    #[view]
    fn total_holes() -> u64 {
        HoleRegistryImpl::total_holes()
    }

    #[view]
    fn the_rabbit_hole(hole_id_: u64, index_: u64) -> u64 {
        HoleRegistryImpl::the_rabbit_hole(hole_id_, index_)
    }

    #[view]
    fn user_stats(user_: ContractAddress) -> u64 {
        HoleRegistryImpl::user_stats(user_)
    }

    #[view]
    fn user_holes(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64> {
        HoleRegistryImpl::user_holes(user_, start_, step_)
    }
    /// Write ///
    #[external]
    fn dig_hole(title_: felt252) -> u64 {
        HoleRegistryImpl::dig_hole(title_)
    }

    #[external]
    fn dig_hole_permitted(title_: felt252, burner_: ContractAddress) -> u64 {
        HoleRegistryImpl::dig_hole_permitted(title_, burner_)
    }

    #[external]
    fn place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress) {
        HoleRegistryImpl::place_rabbit_in_hole(hole_id_, rabbit_id_, burner_);
    }

    /// Internals ///
    fn _initializer(
        dig_fee_: u256,
        dig_reward_: u256,
        dig_token_address_: ContractAddress,
        RBITS_ADDRESS_: ContractAddress,
        MANAGER_ADDRESS_: ContractAddress
    ) {
        _DIG_HOLES::write('DIG HOLES');
        _PLACE_RABBITS::write('PLACE RABBITS');

        _dig_fee::write(dig_fee_);
        _dig_reward::write(dig_reward_);
        _dig_token_address::write(dig_token_address_);
        _RBITS_ADDRESS::write(RBITS_ADDRESS_);
        _MANAGER_ADDRESS::write(MANAGER_ADDRESS_);
    }


    fn _has_valid_permit(account_: ContractAddress, right_: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _MANAGER_ADDRESS::read()
        }.has_valid_permit(account_, right_)
    }

    fn _take_dig_fee(digger_: ContractAddress) {
        IRbitsDispatcher {
            contract_address: _dig_token_address::read()
        }
            .transfer_from(
                sender: digger_, recipient: get_contract_address(), amount: _dig_fee::read()
            );
    }

    fn _mint(address_: ContractAddress, amount_: u256) {
        IRbitsDispatcher {
            contract_address: _RBITS_ADDRESS::read()
        }.mint(recipient: address_, amount: amount_);
    }

    fn _dig_hole(title_: felt252, digger_: ContractAddress) -> (u64, u64) {
        assert(_hole_title_to_id::read(title_) == 0_u64, 'Hole already exists');
        assert(!digger_.is_zero(), 'Invalid digger address');
        let global_depth = _total_holes::read() + 1_u64;
        let hole = Hole {
            digger: digger_, timestamp: get_block_timestamp(), depth: 1_u64, title: title_, 
        };
        _total_holes::write(global_depth);
        _holes::write(global_depth, hole);
        _hole_title_to_id::write(title_, global_depth);
        (global_depth, _inc_user_holes(digger_, global_depth))
    }

    fn _place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress) {
        assert(hole_id_ != 0_u64, 'Invalid hole id');
        assert(rabbit_id_ != 0_u64, 'Invalid rabbit id');
        assert(!burner_.is_zero(), 'Invalid burner address');
        /// @dev Increment hole depth
        let mut hole = _holes::read(hole_id_);
        hole.depth += 1_u64;
        _holes::write(hole_id_, hole);
        /// @dev Place rabbit in hole
        _the_rabbit_hole::write((hole_id_, hole.depth), rabbit_id_);
    }

    fn _inc_user_holes(_address: ContractAddress, _hole_id: u64) -> u64 {
        let mut _user_holes_total = _user_stats::read(_address) + 1_u64;
        _user_stats::write(_address, _user_holes_total);
        _user_holes::write((_address, _user_holes_total), _hole_id);
        _user_holes_total
    }
}
