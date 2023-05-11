#[contract]
mod rbits {
    // use super::IERC20;
    // use super::IOwnable;
    // use super::IRbits;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::ContractAddressZeroable;
    use starknet::Felt252TryIntoContractAddress;

    use zeroable::Zeroable;
    // use integer::BoundedInt;

    struct Storage {
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        /// RBITS exclusive ///
        _owner: ContractAddress,
        _minters: LegacyMap<ContractAddress, bool>,
        _burners: LegacyMap<ContractAddress, bool>,
    }

    trait IRbits {
        fn update_minter(minter: starknet::ContractAddress, status: bool);
        fn update_burner(burner: starknet::ContractAddress, status: bool);
    }

    trait IOwnable {
        fn owner() -> starknet::ContractAddress;
        fn transfer_ownership(new_owner: starknet::ContractAddress);
        fn renounce_ownership();
    }

    trait IERC20 {
        fn name() -> felt252;
        fn symbol() -> felt252;
        fn decimals() -> u8;
        fn total_supply() -> u256;
        fn balance_of(account: starknet::ContractAddress) -> u256;
        fn allowance(owner: starknet::ContractAddress, spender: starknet::ContractAddress) -> u256;
        fn transfer(recipient: starknet::ContractAddress, amount: u256) -> bool;
        fn transfer_from(
            sender: starknet::ContractAddress, recipient: starknet::ContractAddress, amount: u256
        ) -> bool;
        fn approve(spender: starknet::ContractAddress, amount: u256) -> bool;
    }

    #[constructor]
    fn constructor(initial_supply: u256, owner: ContractAddress, ) {
        _initializer('RabbitHoles', 'RBITS');
        _mint(owner, initial_supply);
        IOwnable::transfer_ownership(owner);
    }

    /// RBITS ///
    #[event]
    fn MinterStatusUpdated(minter: ContractAddress, current_status: bool) {}

    #[event]
    fn BurnerStatusUpdated(burner: ContractAddress, current_status: bool) {}

    impl Rbits of IRbits {
        fn update_minter(minter: ContractAddress, status: bool) {
            _only_owner();
            _minters::write(minter, status);
            MinterStatusUpdated(minter, status);
        }
        fn update_burner(burner: ContractAddress, status: bool) {
            _only_owner();
            _burners::write(burner, status);
            BurnerStatusUpdated(burner, status);
        }
    }

    #[view]
    fn is_minter(minter: ContractAddress) -> bool {
        _minters::read(minter)
    }

    #[view]
    fn is_burner(burner: ContractAddress) -> bool {
        _burners::read(burner)
    }

    #[external]
    fn update_minter(minter: ContractAddress, status: bool) {
        Rbits::update_minter(minter, status);
    }

    #[external]
    fn update_burner(burner: ContractAddress, status: bool) {
        Rbits::update_burner(burner, status);
    }

    /// Ownable ///
    #[event]
    fn OwnershipTransferred(previous_owner: ContractAddress, new_owner: ContractAddress) {}

    impl Ownable of IOwnable {
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
        Ownable::owner()
    }

    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        Ownable::transfer_ownership(new_owner);
    }

    #[external]
    fn renounce_ownership() {
        Ownable::renounce_ownership();
    }

    fn _only_owner() {
        assert(get_caller_address() == _owner::read(), 'RBITS::Caller not owner');
    }

    fn _transfer_ownership(new_owner: ContractAddress) {
        _owner::write(new_owner);
    }

    /// ERC20 ///
    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

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

    /// to do: ownership/restrict these 2

    #[external]
    fn mint(recipient: ContractAddress, amount: u256) {
        _mint(recipient, amount)
    }

    #[external]
    fn burn(owner: ContractAddress, amount: u256) {
        _burn(owner, amount);
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
}
