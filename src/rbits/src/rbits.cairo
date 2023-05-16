use starknet::ContractAddress;

trait IRBITS {
    // fn owner() -> ContractAddress;
    // fn transfer_ownership(new_owner: ContractAddress);
    // fn renounce_ownership();
    // fn update_manager_address(new_manager_address: ContractAddress);
    fn mint(recipient: ContractAddress, amount: u256);
    fn burn(owner: ContractAddress, amount: u256);
}

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

#[abi]
trait IManager {
    #[view]
    fn has_valid_permit(account: ContractAddress, right: felt252) -> bool;
}

#[contract]
mod rbits {
    use super::IRBITS;
    use super::IERC20;
    use super::IManager;

    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;

    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    // use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt252;
    use starknet::Felt252TryIntoContractAddress;
    use zeroable::Zeroable;

    struct Storage {
        // _RBITS_MANAGER: felt252, /// permit to firt manager
        _RBITS_MINT: felt252, /// permit to mint tokens
        _RBITS_BURN: felt252, /// permit to burn tokens
        // _owner: ContractAddress, /// can fire manager
        _manager_address: ContractAddress, /// address of the manager contract (minters/burners)
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
    fn constructor(init_supply: u256, owner: ContractAddress, ) {
        _initializer('RabbitHoles', 'RBITS', 18_u8, owner, init_supply);
    }

    /// Implementations ///
    impl ERC20 of IERC20 {
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
    }

    impl Rbits of IRBITS {
        fn mint(recipient: ContractAddress, amount: u256) {
            assert(
                _has_valid_permit(get_caller_address(), _RBITS_MINT::read()),
                'RBITS: Caller non minter'
            );
            _mint(recipient, amount)
        }

        fn burn(owner: ContractAddress, amount: u256) {
            assert(
                _has_valid_permit(get_caller_address(), _RBITS_BURN::read()),
                'RBITS: Caller non burner'
            );
            _burn(owner, amount)
        }
    }

    /// RBITS Read ///
    #[view]
    fn RBITS_MINT() -> felt252 {
        _RBITS_MINT::read()
    }

    #[view]
    fn RBITS_BURN() -> felt252 {
        _RBITS_BURN::read()
    }

    /// ERC20 Read ///
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

    /// RBITS Write ///
    #[external]
    fn mint(recipient: ContractAddress, amount: u256) {
        Rbits::mint(recipient, amount);
    }

    #[external]
    fn burn(owner: ContractAddress, amount: u256) {
        Rbits::burn(owner, amount);
    }

    /// ERC20 Write ///
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

    /// RBITS Internal ///
    fn _initializer(
        name: felt252, symbol: felt252, decimals: u8, init_owner: ContractAddress, init_supply: u256
    ) {
        _RBITS_MINT::write('RBITS_MINT');
        _RBITS_BURN::write('RBITS_BURN');

        _name::write(name);
        _symbol::write(symbol);
        _decimals::write(decimals);
        _mint(init_owner, init_supply);
    }

    fn _has_valid_permit(account: ContractAddress, right: felt252) -> bool {
        IManagerDispatcher {
            contract_address: _manager_address::read()
        }.has_valid_permit(account, right)
    }

    /// ERC20 Internal ///
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
}
//// re write manager to mimic this contract
//  - need it to perform access control checks in IMPL
//      - all view/external funcs should skip, move logic inside IMPL


