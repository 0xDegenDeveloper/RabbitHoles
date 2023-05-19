use starknet::ContractAddress;

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

#[contract]
mod Rbits {
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
        _MINT_RBITS::write('MINT RBITS');
        _BURN_RBITS::write('BURN RBITS');
        _MANAGER_ADDRESS::write(MANAGER_ADDRESS_);
        _name::write('RabbitHoles');
        _symbol::write('RBITS');
        _decimals::write(18_u8);
        _mint(owner_, init_supply_);
    }

    /// Internal ///
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
        let is_unlimited_allowance = current_allowance.low == ONES_MASK
            & current_allowance.high == ONES_MASK;
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


    /// Read ///
    #[view]
    fn MINT_RBITS() -> felt252 {
        _MINT_RBITS::read()
    }

    #[view]
    fn BURN_RBITS() -> felt252 {
        _BURN_RBITS::read()
    }

    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress {
        _MANAGER_ADDRESS::read()
    }

    #[view]
    fn name() -> felt252 {
        _name::read()
    }

    #[view]
    fn symbol() -> felt252 {
        _symbol::read()
    }

    #[view]
    fn decimals() -> u8 {
        _decimals::read()
    }

    #[view]
    fn total_supply() -> u256 {
        _total_supply::read()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        _balances::read(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        _allowances::read((owner, spender))
    }

    /// Write ///
    #[external]
    fn mint(recipient: ContractAddress, amount: u256) {
        assert(
            _has_valid_permit(get_caller_address(), _MINT_RBITS::read()), 'RBITS: Caller non minter'
        );
        _mint(recipient, amount)
    }

    #[external]
    fn burn(owner: ContractAddress, amount: u256) {
        assert(
            _has_valid_permit(get_caller_address(), _BURN_RBITS::read()), 'RBITS: Caller non burner'
        );
        _burn(owner, amount)
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        let sender = get_caller_address();
        _transfer(sender, recipient, amount);
        true
    }

    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        let caller = get_caller_address();
        _spend_allowance(sender, caller, amount);
        _transfer(sender, recipient, amount);
        true
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, amount);
        true
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
}
