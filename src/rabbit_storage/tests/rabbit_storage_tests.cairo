use starknet::ContractAddress;

#[abi]
trait IManager {
    #[view]
    fn set_permit(account: ContractAddress, right: felt252, timestamp: u64);
}

#[abi]
trait IRbits {
    #[view]
    fn MINT_RBITS() -> felt252;
    #[view]
    fn BURN_RBITS() -> felt252;
}

#[abi]
trait IHoleRegistry {
    #[view]
    fn DIG_HOLES() -> felt252;
    #[view]
    fn PLACE_RABBITS() -> felt252;
}

#[abi]
trait IRabbitRegistry {
    #[view]
    fn ADD_RABBITS_STORAGE() -> felt252;
    #[view]
    fn BURN_RABBITS() -> felt252;
    #[view]
    fn HOLE_REGISTRY_ADDRESS() -> ContractAddress;
    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress;
    #[view]
    fn RBITS_ADDRESS() -> ContractAddress;
    #[view]
    fn total_rabbits() -> u64;
    #[view]
    fn burn_logs_total() -> u64;
    #[view]
    fn burn_logs(id_: u64) -> ContractAddress;
    #[view]
    fn burn_logs_record(id_: u64) -> u64;
    #[view]
    fn user_stats(user_: ContractAddress) -> u64;
    #[view]
    fn user_rabbits(user_: ContractAddress, start_: u64, step_: u64) -> Array<u64>;
    #[view]
    fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>);
    #[external]
    fn burn_rabbit(hole_id_: u64, msg_: Array<felt252>) -> u64;
    #[external]
    fn add_rabbit_storage(address_: ContractAddress, id_of_first_rabbit_: u64);
}

#[abi]
trait IRabbitStorage {
    #[view]
    fn MANAGER_ADDRESS() -> ContractAddress;
    #[view]
    fn STORAGE_WRITER() -> ContractAddress;
    #[view]
    fn ID_OF_FIRST_RABBIT() -> u64;
    #[view]
    fn is_cold_storage() -> bool;
    #[view]
    fn get_rabbit(rabbit_id_: u64) -> (ContractAddress, u64, Array<felt252>);
    #[external]
    fn toggle_cold_storage();
    #[external]
    fn store_rabbit(
        rabbit_id_: u64,
        hole_id_: u64,
        msg_: Array<felt252>,
        this_burn_log_id_: u64,
        burner_: ContractAddress
    );
}

#[cfg(test)]
mod EntryPoint {
    use manager::manager::Manager;
    use super::IManagerDispatcher;
    use super::IManagerDispatcherTrait;

    use rbits::rbits::Rbits;
    use super::IRbitsDispatcher;
    use super::IRbitsDispatcherTrait;

    use hole_registry::hole_registry::HoleRegistry;
    use super::IHoleRegistryDispatcher;
    use super::IHoleRegistryDispatcherTrait;

    use rabbit_registry::rabbit_registry::RabbitRegistry;
    use super::IRabbitRegistryDispatcher;
    use super::IRabbitRegistryDispatcherTrait;

    use rabbit_storage::rabbit_storage::RabbitStorage;
    use super::IRabbitStorageDispatcher;
    use super::IRabbitStorageDispatcherTrait;

    use starknet::syscalls::deploy_syscall;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_contract_address;
    use starknet::testing::set_block_timestamp;
    use starknet::get_caller_address;
    use debug::PrintTrait;
    use array::ArrayTrait;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use result::ResultTrait;


    fn deploy_suite() -> (
        IManagerDispatcher,
        IRbitsDispatcher,
        IHoleRegistryDispatcher,
        IRabbitRegistryDispatcher,
        IRabbitStorageDispatcher
    ) {
        set_block_timestamp(12345);
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let mut calldata = ArrayTrait::new();
        calldata.append(owner.into());

        let (manager_address, _) = deploy_syscall(
            Manager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let Manager = IManagerDispatcher { contract_address: manager_address };

        let mut calldata = ArrayTrait::new();
        let init_supply_low = 1000_u128;
        let init_supply_high = 0_u128;
        calldata.append(init_supply_low.into());
        calldata.append(init_supply_high.into());
        calldata.append(owner.into());
        calldata.append(manager_address.into());

        let (rbits_address, _) = deploy_syscall(
            Rbits::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let Rbits = IRbitsDispatcher { contract_address: rbits_address };

        let mut calldata = ArrayTrait::new();
        let dig_fee_low = 111_u128;
        let dig_fee_high = 0_u128;
        let dig_reward_low = 222_u128;
        let dig_reward_high = 0_u128;
        let dig_token_address = rbits_address;

        calldata.append(dig_fee_low.into());
        calldata.append(dig_fee_high.into());
        calldata.append(dig_reward_low.into());
        calldata.append(dig_reward_high.into());
        calldata.append(dig_token_address.into());
        calldata.append(rbits_address.into());
        calldata.append(manager_address.into());

        let (hole_registry_address, _) = deploy_syscall(
            HoleRegistry::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let HoleRegistry = IHoleRegistryDispatcher { contract_address: hole_registry_address };

        /// deploy rabbit storage 
        let mut calldata = ArrayTrait::new();
        calldata.append(manager_address.into());
        calldata.append(0_u64.into());
        let (rabbit_storage_address, _) = deploy_syscall(
            RabbitStorage::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let RabbitStorage = IRabbitStorageDispatcher { contract_address: rabbit_storage_address };
        /// deploy rabbit registry 
        let mut calldata = ArrayTrait::new();
        calldata.append(HoleRegistry.contract_address.into());
        calldata.append(Manager.contract_address.into());
        calldata.append(Rbits.contract_address.into());
        calldata.append(RabbitStorage.contract_address.into());

        let (rabbit_registry_address, _) = deploy_syscall(
            RabbitRegistry::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let RabbitRegistry = IRabbitRegistryDispatcher {
            contract_address: rabbit_registry_address
        };

        Manager.set_permit(HoleRegistry.contract_address, Rbits.MINT_RBITS(), 99999);

        (Manager, Rbits, HoleRegistry, RabbitRegistry, RabbitStorage)
    }

    #[test]
    #[available_gas(2000000)]
    fn constructor() {
        let (Manager, Rbits, HoleRegistry, RabbitRegistry, RabbitStorage) = deploy_suite();
        'left here'.print()
    }
}

#[cfg(test)]
mod Internal {
    use rabbit_storage::rabbit_storage::RabbitStorage;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    use starknet::testing::set_block_timestamp;
    use debug::PrintTrait;
    use array::ArrayTrait;
    use traits::Into;
    use traits::TryInto;
    use option::OptionTrait;
    use result::ResultTrait;


    fn _deploy() -> ContractAddress {
        let deployer = contract_address_const::<1>();
        let manager = contract_address_const::<'manager'>();
        set_caller_address(deployer);
        RabbitStorage::constructor(manager, 0_u64);
        deployer
    }

    /// left off here

    #[test]
    #[available_gas(2000000)]
    fn _burn_to_log() {
        /// add multiple rabbits and make sure m_start and m_end return correctly
        /// check each are in the correct slots (]
        /// 0: 'hello', 1: 'world' => (0, 2) _burn_pointer is 2
        /// 2: 'new rabbit' => (2, 3) _burn_pointer is 3
        let mut rabbit = ArrayTrait::new();
        rabbit.append('this is rabbit');
    }

    #[test]
    #[available_gas(2000000)]
    fn _store_rabbit() {}

    #[test]
    #[available_gas(2000000)]
    fn _get_msg_from_log() { /// 
    }


    #[test]
    #[available_gas(2000000)]
    fn _toggle_cold_storage() {}
}

