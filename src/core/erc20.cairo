/// Contract based on https://github.com/starkware-libs/cairo/blob/main/crates/cairo-lang-starknet/test_data/erc20.cairo July 6, 23
use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    /// Reads
    fn SUDO_BURN(self: @TContractState) -> felt252;
    fn SUDO_MINT(self: @TContractState) -> felt252;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn decimals(self: @TContractState) -> u8;
    fn manager_address(self: @TContractState) -> ContractAddress;
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn total_supply(self: @TContractState) -> u256;
    /// Writes
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    );
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: u256);
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    );
    fn sudo_burn(ref self: TContractState, owner: ContractAddress, amount: u256);
    fn sudo_mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
}

#[starknet::contract]
mod ERC20 {
    use rabbitholes::core::manager::{IManager, IManagerDispatcherTrait, IManagerDispatcher};
    use starknet::{get_caller_address, contract_address_const, ContractAddress};
    use zeroable::Zeroable;

    #[storage]
    struct Storage {
        s_name: felt252,
        s_symbol: felt252,
        s_decimals: u8,
        s_total_supply: u256,
        s_balances: LegacyMap::<ContractAddress, u256>,
        s_allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
        s_manager_contract: IManagerDispatcher,
        s_SUDO_MINT: felt252,
        s_SUDO_BURN: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        value: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name_: felt252,
        symbol_: felt252,
        decimals_: u8,
        initial_supply: u256,
        recipient: ContractAddress,
        manager_address: ContractAddress,
    ) {
        self.s_name.write(name_);
        self.s_symbol.write(symbol_);
        self.s_decimals.write(decimals_);
        assert(!recipient.is_zero(), 'ERC20: mint to the 0 address');
        self.update(contract_address_const::<0>(), recipient, initial_supply);
        self.s_manager_contract.write(IManagerDispatcher { contract_address: manager_address });
        self.s_SUDO_MINT.write('SUDO_MINT');
        self.s_SUDO_BURN.write('SUDO_BURN');
    }

    #[external(v0)]
    impl ERC20 of super::IERC20<ContractState> {
        /// Reads
        fn SUDO_BURN(self: @ContractState) -> felt252 {
            self.s_SUDO_BURN.read()
        }

        fn SUDO_MINT(self: @ContractState) -> felt252 {
            self.s_SUDO_MINT.read()
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.s_allowances.read((owner, spender))
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.s_balances.read(account)
        }

        fn decimals(self: @ContractState) -> u8 {
            self.s_decimals.read()
        }

        fn manager_address(self: @ContractState) -> ContractAddress {
            self.s_manager_contract.read().contract_address
        }

        fn name(self: @ContractState) -> felt252 {
            self.s_name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.s_symbol.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.s_total_supply.read()
        }

        /// Writes
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.s_allowances.read((caller, spender)) - subtracted_value
                );
        }

        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.s_allowances.read((caller, spender)) + added_value
                );
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let sender = get_caller_address();
            self.transfer_helper(sender, recipient, amount);
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            let caller = get_caller_address();
            self.spend_allowance(sender, caller, amount);
            self.transfer_helper(sender, recipient, amount);
        }

        fn sudo_burn(ref self: ContractState, owner: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.has_valid_permit(self.s_SUDO_BURN.read());
            self.spend_allowance(owner, caller, amount);
            self.update(owner, contract_address_const::<0>(), amount);
        }

        fn sudo_mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.has_valid_permit(self.s_SUDO_MINT.read());
            self.update(contract_address_const::<0>(), recipient, amount);
        }
    }

    #[generate_trait]
    impl InteralImpl of StorageTrait {
        fn approve_helper(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!spender.is_zero(), 'ERC20: approve from 0');
            self.s_allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
        }

        fn has_valid_permit(ref self: ContractState, permit: felt252) {
            assert(
                self.s_manager_contract.read().has_valid_permit(get_caller_address(), permit),
                'ERC20: invalid permit'
            );
        }

        fn spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let current_allowance = self.s_allowances.read((owner, spender));
            let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
            let is_unlimited_allowance = current_allowance.low == ONES_MASK
                && current_allowance.high == ONES_MASK;
            if !is_unlimited_allowance {
                assert(current_allowance >= amount, 'ERC20: insufficient allowance');
                self.approve_helper(owner, spender, current_allowance - amount);
            }
        }

        fn transfer_helper(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) {
            assert(!sender.is_zero(), 'ERC20: transfer from 0');
            assert(!recipient.is_zero(), 'ERC20: transfer to 0');
            self.update(sender, recipient, amount);
        }

        fn update(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256
        ) {
            /// From
            if (from.is_zero()) {
                self.s_total_supply.write(self.s_total_supply.read() + amount);
            } else {
                let from_balance = self.s_balances.read(from);
                assert(from_balance >= amount, 'ERC20: insufficient balance');
                self.s_balances.write(from, from_balance - amount);
            }
            /// To
            if (to.is_zero()) {
                self.s_total_supply.write(self.s_total_supply.read() - amount);
            } else {
                self.s_balances.write(to, self.s_balances.read(to) + amount);
            }
            self.emit(Transfer { from: from, to: to, value: amount });
        }
    }
}

