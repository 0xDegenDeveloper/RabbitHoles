use starknet::ContractAddress;

#[starknet::interface]
trait IRegistry<TContractState> {
    /// read
    fn MANAGER_ADDRESS(self: @TContractState) -> ContractAddress;
    fn CREATE_HOLE_PERMIT(self: @TContractState) -> felt252;
    fn CREATE_RABBIT_PERMIT(self: @TContractState) -> felt252;
    fn title_to_id(self: @TContractState, title: felt252) -> u64;
    fn get_holes(self: @TContractState, ids: Array<u64>) -> Array<Registry::Hole>;
    fn get_rabbits(self: @TContractState, ids: Array<u64>) -> Array<Registry::RabbitHot>;
    fn get_rabbits_in_hole(
        self: @TContractState, hole_id: u64, indexes: Array<u64>
    ) -> Array<Registry::RabbitHot>;
    fn get_user_holes(
        self: @TContractState, user: ContractAddress, indexes: Array<u64>
    ) -> Array<Registry::Hole>;
    fn get_user_rabbits(
        self: @TContractState, user: ContractAddress, indexes: Array<u64>
    ) -> Array<Registry::RabbitHot>;
    fn get_user_stats(
        self: @TContractState, users: Array<ContractAddress>
    ) -> Array<Registry::Stats>;
    fn get_global_stats(self: @TContractState) -> Registry::Stats;
    /// write
    fn create_hole(ref self: TContractState, title: felt252, digger: ContractAddress);
    fn create_rabbit(
        ref self: TContractState, burner: ContractAddress, msg: Array<felt252>, hole_id: u64
    );
}

#[starknet::contract]
mod Registry {
    use array::ArrayTrait;
    use rabbitholes::{core::manager::{IManager, IManagerDispatcherTrait, IManagerDispatcher}};
    use starknet::{
        get_block_timestamp, get_caller_address, contract_address_const, ContractAddress,
        ContractAddressIntoFelt252, StorageAccess, storage_address_from_base_and_offset,
        StorageBaseAddress, SyscallResult, storage_read_syscall, storage_write_syscall,
        Felt252TryIntoContractAddress
    };
    use core::integer;
    use option::Option;
    use traits::{Into, TryInto};
    use zeroable::Zeroable;

    #[storage]
    struct Storage {
        s_MANAGER_ADDRESS: ContractAddress,
        s_CREATE_HOLE_PERMIT: felt252,
        s_CREATE_RABBIT_PERMIT: felt252,
        s_total_holes: u64,
        s_total_rabbits: u64,
        s_total_depth: u64,
        s_holes: LegacyMap<u64, Hole>,
        s_rabbits: LegacyMap<u64, RabbitCold>,
        s_stats: LegacyMap<ContractAddress, Stats>,
        s_titles_to_ids: LegacyMap<felt252, u64>,
        s_msg_log: LegacyMap<u64, felt252>,
        s_the_rabbit_hole: LegacyMap<(u64, u64), u64>,
        s_user_holes_table: LegacyMap<(ContractAddress, u64), u64>,
        s_user_rabbits_table: LegacyMap<(ContractAddress, u64), u64>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, manager_address: ContractAddress) {
        self.s_MANAGER_ADDRESS.write(manager_address);
        self.s_CREATE_HOLE_PERMIT.write('CREATE_HOLE_PERMIT');
        self.s_CREATE_RABBIT_PERMIT.write('CREATE_RABBIT_PERMIT');
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        HoleCreated: HoleCreated,
        RabbitCreated: RabbitCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct HoleCreated {
        #[key]
        creator: ContractAddress,
        #[key]
        digger: ContractAddress,
        title: felt252,
        id: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct RabbitCreated {
        #[key]
        creator: ContractAddress,
        #[key]
        burner: ContractAddress,
        depth: u64,
        id: u64,
    }

    #[derive(Serde, Copy, Drop, storage_access::StorageAccess)]
    struct Hole {
        digger: ContractAddress,
        timestamp: u64,
        digs: u64,
        depth: u64,
        title: felt252,
        index: u64,
    }

    #[derive(Serde, Copy, Drop, storage_access::StorageAccess)]
    struct RabbitCold {
        burner: ContractAddress,
        m_start: u64,
        depth: u64,
        timestamp: u64,
        hole_id: u64,
    }

    #[derive(Serde, Drop)]
    struct RabbitHot {
        burner: ContractAddress,
        msg: Array<felt252>,
        timestamp: u64,
        hole_id: u64,
        index: u64,
    }

    #[derive(Serde, Copy, Drop, storage_access::StorageAccess)]
    struct Stats {
        holes: u64,
        rabbits: u64,
        depth: u64,
    }

    #[external(v0)]
    impl Registry of super::IRegistry<ContractState> {
        /// read
        fn MANAGER_ADDRESS(self: @ContractState) -> ContractAddress {
            self.s_MANAGER_ADDRESS.read()
        }

        fn CREATE_HOLE_PERMIT(self: @ContractState) -> felt252 {
            self.s_CREATE_HOLE_PERMIT.read()
        }

        fn CREATE_RABBIT_PERMIT(self: @ContractState) -> felt252 {
            self.s_CREATE_RABBIT_PERMIT.read()
        }

        fn get_holes(self: @ContractState, ids: Array<u64>) -> Array<Hole> {
            let mut res = ArrayTrait::<Hole>::new();
            let mut i = 0;
            loop {
                if (i >= ids.len()) {
                    break ();
                }
                res.append(self.s_holes.read(*ids.at(i)));
                i += 1;
            };
            res
        }

        fn get_rabbits(self: @ContractState, ids: Array<u64>) -> Array<RabbitHot> {
            let mut res = ArrayTrait::<RabbitHot>::new();
            let mut i = 0;
            loop {
                if (i >= ids.len()) {
                    break ();
                }
                res.append(self.fetch_rabbit(*ids.at(i)));
                i += 1;
            };
            res
        }

        fn get_rabbits_in_hole(
            self: @ContractState, hole_id: u64, indexes: Array<u64>
        ) -> Array<RabbitHot> {
            let hole = self.s_holes.read(hole_id);
            let mut res = ArrayTrait::<RabbitHot>::new();
            let mut i = 0;
            loop {
                if (i >= indexes.len()) {
                    break ();
                }
                res
                    .append(
                        self.fetch_rabbit(self.s_the_rabbit_hole.read((hole_id, *indexes.at(i))))
                    );
                i += 1;
            };
            res
        }

        fn get_user_rabbits(
            self: @ContractState, user: ContractAddress, indexes: Array<u64>
        ) -> Array<RabbitHot> {
            let mut res = ArrayTrait::<RabbitHot>::new();
            let mut i = 0;
            loop {
                if (i >= indexes.len()) {
                    break ();
                }
                res
                    .append(
                        self.fetch_rabbit(self.s_user_rabbits_table.read((user, *indexes.at(i))))
                    );
                i += 1;
            };
            res
        }

        fn get_user_holes(
            self: @ContractState, user: ContractAddress, indexes: Array<u64>
        ) -> Array<Hole> {
            let mut res = ArrayTrait::<Hole>::new();
            let mut i = 0;
            loop {
                if (i >= indexes.len()) {
                    break ();
                }
                res.append(self.s_holes.read(self.s_user_holes_table.read((user, *indexes.at(i)))));
                i += 1;
            };
            res
        }

        fn get_user_stats(self: @ContractState, users: Array<ContractAddress>) -> Array<Stats> {
            let mut res = ArrayTrait::<Stats>::new();
            let mut i = 0;
            loop {
                if (i >= users.len()) {
                    break ();
                }
                res.append(self.s_stats.read((*users.at(i))));
                i += 1;
            };
            res
        }

        fn get_global_stats(self: @ContractState) -> Stats {
            Stats {
                holes: self.s_total_holes.read(),
                rabbits: self.s_total_rabbits.read(),
                depth: self.s_total_depth.read(),
            }
        }

        fn title_to_id(self: @ContractState, title: felt252) -> u64 {
            self.s_titles_to_ids.read(title)
        }

        /// write
        fn create_hole(ref self: ContractState, title: felt252, digger: ContractAddress) {
            self.has_valid_permit(self.s_CREATE_HOLE_PERMIT.read());
            assert(self.s_titles_to_ids.read(title).is_zero(), 'Registry: hole already dug');

            self.create_hole_helper(title, digger);
        }

        fn create_rabbit(
            ref self: ContractState, burner: ContractAddress, msg: Array<felt252>, hole_id: u64
        ) {
            self.has_valid_permit(self.s_CREATE_RABBIT_PERMIT.read());
            assert(hole_id.is_non_zero(), 'Registry: invalid hole id');
            assert(hole_id <= self.s_total_holes.read(), 'Registry: invalid hole id');

            self.create_rabbit_helper(burner, msg, hole_id);
        }
    }

    #[generate_trait]
    impl InternalImpl of StorageTrait {
        fn fetch_rabbit(self: @ContractState, id: u64) -> RabbitHot {
            let rabbit = self.s_rabbits.read(id);
            RabbitHot {
                burner: rabbit.burner,
                msg: self.fetch_msg(id),
                timestamp: rabbit.timestamp,
                hole_id: rabbit.hole_id,
                index: id
            }
        }

        fn fetch_msg(self: @ContractState, rabbit_id: u64) -> Array<felt252> {
            let m_start = self.s_rabbits.read(rabbit_id).m_start;
            let mut m_len = self.s_rabbits.read(rabbit_id).depth;
            let mut res = ArrayTrait::<felt252>::new();

            let mut i = 0;
            loop {
                if (i >= m_len) {
                    break ();
                }
                res.append(self.s_msg_log.read(m_start + i));
                i += 1;
            };
            res
        }

        fn write_msg(ref self: ContractState, msg: Array<felt252>) -> (u64, u64) {
            let mut i = 0;
            let m_len: u64 = msg.len().into();
            let m_start = self.s_total_depth.read();
            loop {
                if (i.into() >= m_len) {
                    break ();
                }
                let slot = m_start + i.into();
                self.s_msg_log.write(slot, *msg.at(i));
                i += 1;
            };
            (m_start, m_len)
        }

        fn create_hole_helper(ref self: ContractState, title: felt252, digger: ContractAddress, ) {
            let mut stats = self.s_stats.read(digger);
            let id = self.s_total_holes.read() + 1;
            self.s_titles_to_ids.write(title, id);
            self.s_total_holes.write(id);
            self
                .s_holes
                .write(
                    id,
                    Hole {
                        digger,
                        timestamp: get_block_timestamp(),
                        digs: 0,
                        depth: 0,
                        title,
                        index: id
                    }
                );
            stats.holes += 1;
            self.s_user_holes_table.write((digger, stats.holes), id);
            self.s_stats.write(digger, stats);

            self.emit(HoleCreated { creator: get_caller_address(), digger, title, id });
        }

        fn create_rabbit_helper(
            ref self: ContractState, burner: ContractAddress, msg: Array<felt252>, hole_id: u64
        ) {
            let mut hole = self.s_holes.read(hole_id);
            let mut stats = self.s_stats.read(burner);
            let id = self.s_total_rabbits.read() + 1;
            let (m_start, depth) = self.write_msg(msg);

            hole.digs += 1;
            hole.depth += depth;
            stats.rabbits += 1;
            stats.depth += depth;

            self.s_the_rabbit_hole.write((hole_id, hole.digs), id);
            self.s_total_depth.write(m_start + depth);
            self.s_total_rabbits.write(id);
            self.s_user_rabbits_table.write((burner, stats.rabbits), id);
            self.s_holes.write(hole_id, hole);
            self.s_stats.write(burner, stats);
            self
                .s_rabbits
                .write(
                    id,
                    RabbitCold { burner, m_start, depth, timestamp: get_block_timestamp(), hole_id }
                );

            self.emit(RabbitCreated { creator: get_caller_address(), burner, depth, id });
        }

        fn has_valid_permit(ref self: ContractState, permit: felt252) {
            assert(
                IManagerDispatcher {
                    contract_address: self.s_MANAGER_ADDRESS.read()
                }.has_valid_permit(get_caller_address(), permit),
                'Registry: invalid permit'
            );
        }
    }
}
