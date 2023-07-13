# Cairo Contracts

## Core

### Manager

The Manager contract controls permits for users. Other contracts can reference this contract to restrict function calls to specific permit holders. These permits are controlled by the owner of the contract and can be issued to users as needed. There are essentially two types of permits, regular and sudo. A regular permit allows its holder access to functions requiring it. A sudo permits allows its holder to issue regular permits. The owner and users with a `SUDO_PERMIT` have the ability to bind regular permits -> sudo permits.

#### Example usages

For these examples, assume a contract requires a `MINT_PERMIT` to call its mint funciton

##### Basic permits

- Owner issues Alice a `MINT_PERMIT`

Alice & Owner are the only users able to mint in this scenario.

##### Sudo permits

- Owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- Owner issues a `SUDO_MINT_PERMIT` to Sudoer
- Sudoer issues `MINT_PERMITs` to Alice & Bob

In this scenario Bob, Alice, & Owner are the only users able to mint. Sudoer & Owner are the only ones able to issue `MINT_PERMITs`.

##### Sudo permit managers

- Owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- Owner binds `SUDO_MINT_PERMIT` -> `SUDO_MINT_MANAGER`
- Owner issues a `SUDO_MINT_MANAGER` permit to Manager
- Manager issues `SUDO_MINT_PERMITs` to Sudoer1 & Sudoer2
- Sudoer1 issues Alice a `MINT_PERMIT` & Sudoer2 issues Bob a `MINT_PERMIT`

In this example, Alice, Bob & Owner are the only users able to mint. Sudoer1, Sudoer2, & Owner are the only users able to issue `MINT_PERMITs`. And Manager & Owner are the only users able to issue `SUDO_MINT_PERMITs`

##### Binding permits to sudo permits

- Owner issues Manager a `SUDO_PERMIT`

Manager & Owner are the users able to bind `XYZ_PERMIT` -> `SUDO_XYZ`

###### Note

> The values for these permits are represented as `felt252s` and are arbitrary (except for the `SUDO_PERMIT`). That is, a contract could require an `asdf` permit to call a function, and the owner (or `SUDO_PERMIT` holders) may bind `asdf;` -> `jkl;` & `jkl;` -> `asdfjkl;` to implement the scenarios mentioned above.

##### Going deeper

> The examples above solely apply to the contract's mint function due to its set up:
> assert(`contract.has_valid_permit(User, PERMIT) == true, 'Reason: invalid permit'`)

> This permit abstraction can be specifc like shown, or go deep. Imagine an NFT contract:
>
> - functions sharing permits: `set_royalty_percentage() & set_royalty_receiver()` functions both requiring a `ROYALTY_PERMIT`
> - permits sharing a sudo permit : `MINT_PERMIT` & `BURN_PERMIT` are both binded -> `SUPPLY_SUDO_PERMIT`, sudoer can issue only these two permits
> - sudo permits sharing a manager permit: `SUDO_SUPPLY_PERMIT` & `SUDO_ROYALTY_PERMIT` are both binded -> `REGIONAL_MANAGER_1`, holders of this regional permit can only issue these two sudo permits
>   - in this scenarios, the contract's `setURI(), withdraw(), etc.` functions are only accessible to Owner (or permit holders if setup)

### ERC20

This is a standard ERC20 contract that references the Manager contract for minting & burning permissions. To mint tokens, a user or contract must have a `MINT_PERMIT`, and to burn tokens, they must have a `BURN_PERMIT`.

### Registry

This contract handles the logic for the creation and storage of Holes & Rabbits, referencing the Manager contract for these permissions. A `CREATE_HOLE_PERMIT` & `CREATE_RABBIT_PERMIT` are required to create Holes & Rabbits respectively. There are no fees/rewards associated with this contract, that logic is intended to come from contracts with these `CREATE_HOLE/RABBIT_PERMITs`. This structure allows the project to be extended with few restraints.

##### Theoretical extensions

- A Shovel NFT collection is released that allow owners to dig holes at a discount and receive bigger `dig_rewards`
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
  - In the above example, if the `digger_bps` is 2,500, the msg will cost 2.000000 $RBITS; 0.500000 are sent to the Hole's digger, and 1.500000 are burned

#### Stats are stored in this contract as such:

- holes: The number of holes dug (globally or by a user)
- rabbits: The number of rabbits left (globally or by a user)
- depth: The total length of rabbit msgs left (globally or by a user)

## Commands

- `scarb build` creates the sierra.json files for the suite
- `scarb test` runs `core` & `V1` tests
