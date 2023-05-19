use starknet::ContractAddress;

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

#[abi]
trait IHoleRegistry {
    fn place_rabbit_in_hole(hole_id_: u64, rabbit_id_: u64, burner_: ContractAddress);
}

#[contract]
mod RabbitStorage {
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
        _MANAGER_ADDRESS: ContractAddress,
        _STORAGE_WRITER: felt252,
        _ID_OF_FIRST_RABBIT: u64,
        _is_cold_storage: bool,
        _burn_log: LegacyMap<u64, felt252>, /// slot index -> rabbit.msg chunk
        _burn_pointer: u64, /// pointer for the next rabbit slot
        _rabbits: LegacyMap<u64, Rabbit>,
    }

    /// Events ///
    fn StorageFroze() {}

    /// Structs ///
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

    /// Constructor ///
    #[constructor]
    fn constructor(MANAGER_ADDRESS_: ContractAddress, ID_OF_FIRST_RABBIT_: u64) {
        _MANAGER_ADDRESS::write(MANAGER_ADDRESS_);
        _ID_OF_FIRST_RABBIT::write(ID_OF_FIRST_RABBIT_);
        _STORAGE_WRITER::write('STORAGE WRITER');
    }

    /// Internal ///
    fn _has_valid_permit(account_: ContractAddress, right_: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _MANAGER_ADDRESS::read()
        }.has_valid_permit(account_, right_)
    }

    fn _get_msg_from_log(rabbit_id_: u64) -> Array<felt252> {
        let rabbit = _rabbits::read(rabbit_id_);
        let (m_start, m_end) = (rabbit.m_start, rabbit.m_end);
        let mut i = m_start;
        let mut _msg_array = ArrayTrait::new();
        loop {
            if i >= m_end {
                break ();
            }
            let _msg = _burn_log::read(i);
            _msg_array.append(_msg);
            i += 1_u64;
        };
        _msg_array
    }

    fn _burn_to_log(msg_: Array<felt252>) -> (u64, u64) {
        let len_felt: felt252 = msg_.len().into();
        let m_len: u64 = len_felt.try_into().unwrap();
        let m_start = _burn_pointer::read();
        let m_end = m_start + m_len;
        let mut i = 0_u64;
        loop {
            if (i >= m_len) {
                break ();
            }
            let bp = m_start + i;
            let i_felt: felt252 = i.into();
            let i_32: u32 = i_felt.try_into().unwrap();
            _burn_log::write(bp, *msg_.at(i_32));
            i += 1;
        };
        _burn_pointer::write(m_end);
        (m_start, m_end)
    }

    fn _store_rabbit(
        rabbit_id_: u64,
        hole_id_: u64,
        msg_: Array<felt252>,
        this_burn_log_id_: u64,
        burner_: ContractAddress
    ) {
        /// @dev store msg chunks
        let (m_start, m_end) = _burn_to_log(msg_);
        /// @dev store rabbit details
        let mut rabbit = Rabbit {
            burner: burner_,
            timestamp: get_block_timestamp(),
            m_start: m_start,
            m_end: m_end,
            hole_id: hole_id_,
            burn_log_id: this_burn_log_id_,
        };
        _rabbits::write(rabbit_id_, rabbit);
    }

    fn _toggle_cold_storage() {
        let is_cold = _is_cold_storage::read();
        _is_cold_storage::write(!is_cold);
    }

    /// Read /// 
    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress {
        _MANAGER_ADDRESS::read()
    }

    #[view]
    fn STORAGE_WRITER() -> felt252 {
        _STORAGE_WRITER::read()
    }

    #[view]
    fn ID_OF_FIRST_RABBIT() -> u64 {
        _ID_OF_FIRST_RABBIT::read()
    }

    #[view]
    fn is_cold_storage() -> bool {
        _is_cold_storage::read()
    }

    #[view]
    fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>) {
        let rabbit = _rabbits::read(rabbit_id_);
        let msg = _get_msg_from_log(rabbit_id_);
        (rabbit.burner, rabbit.timestamp, msg)
    }


    /// Write ///
    #[external]
    fn toggle_cold_storage() {
        assert(
            _has_valid_permit(get_caller_address(), _STORAGE_WRITER::read()),
            'Caller non storage writer'
        );
        _toggle_cold_storage();
    }


    #[external]
    fn store_rabbit(
        rabbit_id_: u64,
        hole_id_: u64,
        msg_: Array<felt252>,
        this_burn_log_id_: u64,
        burner_: ContractAddress
    ) {
        assert(!_is_cold_storage::read(), 'Storage is cold');
        assert(
            _has_valid_permit(get_caller_address(), _STORAGE_WRITER::read()),
            'Caller non storage writer'
        );
        _store_rabbit(rabbit_id_, hole_id_, msg_, this_burn_log_id_, burner_);
    }
}

