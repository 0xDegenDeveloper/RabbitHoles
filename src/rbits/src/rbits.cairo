use starknet::ContractAddress;

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

#[abi]
trait IRbits {
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn decimals() -> u8;
    fn total_supply() -> u256;
    fn balance_of(account: ContractAddress) -> u256;
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(spender: ContractAddress, amount: u256) -> bool;
    fn mint(recipient: ContractAddress, amount: u256);
    fn burn(owner: ContractAddress, amount: u256);
    fn MINT_RBITS() -> felt252;
    fn BURN_RBITS() -> felt252;
    fn MANAGER_ADDRESS() -> ContractAddress;
}

#[contract]
mod Rbits {
    use super::IRbits;
    use super::IRbitsDispatcher;
    use super::IRbitsDispatcherTrait;

    use super::IManager;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;

    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::get_contract_address;
    use starknet::ContractAddressIntoFelt252;
    use starknet::Felt252TryIntoContractAddress;
    use zeroable::Zeroable;

    struct Storage {
        _MINT_RBITS: felt252,
        _BURN_RBITS: felt252,
        _MANAGER_ADDRESS: ContractAddress,
        _name: felt252,
        _symbol: felt252,
        _decimals: u8,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    /// Events ///
    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    /// Constructor ///
    #[constructor]
    fn constructor(init_supply_: u256, owner_: ContractAddress, MANAGER_ADDRESS_: ContractAddress) {
        _initializer('RabbitHoles', 'RBITS', 18_u8, owner_, init_supply_, MANAGER_ADDRESS_);
    }

    /// Implementations ///
    impl RbitsImpl of IRbits {
        fn name() -> felt252 {
            _name::read()
        }

        fn symbol() -> felt252 {
            _symbol::read()
        }

        fn decimals() -> u8 {
            _decimals::read()
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

        fn mint(recipient: ContractAddress, amount: u256) {
            assert(
                _has_valid_permit(get_caller_address(), _MINT_RBITS::read()),
                'RBITS: Caller non minter'
            );
            _mint(recipient, amount)
        }

        fn burn(owner: ContractAddress, amount: u256) {
            assert(
                _has_valid_permit(get_caller_address(), _BURN_RBITS::read()),
                'RBITS: Caller non burner'
            );
            _burn(owner, amount)
        }

        fn MINT_RBITS() -> felt252 {
            _MINT_RBITS::read()
        }

        fn BURN_RBITS() -> felt252 {
            _BURN_RBITS::read()
        }

        fn MANAGER_ADDRESS() -> ContractAddress {
            _MANAGER_ADDRESS::read()
        }
    }

    /// Read ///
    #[view]
    fn MINT_RBITS() -> felt252 {
        RbitsImpl::MINT_RBITS()
    }

    #[view]
    fn BURN_RBITS() -> felt252 {
        RbitsImpl::BURN_RBITS()
    }

    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress {
        RbitsImpl::MANAGER_ADDRESS()
    }

    #[view]
    fn name() -> felt252 {
        RbitsImpl::name()
    }

    #[view]
    fn symbol() -> felt252 {
        RbitsImpl::symbol()
    }

    #[view]
    fn decimals() -> u8 {
        RbitsImpl::decimals()
    }

    #[view]
    fn total_supply() -> u256 {
        RbitsImpl::total_supply()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        RbitsImpl::balance_of(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        RbitsImpl::allowance(owner, spender)
    }

    /// Write ///
    #[external]
    fn mint(recipient: ContractAddress, amount: u256) {
        RbitsImpl::mint(recipient, amount);
    }

    #[external]
    fn burn(owner: ContractAddress, amount: u256) {
        RbitsImpl::burn(owner, amount);
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        RbitsImpl::transfer(recipient, amount)
    }

    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        RbitsImpl::transfer_from(sender, recipient, amount)
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        RbitsImpl::approve(spender, amount)
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) - subtracted_value);
        true
    }

    /// Internal ///
    fn _initializer(
        name_: felt252,
        symbol_: felt252,
        decimals_: u8,
        init_owner_: ContractAddress,
        init_supply_: u256,
        MANAGER_ADDRESS_: ContractAddress
    ) {
        _MINT_RBITS::write('MINT RBITS');
        _BURN_RBITS::write('BURN RBITS');
        _MANAGER_ADDRESS::write(MANAGER_ADDRESS_);

        _name::write(name_);
        _symbol::write(symbol_);
        _decimals::write(decimals_);
        _mint(init_owner_, init_supply_);
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

    fn _has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _MANAGER_ADDRESS::read()
        }.has_valid_permit(account, right)
    }
}
