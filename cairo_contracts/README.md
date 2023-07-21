# RabbitHoles - Cairo Contracts

## Core

### Manager Contract

This contract serves as a permit control system for users and contracts. It allows other contracts to limit function calls to specific permit holders using a deployed instance of this contract. The contract owner manages these permits and can issue them to users as required. The permits fall into two categories: regular and sudo.

A regular permit grants a user access to functions that require it. On the other hand, a sudo permit gives a user the authority to issue regular permits. The contract owner and any user with a `SUDO_PERMIT` can bind regular permits to sudo permits.

#### Example Usages

For these examples, we'll assume a contract requires a `MINT_PERMIT` to call its mint function as follows:

> `assert(ManagerContract.has_valid_permit(get_caller_address(), 'MINT_PERMIT') == true, 'Reason: invalid permit')`

##### Basic Permits

- The contract owner issues Alice a `MINT_PERMIT`

In this case, only Alice and the owner can mint tokens.

##### Sudo Permits

- The contract owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- The contract owner issues a `SUDO_MINT_PERMIT` to Sudoer
- Sudoer issues `MINT_PERMITs` to Alice & Bob

In this scenario, Alice, Bob, and the contract owner can mint tokens. Meanwhile, only Sudoer and the owner can issue `MINT_PERMITs`.

##### Sudo Permit Managers

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

> While the examples above apply specifically to the contract's mint function, this permit abstraction can be made more specific or complex. Here are some examples:
>
> - Sharing permits: Multiple functions might require the same permit. For example, both `set_royalty_bps()` & `set_royalty_receiver()` functions might require `ROYALTY_PERMITs`. Any user holding this permit may call both functions.
> - Multi-access sudoers: More than one permit could be bound to the same sudo permit, such as `SET_TOKEN_URI_PERMIT` & `SET_CONTRACT_URI_PERMIT` -> `SUDO_URI_PERMIT`. Users with this sudo permit can issue both `SET_TOKEN/CONTRACT_URI_PERMITs`.
> - Multi-access managers: Several sudo permits could be bound to the same manager permit. For instance, `SUDO_ROYALTY_PERMIT` & `SUDO_URI_PERMIT` could both be bound to `ARTIST_PERMIT`. With this, artists can issue `SUDO_ROYALTY/URI_PERMITs`, allowing recipients to then issue both `SET_ROYALTY_BPS/RECEIVER_PERMITs` and `SET_TOKEN/CONTRACT_URI_PERMITs`.

### ERC20

This is a standard ERC20 contract that references an instance of the Manager contract for minting & burning permissions. To mint tokens, a user or contract must have a `MINT_PERMIT`, and to burn tokens, they must have a `BURN_PERMIT`.

### Registry

This contract handles the logic for the creation and storage of Holes & Rabbits, also referencing the Manager contract instance for these permissions. A `CREATE_HOLE_PERMIT` & `CREATE_RABBIT_PERMIT` are required to create Holes & Rabbits respectively. There are no fees/rewards associated with this contract, that logic is intended to come from contracts with `CREATE_HOLE/RABBIT_PERMITs`. This structure allows the project to be extended with fewer restrictions.

##### Theoretical extensions

- A Shovel NFT collection is released that allows owners to dig holes at a discount and receive bigger `dig_rewards`
- RabbitholesV1_Shovel is deployed, handling the logic for this discount, reward & ownership verification
- With the neccessary permits, V1 & V1_Shovel are operating synchronously

...

- Months later a V2 is drafted, introducing public/private holes
- A vote takes place, V1 & V1_Shovel are disabled, and V2 is deployed using the same core contracts (Manager, ERC20, Registry)

#### Creating a Hole

A Hole is created using a `title`. This title is the topic for the Hole's discussion, and is stored in the contract as a `felt252`. This means the title must be 31 characters or less.

#### Creating a Rabbit

A Rabbit is created using a `hole_id` & a `msg`, this Hole must already exist, and the msg is a user's comment in the Hole's discussion. The `msg` is an array of `felt252s`, and the length of this array is referred to as the Rabbit's `depth`. Once a Rabbit is placed in a Hole, the Hole's digs are incremented by 1, and its depth is increased by the Rabbit's depth (global and user stats are handled as well).

### RabbitholesV1

This contract is the first implementation of Rabbitholes.

#### Digging a Hole

- To dig a Hole, a user must pay the `dig_fee` (using the `dig_token`, $ETH, $STRK, etc.)
- Digging a hole mints the digger $RBITS (`dig_reward`)

#### Burning a Rabbit

- To burn a Rabbit, a user will spend some of their $RBITS

  - The amount of $RBITS a Rabbit will cost is equal to its depth (the number of `felt252s` the Rabbit's msg spans)
  - i.e. "If this was a msg I wanted to leave in a hole", it would span across two felts:
  - 45 characters == 2 `felt252s` -> <31chars>, <14 chars>
    - `['If this was a msg I wanted to l', 'eave in a hole']`

- Using the `digger_bps (0 <= digger_bps <= 10,000)`, some $RBITS are transfered to the Hole's digger, and the rest are burned
  - In the above example, if the `digger_bps` is 2,500 (`2500/10000 == 25%`), the msg will cost 2.000000 $RBITS; 0.500000 are sent to the Hole's digger, and 1.500000 are burned

#### Statistics are stored in this contract as such:

- holes: The number of holes dug (globally or by a user)
- rabbits: The number of rabbits left (globally or by a user)
- depth: The total length of rabbit msgs left (globally or by a user)

#### Along with lookup tables for returning:

- A user's holes or rabbits based on an array of indexes (return a user's 1st & 2nd `Hole` or a user's 8th, 9th, & 10th `Rabbit`)

## Commands

- `scarb build` creates the sierra.json files for the suite
- `scarb test` runs `core` & `V1` tests
- `scarb fmt` cleans spacing in all .cairo files
