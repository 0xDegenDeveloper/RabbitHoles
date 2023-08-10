use starknet::ContractAddress;

#[starknet::interface]
trait IRabbitholesV1<TContractState> {
    /// read
    fn MANAGER_ADDRESS(self: @TContractState) -> ContractAddress;
    fn RBITS_ADDRESS(self: @TContractState) -> ContractAddress;
    fn REGISTRY_ADDRESS(self: @TContractState) -> ContractAddress;
    fn SET_DIG_FEE_PERRMIT(self: @TContractState) -> felt252;
    fn SET_DIG_REWARD_PERRMIT(self: @TContractState) -> felt252;
    fn SET_DIG_TOKEN_PERMIT(self: @TContractState) -> felt252;
    fn SET_DIGGER_BPS_PERMIT(self: @TContractState) -> felt252;
    fn TOGGLE_DIGGING_PERMIT(self: @TContractState) -> felt252;
    fn TOGGLE_BURNING_PERMIT(self: @TContractState) -> felt252;
    fn WITHDRAW_PERMIT(self: @TContractState) -> felt252;
    fn digger_bps(self: @TContractState) -> u16;
    fn dig_fee(self: @TContractState) -> u256;
    fn dig_token_address(self: @TContractState) -> ContractAddress;
    fn dig_reward(self: @TContractState) -> u256;
    fn is_burning(self: @TContractState) -> bool;
    fn is_digging(self: @TContractState) -> bool;
    /// write
    fn burn_rabbit(ref self: TContractState, msg: Array<felt252>, hole_id: u64);
    fn dig_hole(ref self: TContractState, title: felt252);
    fn set_digger_bps(ref self: TContractState, bps: u16);
    fn set_dig_fee(ref self: TContractState, fee: u256);
    fn set_dig_reward(ref self: TContractState, reward: u256);
    fn set_dig_token(ref self: TContractState, token: ContractAddress);
    fn toggle_digging(ref self: TContractState);
    fn toggle_burning(ref self: TContractState);
    fn withdraw(ref self: TContractState, amount: u256, to: ContractAddress);
}

#[starknet::contract]
mod RabbitholesV1 {
    use array::ArrayTrait;
    use rabbitholes::{
        core::{
            manager::{IManager, IManagerDispatcherTrait, IManagerDispatcher},
            erc20::{IERC20, IERC20DispatcherTrait, IERC20Dispatcher},
            registry::{Registry, IRegistry, IRegistryDispatcherTrait, IRegistryDispatcher}
        }
    };
    use starknet::{
        get_block_timestamp, get_caller_address, get_contract_address, contract_address_const,
        ContractAddress, ContractAddressIntoFelt252, Store, storage_address_from_base_and_offset,
        StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
        Felt252TryIntoContractAddress
    };
    use core::integer;
    use option::{Option, OptionTrait};
    use traits::{Into, TryInto};
    use zeroable::Zeroable;

    #[storage]
    struct Storage {
        s_MANAGER_ADDRESS: ContractAddress,
        s_RBITS_ADDRESS: ContractAddress,
        s_REGISTRY_ADDRESS: ContractAddress,
        s_SET_DIGGER_BPS_PERMIT: felt252,
        s_SET_DIG_FEE_PERRMIT: felt252,
        s_SET_DIG_REWARD_PERRMIT: felt252,
        s_SET_DIG_TOKEN_PERMIT: felt252,
        s_TOGGLE_DIGGING_PERMIT: felt252,
        s_TOGGLE_BURNING_PERMIT: felt252,
        s_WITHDRAW_PERMIT: felt252,
        s_digger_bps: u16,
        s_dig_token_address: ContractAddress,
        s_dig_fee: u256,
        s_dig_reward: u256,
        s_is_digging: bool,
        s_is_burning: bool,
    }


    #[constructor]
    fn constructor(
        ref self: ContractState,
        manager_address: ContractAddress,
        rbits_address: ContractAddress,
        registry_address: ContractAddress,
        dig_token_address: ContractAddress,
        digger_bps: u16,
        dig_fee: u256,
        dig_reward: u256,
    ) {
        self.s_MANAGER_ADDRESS.write(manager_address);
        self.s_RBITS_ADDRESS.write(rbits_address);
        self.s_REGISTRY_ADDRESS.write(registry_address);
        self.s_TOGGLE_DIGGING_PERMIT.write('TOGGLE_DIGGING_PERMIT');
        self.s_TOGGLE_BURNING_PERMIT.write('TOGGLE_BURNING_PERMIT');
        self.s_SET_DIG_FEE_PERRMIT.write('SET_DIG_FEE_PERRMIT');
        self.s_SET_DIG_REWARD_PERRMIT.write('SET_DIG_REWARD_PERRMIT');
        self.s_SET_DIG_TOKEN_PERMIT.write('SET_DIG_TOKEN_PERMIT');
        self.s_SET_DIGGER_BPS_PERMIT.write('SET_DIGGER_BPS_PERMIT');
        self.s_WITHDRAW_PERMIT.write('WITHDRAW_PERMIT');
        assert(digger_bps <= 10000, 'Rabbitholes bps must <= 10000');
        self.s_digger_bps.write(digger_bps);
        self.s_dig_token_address.write(dig_token_address);
        self.s_dig_fee.write(dig_fee);
        self.s_dig_reward.write(dig_reward);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BurningToggled: BurningToggled,
        DiggingToggled: DiggingToggled,
        DigFeeChanged: DigFeeChanged,
        DigRewardChanged: DigRewardChanged,
        DigTokenChanged: DigTokenChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct BurningToggled {
        #[key]
        manager: ContractAddress,
        new_state: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct DiggingToggled {
        #[key]
        manager: ContractAddress,
        new_state: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct DigFeeChanged {
        #[key]
        manager: ContractAddress,
        new_fee: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct DigRewardChanged {
        #[key]
        manager: ContractAddress,
        new_reward: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct DigTokenChanged {
        #[key]
        manager: ContractAddress,
        new_token: ContractAddress,
    }

    #[external(v0)]
    impl RabbitholesV1 of super::IRabbitholesV1<ContractState> {
        fn MANAGER_ADDRESS(self: @ContractState) -> ContractAddress {
            self.s_MANAGER_ADDRESS.read()
        }

        fn RBITS_ADDRESS(self: @ContractState) -> ContractAddress {
            self.s_RBITS_ADDRESS.read()
        }

        fn REGISTRY_ADDRESS(self: @ContractState) -> ContractAddress {
            self.s_REGISTRY_ADDRESS.read()
        }

        fn SET_DIGGER_BPS_PERMIT(self: @ContractState) -> felt252 {
            self.s_SET_DIGGER_BPS_PERMIT.read()
        }

        fn SET_DIG_FEE_PERRMIT(self: @ContractState) -> felt252 {
            self.s_SET_DIG_FEE_PERRMIT.read()
        }

        fn SET_DIG_REWARD_PERRMIT(self: @ContractState) -> felt252 {
            self.s_SET_DIG_REWARD_PERRMIT.read()
        }

        fn SET_DIG_TOKEN_PERMIT(self: @ContractState) -> felt252 {
            self.s_SET_DIG_TOKEN_PERMIT.read()
        }

        fn TOGGLE_BURNING_PERMIT(self: @ContractState) -> felt252 {
            self.s_TOGGLE_BURNING_PERMIT.read()
        }

        fn TOGGLE_DIGGING_PERMIT(self: @ContractState) -> felt252 {
            self.s_TOGGLE_DIGGING_PERMIT.read()
        }

        fn WITHDRAW_PERMIT(self: @ContractState) -> felt252 {
            self.s_WITHDRAW_PERMIT.read()
        }

        fn digger_bps(self: @ContractState) -> u16 {
            self.s_digger_bps.read()
        }

        fn dig_fee(self: @ContractState) -> u256 {
            self.s_dig_fee.read()
        }

        fn dig_reward(self: @ContractState) -> u256 {
            self.s_dig_reward.read()
        }

        fn dig_token_address(self: @ContractState) -> ContractAddress {
            self.s_dig_token_address.read()
        }

        fn is_digging(self: @ContractState) -> bool {
            self.s_is_digging.read()
        }

        fn is_burning(self: @ContractState) -> bool {
            self.s_is_burning.read()
        }

        /// write 
        fn burn_rabbit(ref self: ContractState, msg: Array<felt252>, hole_id: u64) {
            assert(self.s_is_burning.read(), 'Rabbitholes: burning closed');
            self.burn_and_send_rbits(hole_id, msg.len().into());

            IRegistryDispatcher {
                contract_address: self.s_REGISTRY_ADDRESS.read()
            }.create_rabbit(get_caller_address(), msg, hole_id);
        }

        fn dig_hole(ref self: ContractState, title: felt252) {
            assert(self.s_is_digging.read(), 'Rabbitholes: digging closed');
            self.charge_dig_fee();
            self.mint_dig_reward();

            IRegistryDispatcher {
                contract_address: self.s_REGISTRY_ADDRESS.read()
            }.create_hole(title, get_caller_address());
        }


        fn set_digger_bps(ref self: ContractState, bps: u16) {
            self.has_valid_permit(self.s_SET_DIGGER_BPS_PERMIT.read());
            assert(bps <= 10000, 'Rabbitholes bps must <= 10000');
            self.s_digger_bps.write(bps);
        }

        fn set_dig_fee(ref self: ContractState, fee: u256) {
            self.has_valid_permit(self.s_SET_DIG_FEE_PERRMIT.read());
            self.s_dig_fee.write(fee);
            self
                .emit(
                    DigFeeChanged {
                        manager: get_caller_address(), new_fee: self.s_dig_fee.read(), 
                    }
                );
        }

        fn set_dig_reward(ref self: ContractState, reward: u256) {
            self.has_valid_permit(self.s_SET_DIG_REWARD_PERRMIT.read());
            self.s_dig_reward.write(reward);
            self
                .emit(
                    DigRewardChanged {
                        manager: get_caller_address(), new_reward: self.s_dig_reward.read(), 
                    }
                );
        }

        fn set_dig_token(ref self: ContractState, token: ContractAddress) {
            self.has_valid_permit(self.s_SET_DIG_TOKEN_PERMIT.read());
            self.s_dig_token_address.write(token);
            self
                .emit(
                    DigTokenChanged {
                        manager: get_caller_address(), new_token: self.s_dig_token_address.read(), 
                    }
                );
        }

        fn toggle_digging(ref self: ContractState) {
            self.has_valid_permit(self.s_TOGGLE_DIGGING_PERMIT.read());
            self.s_is_digging.write(!self.s_is_digging.read());
            self
                .emit(
                    DiggingToggled {
                        manager: get_caller_address(), new_state: self.s_is_digging.read(), 
                    }
                );
        }

        fn toggle_burning(ref self: ContractState) {
            self.has_valid_permit(self.s_TOGGLE_BURNING_PERMIT.read());
            self.s_is_burning.write(!self.s_is_burning.read());
            self
                .emit(
                    BurningToggled {
                        manager: get_caller_address(), new_state: self.s_is_burning.read(), 
                    }
                );
        }

        fn withdraw(ref self: ContractState, amount: u256, to: ContractAddress) {
            self.has_valid_permit(self.s_WITHDRAW_PERMIT.read());
            IERC20Dispatcher {
                contract_address: self.s_dig_token_address.read()
            }.transfer(to, amount);
        }
    }

    #[generate_trait]
    impl InternalImpl of StorageTrait {
        fn burn_and_send_rbits(ref self: ContractState, hole_id: u64, mut cost: u256) {
            cost = cost * 1000000; /// 1e6
            let to_digger = (cost * self.s_digger_bps.read().into()) / 10000;
            let to_burn = cost - to_digger;
            /// transfer rbits from burner to digger
            IERC20Dispatcher {
                contract_address: self.s_RBITS_ADDRESS.read()
            }.transfer_from(get_caller_address(), self.fetch_digger(hole_id), to_digger);
            /// burn the rest
            IERC20Dispatcher {
                contract_address: self.s_RBITS_ADDRESS.read()
            }.burn(get_caller_address(), to_burn);
        }

        fn charge_dig_fee(ref self: ContractState) {
            IERC20Dispatcher {
                contract_address: self.s_dig_token_address.read()
            }.transfer_from(get_caller_address(), get_contract_address(), self.s_dig_fee.read());
        }

        fn fetch_digger(ref self: ContractState, hole_id: u64) -> ContractAddress {
            let mut ids = ArrayTrait::<u64>::new();
            ids.append(hole_id);
            *IRegistryDispatcher {
                contract_address: self.s_REGISTRY_ADDRESS.read()
            }.get_holes(ids).at(0).digger
        }

        fn has_valid_permit(ref self: ContractState, permit: felt252) {
            assert(
                IManagerDispatcher {
                    contract_address: self.s_MANAGER_ADDRESS.read()
                }.has_valid_permit(get_caller_address(), permit),
                'Rabbitholes: invalid permit'
            );
        }

        fn mint_dig_reward(ref self: ContractState) {
            IERC20Dispatcher {
                contract_address: self.s_RBITS_ADDRESS.read()
            }.mint(get_caller_address(), self.s_dig_reward.read());
        }
    }
}
