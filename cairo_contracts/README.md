# RabbitHoles - Cairo Contracts

## Core

### Manager Contract

This contract serves as a permit control system for users and contracts. It allows other contracts to limit function calls to specific permit holders using a deployed instance of this contract. The contract owner manages these permits and can issue them to users as needed. The permits fall into two categories: regular and sudo.

A regular permit grants a user access to functions that require it. And on the other hand, a sudo permit gives a user the authority to issue regular permits. The contract owner and any user with a `SUDO_PERMIT` can bind regular permits to sudo permits. The `has_valid_permit()` function will always return true for the contract owner.

#### Example Usages

For these examples, we'll assume a contract requires a `MINT_PERMIT` to call its mint function as follows:

> `let Manager =  IManagerDispatcher {contract_address: self.s_MANAGER_ADDRESS.read()}`

> `assert(Manager.has_valid_permit(get_caller_address(), 'MINT_PERMIT') == true, 'Reason: invalid permit')`

##### Basic Permit

- The (Manager) contract owner issues Alice a `MINT_PERMIT`

In this case, only Alice and the owner can mint tokens.

##### Sudo Permit

- The contract owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- The contract owner issues a `SUDO_MINT_PERMIT` to Sudoer
- Sudoer issues `MINT_PERMITs` to Alice & Bob

In this scenario, Alice, Bob, and the contract owner can mint tokens. Meanwhile, only Sudoer and the owner can issue `MINT_PERMITs`.

##### Sudo Permit Manager

- The contract owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- The contract owner binds `SUDO_MINT_PERMIT` -> `SUDO_MINT_MANAGER`
- The contract owner issues a `SUDO_MINT_MANAGER` permit to a Manager
- The Manager issues `SUDO_MINT_PERMITs` to Sudoer1 & Sudoer2
- Sudoer1 issues Alice a `MINT_PERMIT` & Sudoer2 issues Bob a `MINT_PERMIT`

In this example, Alice, Bob, and the contract owner are the only users able to mint tokens. Sudoer1, Sudoer2, and the contract owner are the only users who can issue `MINT_PERMITs`. And only the Manager and contract owner can issue `SUDO_MINT_PERMITs`.

##### Binding Permits to Sudo Permits

- The contract owner issues the Manager a `SUDO_PERMIT`

Here, only the Manager and contract owner are capable of binding `XYZ_PERMIT` -> `SUDO_XYZ`.

###### Note

> The values for these permits are represented as `felt252s` and are arbitrary (except for the `SUDO_PERMIT`). For example, a contract could require an `asdf` permit to call a function. The contract owner (or `SUDO_PERMIT` holders) may bind `asdf` -> `jkl;` & `jkl;` -> `asdfjkl;` to implement the scenarios described above.

##### Advanced Scenarios

> While the examples above apply specifically to the contract's mint function, this permit abstraction can be made more specific and complex. Here are some examples:
>
> - Sharing permits: Multiple functions might require the same permit. For example, both `set_royalty_bps()` & `set_royalty_receiver()` functions might require `ROYALTY_PERMITs`. Any user holding this permit may call both functions.
> - Multi-access sudoers: More than one permit could be bound to the same sudo permit, such as `SET_TOKEN_URI_PERMIT` & `SET_CONTRACT_URI_PERMIT` -> `SUDO_URI_PERMIT`. Users with this sudo permit can issue both `SET_TOKEN/CONTRACT_URI_PERMITs`.
> - Multi-access managers: Several sudo permits could be bound to the same manager permit. For instance, `SUDO_ROYALTY_PERMIT` & `SUDO_URI_PERMIT` could both be bound to `ARTIST_PERMIT`. With this, artists can issue `SUDO_ROYALTY/URI_PERMITs`, allowing recipients to then issue both `ROYALTY_PERMITs` and `URI_PERMITs`.

### ERC20

This is a standard ERC20 contract that references an instance of the Manager contract for minting & burning permissions. To mint tokens, a user or contract must have a `MINT_PERMIT`, and to burn tokens, they must have a `BURN_PERMIT`.

### Registry

This contract handles the logic for the creation and storage of Holes & Rabbits, also referencing the Manager contract instance for these permissions. A `CREATE_HOLE_PERMIT` & `CREATE_RABBIT_PERMIT` are required to create Holes & Rabbits respectively on befalf of users. There are no fees/rewards associated with this contract, that logic is intended to come from contracts with `CREATE_HOLE/RABBIT_PERMITs`. This structure allows the project to be extended with fewer restrictions.

##### Theoretical extensions

- A Shovel NFT collection is released that allows owners to dig holes at a discount and receive bigger `dig_rewards`
- RabbitholesV1_Shovel is deployed, handling this discount, reward, and ownership verification logic
- With the neccessary permits, V1 & V1_Shovel are operating synchronously

...

- Months later a V2 is drafted, introducing public/private holes
- A vote takes place, V1 & V1_Shovel are disabled, and V2 is deployed using the same core contracts (Manager, ERC20, Registry)

#### Creating a Hole

A Hole is created using a `title`. This title is the topic for the Hole's discussion, and is stored in the contract as a `felt252`. This means the title must be 31 characters or less.

#### Creating a Rabbit

A Rabbit is created using a `hole_id` & a `msg`, this Hole must already exist, and the msg is a user's comment in the Hole's discussion. The `msg` is an array of `felt252s`, and the length of this array is referred to as the Rabbit's `depth`. Once a Rabbit is placed in a Hole, the Hole's digs are incremented by 1, and its depth is increased by the Rabbit's depth (global and user stats are handled as well).

#### Statistics are stored as such:

- holes: The number of holes dug (globally or by a user)
- rabbits: The number of rabbits left (globally or by a user)
- depth: The total length of rabbit msgs left (globally or by a user)

#### Along with lookup tables for:

- The holes or rabbits created by a user based on an array of indexes (return a user's 1st & 2nd `Hole` or their 8th, 9th, & 10th `Rabbit`)
- The rabbits in a hole based on an array of indexes (return a hole's 1st, 2nd, & 10th `Rabbit`)

### RabbitHolesV1

This contract is the first implementation of RabbitHoles.

#### Digging a Hole

- To dig a Hole, a user must pay the `dig_fee` (using the `dig_token`, $ETH, $STRK, etc.)
- Digging a hole mints the digger $RBITS (`dig_reward`)

#### Burning a Rabbit

- To burn a Rabbit, a user will spend some of their $RBITS

  - The amount of $RBITS a Rabbit will cost is equal to its depth (the number of `felt252s` the Rabbit's msg spans)
  - i.e. "If this was a msg I wanted to leave in a hole", it would span across two felts:
  - 45 characters == 2 `felt252s` -> <31chars>, <14 chars>
    - `['If this was a msg I wanted to l', 'eave in a hole']`

- Using the `digger_bps` (0 <= `digger_bps` <= 10,000), some $RBITS are transfered to the Hole's digger, and the rest are burned
  - In the above example, if the `digger_bps` is 2,500 (`2500/10000 == 25%`), the msg will cost 2.000000 $RBITS; 0.500000 are sent to the Hole's digger, and 1.500000 are burned

## Dev

### Commands

- `scarb build` creates the sierra.json files for the suite
- `scarb test` runs `core` & `V1` tests
- `scarb fmt` cleans spacing in all .cairo files

### Declare

`starkli declare --account $STARKNET_ACCOUNT target/dev/<target.json> --rpc $STARKNET_GOERLI_RPC --keystore $STARKNET_SIGNER --compiler-version 2.0.1`

### Deploy

> `starkli deploy <class_hash> <args> --account $STARKNET_ACCOUNT --rpc $STARKNET_GOERLI_RPC --keystore $STARKNET_SIGNER`

### Params

#### Manager:

> <class_hash> == `0x0209ff8a5a1dfef1fd365ca5d2f7bad09c37ff995d19917e7ebd33f6e4543165`

> <args> == `284853202282316910755836087987553145089895892383786529501944231852568436737` (owner)

> deployed at: `0x026a60f9b16975e44c11550c2baff45ac4c52d399cdccab5532dccc73ffa3298`

#### ERC20:

> <class_hash> == `0x05acbcb27c044d194cc3da98272eba78b8122456233dde5759fdd3db1449e08b`

> <args> == `1092580785392713095075232812540319657223439146213786134614021612951427494552 99591801629484114175092083 353299420243 6 1000000000 0 284853202282316910755836087987553145089895892383786529501944231852568436737` (manager_address, name, symbol, decimals, initial_supply_lower, initial_supply_upper, receiver)

> deployed at: `0x06a3e59fce87072a652e7d67df0782e89b337b65ff50f1d8553e990dd3c95cef`

#### Registry:

> <clash_hash> == `0x07aae7e07189c0a39d2c2475062bbac1ea558fdbf62a531fb8a141dad955b92f`

> <args> == `1092580785392713095075232812540319657223439146213786134614021612951427494552` (manager_address)

> deployed at: `0x026377bcc9b973eae8500eca7f916e42a645ffd4b15146e62b69e57e958502fc`

#### V1

> <clash_hash> == `0x043ffae7dd9b18e2318f6d9355596e38af133f8b949a3ed80cad8f2e88ecfba6`

> <args> == `1092580785392713095075232812540319657223439146213786134614021612951427494552 3003457971353289469238991866356045131336341321679831255126448961467567398127 1080369954108895810355668535768540353512322402048349022580986615052531729148 2087021424722619777119509474943472645767659996348769578120564519014510906823 5000 10000000 0 20000000 0` (manager_address, rbits_address, registry_address, dig_token_address, digger_bps, dig_fee_lower, dig_fee_upper, dig_reward_lower, dig_reward_upper)

> deployed at: `0x01c8ca977ca1c5721fb5150f63b1ae5b75e6155ef9b4e0f19acc9082d8c7fff3`

### Post deployment

#### Issue permits through Manager contract

- V1 -> `CREATE_HOLE_PERMIT` (5864518367455677081700114700087541139065172), `CREATE_RABBIT_PERMIT` (384337075729575254014235448159253223033088592212), `MINT_PERMIT` (93433465789279960535222612), `BURN_PERMIT`, (80192023525944205966657876)

#### Toggle bool values

- RBITS -> `toggle_minting()`, `toggle_burning()`
- Registry -> `toggle_hole_creation()`, `toggle_rabbit_creation()`
