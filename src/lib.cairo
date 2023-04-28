#[abi]
trait IDigFeeToken {
    #[external]
    fn allowance(owner: starknet::ContractAddress, spender: starknet::ContractAddress) -> u256;
    #[external]
    fn balance_of(account: starknet::ContractAddress) -> u256;
    #[external]
    fn transfer_from(
        sender: starknet::ContractAddress, recipient: starknet::ContractAddress, amount: u256
    ) -> bool;
}


/// @dev author: DegenDeveloper.eth (Matt Carter)
/// @dev date: April 28, 2023
#[contract]
mod RabbitHoles {
    use super::IDigFeeTokenDispatcher;
    use super::IDigFeeTokenDispatcherTrait;

    use array::ArrayTrait;
    use zeroable::Zeroable;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;

    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::get_block_timestamp;

    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::ContractAddressZeroable;
    
    use starknet::StorageAccess;
    use starknet::StorageBaseAddress;
    use starknet::SyscallResult;
    use starknet::storage_read_syscall;
    use starknet::storage_write_syscall;
    use starknet::storage_address_from_base_and_offset;
    

    struct Storage {
        /// Ownable ///
        _owner: ContractAddress,
        /// ERC20 ///
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        /// RabbitHoles ///
        _DIG_FEE: u256, // eth fee to dig a hole (to do)
        _DIG_REWARD: u256, // number of RBIT to mint to the digger
        _dig_fee_token_address: ContractAddress, // address of the ether contract
        _total_digs: u64, // total number of holes dug
        _digs: LegacyMap<u64, Hole>, // hole_id -> hole
        _digs_title_to_id: LegacyMap<felt252, u64>, // hole_title -> hole_id
        _total_burns: u64, // total number of rabbits burnt in holes
        _burns: LegacyMap<u64, Rabbit>, // rabbit_id -> rabbit
        _burn_pointer: u64, // index for the next msg chunk to be burned in to the log
        _burn_log: LegacyMap<u64, felt252>, // index -> rabbit msg chunk 
        _the_rabbit_hole: LegacyMap<(u64, u64), u64>, // hole_id, index -> rabbit_id
        _user_stats: LegacyMap<ContractAddress, UserStats>, // user_address -> user (.digs & .burns)
        _user_digs: LegacyMap<(ContractAddress, u64), u64>, // user_address, index -> hole_id
        _user_burns: LegacyMap<(ContractAddress, u64), u64>, // user_address, index -> rabbit_id
    }

    #[constructor]
    fn constructor(
        owner: ContractAddress,
        dig_fee_token_address: ContractAddress,
        initial_supply: u256,
        recipient: ContractAddress,
        dig_fee: u256,
        dig_reward: u256
    ) {
        _owner::write(owner);
        _dig_fee_token_address::write(dig_fee_token_address);
        _initializer('RabbitHoles', 'RBITS');
        _DIG_FEE::write(dig_fee);
        _DIG_REWARD::write(dig_reward);
        _mint(recipient, initial_supply);
    }

    #[event]
    fn HoleDug(_title: felt252, _digger: ContractAddress, _global_index: u64, _user_index: u64) {}

    #[event]
    fn RabbitBurned(
        _title: felt252, _burner: ContractAddress, _global_index: u64, _user_index: u64
    ) {}

    /// Owner-Only Functions ///
    #[external]
    fn set_dig_fee(amount: u256) {
        _only_owner();
        _DIG_FEE::write(amount);
    }

    #[external]
    fn set_dig_reward(amount: u256) {
        _only_owner();
        _DIG_REWARD::write(amount);
    }

    #[external]
    fn set_dig_fee_token_address(address: ContractAddress) {
        _only_owner();
        _dig_fee_token_address::write(address);
    }

    /// Read-Only Functions ///
    #[view]
    fn DIG_FEE() -> u256 {
        _DIG_FEE::read()
    }

    #[view]
    fn DIG_REWARD() -> u256 {
        _DIG_REWARD::read()
    }

    #[view]
    fn DIG_FEE_TOKEN_ADDRESS() -> ContractAddress {
        _dig_fee_token_address::read()
    }

    #[view]
    fn total_digs() -> u64 {
        _total_digs::read()
    }

    #[view]
    fn total_burns() -> u64 {
        _total_burns::read()
    }

    #[view]
    fn get_hole(id: u64) -> Hole {
        _digs::read(id)
    }

    #[view]
    fn get_hole_id_from_title(title: felt252) -> u64 {
        _digs_title_to_id::read(title)
    }

    #[view]
    // fn get_rabbit(id: u64) -> Rabbit {
    fn get_rabbit(id: u64) -> (Rabbit, Array<felt252>) {
        (_burns::read(id), _get_message_from_log(id))
    }

    #[view]
    fn get_rabbits_in_hole(id: u64) -> Array<u64> {
        _get_rabbits_in_hole(id)
    }

    #[view]
    fn get_user_stats(address: ContractAddress) -> UserStats {
        _user_stats::read(address)
    }

    #[view]
    fn get_user_rabbits_and_holes(address: ContractAddress) -> (Array<u64>, Array<u64>) {
        (_get_user_holes(address), _get_user_rabbits(address))
    }

    #[view]
    fn get_user_holes(address: ContractAddress) -> Array<u64> {
        _get_user_holes(address)
    }

    #[view]
    fn get_user_rabbits(address: ContractAddress) -> Array<u64> {
        _get_user_rabbits(address)
    }

    /// Public Functions ///
    #[external]
    fn dig_hole(title: felt252) {
        /// @dev Check if hole already exists
        assert(_digs_title_to_id::read(title) == 0_u64, 'RBITS::Hole already exists');

        let digger = get_caller_address();
        let this_address = get_contract_address();
        let dig_fee: u256 = _DIG_FEE::read();

        /// @dev Check if caller can afford to dig hole
        let dig_fee_token_balance: u256 = IDigFeeTokenDispatcher {
            contract_address: _dig_fee_token_address::read()
        }.balance_of(digger);
        assert(dig_fee_token_balance >= dig_fee, 'RBITS::Insufficient Ether');

        /// @dev Check if this contract can spend caller's ether
        let dig_fee_token_allowance: u256 = IDigFeeTokenDispatcher {
            contract_address: _dig_fee_token_address::read()
        }.allowance(owner: digger, spender: this_address, );
        assert(dig_fee_token_allowance >= dig_fee, 'RBITS::Insufficient Allowance');

        /// @dev Logic for digging hole
        let (global_depth, user_depth) = _dig_hole(title, digger, 'TO DO'.try_into().unwrap());

        /// @dev Transfer Ether from caller to this contract
        IDigFeeTokenDispatcher {
            contract_address: _dig_fee_token_address::read()
        }.transfer_from(sender: digger, recipient: this_address, amount: dig_fee);

        /// @dev Mint RBITS to digger
        _mint(digger, _DIG_REWARD::read());

        /// @dev Fire event
        HoleDug(title, digger, global_depth, user_depth);
    }

    #[external]
    fn burn_rabbit(title: felt252, msg_array: Array<felt252>) {
        /// @dev Check if hole exists
        let hole_id = _digs_title_to_id::read(title);
        assert(_digs::read(hole_id).depth > 0_u64, 'RBITS::Hole does not exist');

        let burner = get_caller_address();

        /// @dev Check if caller can afford to burn an RBIT
        assert(balance_of(burner) > 0.into(), 'RBITS::No RBITS to burn');

        ///  @dev Logic for burning rabbit
        let (global_burn_depth, user_burn_depth) = _burn_rabbit(
            _title: title, _burner: burner, _msg_array: msg_array
        );

        /// @dev Burn 1 of caller's RBITS
        _burn(burner, 1.into());

        /// @dev Fire event
        RabbitBurned(title, burner, global_burn_depth, user_burn_depth);
    }

    /// Structs/Impls ///
    #[derive(Drop, Serde)]
    struct UserStats {
        digs: u64,
        burns: u64,
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

    trait UserStatsTraits {
        fn _add_dig(_address: ContractAddress, _hole_id: u64) -> u64;
        fn _add_rabbit(_address: ContractAddress, _rabbit_id: u64) -> u64;
    }

    impl UserStatsTraitsImpl of UserStatsTraits {
        fn _add_dig(_address: ContractAddress, _hole_id: u64) -> u64 {
            let mut _user = _user_stats::read(_address);
            let new_depth = _user.digs + 1_u64;
            _user.digs = new_depth;
            _user_stats::write(_address, _user);
            _user_digs::write((_address, new_depth), _hole_id);
            new_depth
        }

        fn _add_rabbit(_address: ContractAddress, _rabbit_id: u64) -> u64 {
            let mut _user = _user_stats::read(_address);
            let new_depth = _user.burns + 1_u64;
            _user.burns = new_depth;
            _user_stats::write(_address, _user);
            _user_burns::write((_address, new_depth), _rabbit_id);
            new_depth
        }
    }

    impl UserStatsStorageAccess of StorageAccess<UserStats> {
        fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<UserStats> {
            Result::Ok(
                UserStats {
                    digs: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 0_u8)
                    )?.try_into().unwrap(),
                    burns: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?.try_into().unwrap(),
                }
            )
        }

        fn write(
            address_domain: u32, base: StorageBaseAddress, value: UserStats
        ) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 0_u8), value.digs.into()
            )?;
            storage_write_syscall(
                address_domain, storage_address_from_base_and_offset(base, 1_u8), value.burns.into()
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
                    ).unwrap(),
                    timestamp: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?.try_into().unwrap(),
                    depth: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 2_u8)
                    )?.try_into().unwrap(),
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
                    ).unwrap(),
                    timestamp: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 1_u8)
                    )?.try_into().unwrap(),
                    m_start: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 2_u8)
                    )?.try_into().unwrap(),
                    m_end: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 3_u8)
                    )?.try_into().unwrap(),
                    hole_id: storage_read_syscall(
                        address_domain, storage_address_from_base_and_offset(base, 4_u8)
                    )?.try_into().unwrap(),
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

    /// Helpers/Internals ///
    fn _dig_hole(_title: felt252, _digger: ContractAddress, _timestamp: u64) -> (u64, u64) {
        /// @dev Increment global digs
        let global_depth = _total_digs::read() + 1_u64;
        _total_digs::write(global_depth);
        /// @dev Create hole and write to storage
        let hole = Hole { digger: _digger, timestamp: _timestamp, depth: 1_u64, title: _title };
        _digs::write(global_depth, hole);
        _digs_title_to_id::write(_title, global_depth);
        /// @dev Increment user digs and write to user storage
        let user_depth = UserStatsTraitsImpl::_add_dig(_digger, global_depth);
        /// @return global_depth: the index of the hole globally
        /// @return user_depth: the index of the hole for the user
        (global_depth, user_depth)
    }

    fn _burn_rabbit(
        _title: felt252, _burner: ContractAddress, _msg_array: Array<felt252>
    ) -> (u64, u64) {
        /// @dev Increment global burns
        let total_burns_new = _total_burns::read() + 1_u64;
        _total_burns::write(total_burns_new);
        /// @dev Increment depth of hole
        let hole_id = _digs_title_to_id::read(_title);
        let mut hole = _digs::read(hole_id);
        let hole_depth = hole.depth + 1_u64;
        hole.depth = hole_depth;
        _digs::write(hole_id, hole);
        /// @dev Write rabbit to log
        let (m_start, m_end) = _burn_to_log(_msg_array);
        /// @dev Create rabbit and write to storage
        let mut rabbit = Rabbit {
            burner: _burner, timestamp: get_block_timestamp(), m_start, m_end, hole_id, 
        };
        _burns::write(total_burns_new, rabbit);
        /// @dev Increment user burns and write to user storage
        let user_burns_new = UserStatsTraitsImpl::_add_rabbit(_burner, total_burns_new);
        /// @dev Place rabbit in hole
        let hole_id = _digs_title_to_id::read(_title);
        _the_rabbit_hole::write((hole_id, hole_depth), total_burns_new);
        /// @return total_burns_new: index of rabbit globally
        /// @return user_burns_new: index of rabbit for user
        (total_burns_new, user_burns_new)
    }

    fn _burn_to_log(_msg_array: Array<felt252>) -> (u64, u64) {
        let m_len: u64 = _msg_array.len().into().try_into().unwrap();
        let m_start: u64 = _burn_pointer::read();
        let m_end: u64 = m_start + m_len;
        let mut _i64: u64 = 0_u64;
        loop {
            if _i64 >= m_len {
                break ();
            }
            let _bp = m_start + _i64;
            let _i32: u32 = _i64.into().try_into().unwrap(); // u64 -> u32
            _burn_log::write(_bp, *_msg_array.at(_i32));
            _i64 += 1_u64;
        };
        _burn_pointer::write(m_end);
        (m_start, m_end)
    }

    fn _block_timestamp() -> u64 {
        get_block_timestamp()
    }

    fn _get_user_holes(address: ContractAddress) -> Array<u64> {
        let len = _user_stats::read(address).digs;
        let mut user_hole_ids = ArrayTrait::new();
        let mut i: u64 = 0_u64;
        loop {
            if (i >= len) {
                break ();
            }
            let hole_id = _user_digs::read((address, i));
            user_hole_ids.append(hole_id);

            i += 1_u64;
        };

        user_hole_ids
    }

    fn _get_user_rabbits(address: ContractAddress) -> Array<u64> {
        let len = _user_stats::read(address).burns;
        let mut user_rabbit_ids = ArrayTrait::new();
        let mut i: u64 = 0_u64;
        loop {
            if (i >= len) {
                break ();
            }
            let rabbit_id = _user_burns::read((address, i));
            user_rabbit_ids.append(rabbit_id);

            i += 1_u64;
        };

        user_rabbit_ids
    }

    fn _get_rabbits_in_hole(hole_id: u64) -> Array<u64> {
        let len = _digs::read(hole_id).depth;
        let mut rabbit_ids = ArrayTrait::new();
        let mut i: u64 = 0_u64;
        loop {
            if (i >= len) {
                break ();
            }
            let rabbit_id = _the_rabbit_hole::read((hole_id, i));
            rabbit_ids.append(rabbit_id);

            i += 1_u64;
        };

        rabbit_ids
    }

    fn _get_message_from_log(rabbit_id: u64) -> Array<felt252> {
        let rabbit = _burns::read(rabbit_id);
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

    /// ERC20 ///

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    trait IERC20 {
        fn name() -> felt252;
        fn symbol() -> felt252;
        fn decimals() -> u8;
        fn total_supply() -> u256;
        fn balance_of(account: ContractAddress) -> u256;
        fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
        fn transfer(recipient: ContractAddress, amount: u256) -> bool;
        fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
        fn approve(spender: ContractAddress, amount: u256) -> bool;
    }

    impl ERC20 of IERC20 {
        fn name() -> felt252 {
            _name::read()
        }

        fn symbol() -> felt252 {
            _symbol::read()
        }

        fn decimals() -> u8 {
            18_u8
        }

        fn total_supply() -> u256 {
            _total_supply::read()
        }

        fn balance_of(account: ContractAddress) -> u256 {
            _balances::read(account)
        }

        fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
            _allowances::read((owner, spender))
        }

        fn transfer(recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            _transfer(sender, recipient, amount);
            true
        }

        fn transfer_from(
            sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool {
            let caller = get_caller_address();
            _spend_allowance(sender, caller, amount);
            _transfer(sender, recipient, amount);
            true
        }

        fn approve(spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            _approve(caller, spender, amount);
            true
        }
    }

    #[view]
    fn name() -> felt252 {
        ERC20::name()
    }

    #[view]
    fn symbol() -> felt252 {
        ERC20::symbol()
    }

    #[view]
    fn decimals() -> u8 {
        ERC20::decimals()
    }

    #[view]
    fn total_supply() -> u256 {
        ERC20::total_supply()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        ERC20::balance_of(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        ERC20::allowance(owner, spender)
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transfer(recipient, amount)
    }

    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transfer_from(sender, recipient, amount)
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        ERC20::approve(spender, amount)
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        _increase_allowance(spender, added_value)
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        _decrease_allowance(spender, subtracted_value)
    }

    fn _initializer(name_: felt252, symbol_: felt252) {
        _name::write(name_);
        _symbol::write(symbol_);
    }

    fn _increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    fn _decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) - subtracted_value);
        true
    }

    fn _mint(recipient: ContractAddress, amount: u256) {
        assert(!recipient.is_zero(), 'ERC20: mint to 0');
        _total_supply::write(_total_supply::read() + amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(Zeroable::zero(), recipient, amount);
    }

    fn _burn(account: ContractAddress, amount: u256) {
        assert(!account.is_zero(), 'ERC20: burn from 0');
        _total_supply::write(_total_supply::read() - amount);
        _balances::write(account, _balances::read(account) - amount);
        Transfer(account, Zeroable::zero(), amount);
    }

    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!owner.is_zero(), 'ERC20: approve from 0');
        assert(!spender.is_zero(), 'ERC20: approve to 0');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer to 0');
        _balances::write(sender, _balances::read(sender) - amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(sender, recipient, amount);
    }

    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = _allowances::read((owner, spender));
        let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
        let is_unlimited_allowance =
            current_allowance.low == ONES_MASK & current_allowance.high == ONES_MASK;
        if !is_unlimited_allowance {
            _approve(owner, spender, current_allowance - amount);
        }
    }

    /// OWNABLE ///

    #[event]
    fn OwnershipTransferred(previous_owner: ContractAddress, new_owner: ContractAddress) {}

    trait IOwnable {
        fn owner() -> ContractAddress;
        fn transfer_ownership(new_owner: ContractAddress);
        fn renounce_ownership();
    }

    impl Ownerable of IOwnable {
        fn owner() -> ContractAddress {
            _owner::read()
        }

        fn transfer_ownership(new_owner: ContractAddress) {
            _only_owner();
            let prev_owner = _owner::read();
            _transfer_ownership(new_owner);
            OwnershipTransferred(prev_owner, new_owner);
        }

        fn renounce_ownership() {
            _only_owner();
            let prev_owner = _owner::read();
            let new_owner = 0.try_into().unwrap();
            _transfer_ownership(new_owner);
            OwnershipTransferred(_owner::read(), new_owner);
        }
    }

    #[view]
    fn owner() -> ContractAddress {
        IOwnable::owner()
    }

    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        IOwnable::transfer_ownership(new_owner);
    }

    #[external]
    fn renounce_ownership() {
        IOwnable::renounce_ownership();
    }

    fn _only_owner() {
        assert(get_caller_address() == _owner::read(), 'RBITS::Caller not owner');
    }

    fn _transfer_ownership(new_owner: ContractAddress) {
        _owner::write(new_owner);
    }
}
