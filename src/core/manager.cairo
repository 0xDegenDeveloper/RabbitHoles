use starknet::ContractAddress;

#[starknet::interface]
trait IManager<TContractState> {
    /// Reads
    fn MANAGER_PERMIT(self: @TContractState) -> felt252;
    fn has_permit_until(self: @TContractState, account: ContractAddress, permit: felt252) -> u64;
    fn has_valid_permit(self: @TContractState, account: ContractAddress, permit: felt252) -> bool;
    fn manager_permits(self: @TContractState, permit: felt252) -> felt252;
    fn owner(self: @TContractState) -> ContractAddress;
    /// Writes
    fn renounce_ownership(ref self: TContractState);
    fn set_permit(
        ref self: TContractState, account: ContractAddress, permit: felt252, timestamp: u64
    );
    fn set_sudo_permit(ref self: TContractState, permit: felt252, sudo_permit: felt252);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::contract]
mod Manager {
    use starknet::{
        ContractAddress, contract_address_const, get_block_timestamp, get_caller_address
    };

    #[storage]
    struct Storage {
        s_MANAGER_PERMIT: felt252,
        s_owner: ContractAddress,
        s_permits: LegacyMap<(ContractAddress, felt252), u64>,
        s_sudo_permits: LegacyMap<felt252, felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred,
        PermitIssued: PermitIssued,
        SudoPermitIssued: SudoPermitIssued,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PermitIssued {
        #[key]
        permit_granter: ContractAddress,
        #[key]
        permit_receiver: ContractAddress,
        #[key]
        permit: felt252,
        timestamp: u64
    }

    #[derive(Drop, starknet::Event)]
    struct SudoPermitIssued {
        #[key]
        manager: ContractAddress,
        #[key]
        permit: felt252,
        #[key]
        sudo_permit: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, _owner: ContractAddress) {
        self.write_owner(_owner);
        self.s_MANAGER_PERMIT.write('MANAGER');
    }

    #[external(v0)]
    impl Manager of super::IManager<ContractState> {
        /// Reads
        fn MANAGER_PERMIT(self: @ContractState) -> felt252 {
            self.s_MANAGER_PERMIT.read()
        }

        fn has_permit_until(
            self: @ContractState, account: ContractAddress, permit: felt252
        ) -> u64 {
            self.s_permits.read((account, permit))
        }

        fn has_valid_permit(
            self: @ContractState, account: ContractAddress, permit: felt252
        ) -> bool {
            self.has_valid_permit_helper(account, permit)
        }

        fn manager_permits(self: @ContractState, permit: felt252) -> felt252 {
            self.s_sudo_permits.read(permit)
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self.s_owner.read()
        }

        /// Writes
        fn renounce_ownership(ref self: ContractState) {
            self.only_owner();
            let zero_address = contract_address_const::<0>();
            self.write_owner(zero_address);
            self
                .emit(
                    OwnershipTransferred {
                        prev_owner: get_caller_address(), new_owner: zero_address
                    }
                );
        }

        fn set_permit(
            ref self: ContractState, account: ContractAddress, permit: felt252, timestamp: u64
        ) {
            let caller = get_caller_address();
            assert(permit != 0x0, 'Manager: Setting zeroed permit');
            assert(
                self.has_valid_permit_helper(caller, self.s_sudo_permits.read(permit)),
                'Manager: invalid sudo permit'
            );
            self.s_permits.write((account, permit), timestamp);
            self
                .emit(
                    PermitIssued {
                        permit_granter: caller, permit_receiver: account, permit, timestamp
                    }
                );
        }

        fn set_sudo_permit(ref self: ContractState, permit: felt252, sudo_permit: felt252) {
            assert(
                self.has_valid_permit_helper(get_caller_address(), self.s_MANAGER_PERMIT.read()),
                'Manager: Caller non manager'
            );
            self.s_sudo_permits.write(permit, sudo_permit);
            self.emit(SudoPermitIssued { manager: get_caller_address(), permit, sudo_permit });
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.only_owner();
            assert(new_owner != contract_address_const::<0>(), 'Manager: false renouncement');
            self.write_owner(new_owner);
            self.emit(OwnershipTransferred { prev_owner: get_caller_address(), new_owner });
        }
    }

    #[generate_trait]
    impl StorageImpl of StorageTrait {
        fn has_valid_permit_helper(
            self: @ContractState, account: ContractAddress, permit: felt252
        ) -> bool {
            if (account == self.s_owner.read()) {
                return true;
            }
            if (self.s_permits.read((account, permit)) > get_block_timestamp()) {
                return true;
            }
            false
        }

        fn only_owner(ref self: ContractState) {
            assert(get_caller_address() == self.s_owner.read(), 'Manager: caller not owner');
        }

        fn write_owner(ref self: ContractState, new_owner: ContractAddress) {
            self.s_owner.write(new_owner);
        }
    }
}
/// -------------------- tests --------------------


