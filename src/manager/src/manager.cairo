/// contract to store just holes and rabbits
/// manages who can add holes and rabbits (public registry, shovel registry, private registry, etc)

// mimic managerial contract

#[contract]
mod Manager {
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::ContractAddressIntoFelt252;
    use starknet::ContractAddressZeroable;
    use starknet::get_caller_address;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;

    struct Storage {
        // address -> permission hash/sig (e.g. keccak('MINT')) -> timestamp
        permissions: LegacyMap<(ContractAddress, felt252), u64>,
        // permission hash/sig (e.g. keccak('mint')) -> manager hash/sig right (e.g. keccak('MINT MANAGER'))
        managerRights: LegacyMap<felt252, felt252>,
        _ZERO_RIGHT: felt252,
        _MANAGER_RIGHT: felt252,
        // owner of the contract
        _owner: ContractAddress,
    }

    trait IOwnable {
        fn owner() -> ContractAddress;
        fn transfer_ownership(new_owner: ContractAddress);
        fn renounce_ownership();
    }

    #[event]
    fn OwnershipTransferred(previous_owner: ContractAddress, new_owner: ContractAddress) {}

    trait IManager { // events (not in interface)
        //modifer
        #[view]
        fn hasValidPermit() -> bool;
        #[view]
        fn hasRightUntil(account: ContractAddress, right: felt252) -> u64;
        #[external]
        fn setPermit(account: ContractAddress, right: felt252, timestamp: u64);
        #[external]
        fn setManagerRight(right: felt252, manager_right: felt252);
    }

    #[event]
    fn PermitUpdated(
        updator: ContractAddress, updatee: ContractAddress, right: felt252, timestamp: u64
    ) {}

    #[event]
    fn ManagementUpdated(
        manager: ContractAddress, managed_right: felt252, manager_right: felt252
    ) {}

    /// Manager ///
    impl ManagerImpl of IManager {
        fn hasValidPermit() -> bool {
            // let caller = get_caller_address();
            // let right = get_selector();
            // let timestamp = _storage::permissions::get((caller, right));
            // return timestamp > 0 && timestamp < block_timestamp();
            return false;
        }

        fn hasRightUntil(account: ContractAddress, right: felt252) -> u64 {
            // return permissions::read((account, right));
            return 0_u64;
        }

        fn setPermit(account: ContractAddress, right: felt252, timestamp: u64) { // _only_owner();
        // _storage::permissions::set((account, right), timestamp);
        // PermitUpdated(get_caller_address(), account, right, timestamp);
        }

        fn setManagerRight(right: felt252, manager_right: felt252) { // _only_owner();
        // _storage::managerRights::set(right, manager_right);
        // ManagementUpdated(get_caller_address(), right, manager_right);
        }
    }

    #[view]
    fn hasValidPermit() -> bool {
        ManagerImpl::hasValidPermit()
    }

    #[view]
    fn hasRightUntil(account: ContractAddress, right: felt252) -> u64 {
        ManagerImpl::hasRightUntil(account, right)
    }

    #[external]
    fn setPermit(account: ContractAddress, right: felt252, timestamp: u64) {
        ManagerImpl::setPermit(account, right, timestamp);
    }

    #[external]
    fn setManagerRight(right: felt252, manager_right: felt252) {
        ManagerImpl::setManagerRight(right, manager_right);
    }

    /// Ownable ///
    impl OwnableImpl of IOwnable {
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
            OwnershipTransferred(prev_owner, new_owner);
        }
    }

    #[constructor]
    fn constructor(owner_: ContractAddress) {
        OwnableImpl::transfer_ownership(owner_);

        _ZERO_RIGHT::write(0x0);
        _MANAGER_RIGHT::write(0x999); // to do, needs to be max felt252
    /// loop add any known manager rights here as well (minter/burner for rbits,)
    }

    #[view]
    fn owner() -> ContractAddress {
        OwnableImpl::owner()
    }

    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        OwnableImpl::transfer_ownership(new_owner);
    }

    #[external]
    fn renounce_ownership() {
        OwnableImpl::renounce_ownership();
    }

    fn _only_owner() {
        assert(get_caller_address() == _owner::read(), 'RBITS::Caller not owner');
    }

    fn _transfer_ownership(new_owner: ContractAddress) {
        _owner::write(new_owner);
    }
}
