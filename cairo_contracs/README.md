# Cairo Contracts

## Core

### Manager

The Manager contract controls permissions, or "permits", for users. Other contracts can reference this contract to restrict function calls to specific permit holders. These permits are controlled by the owner of the contract and can be issued to users as needed.

The contract consists primarily of two types of permits, regular and sudo. A regular permit allows its holder access to functions requiring the permit. A sudo permits allows its holders the ability to issue regular permits. The owner and users with a `SUDO_PERMIT` have the ability to bind regular permits to sudo permits.

Simple example: A mint function requires the caller to own a `MINT_PERMIT`:

- Owner issues Bob a `MINT_PERMIT`
- Bob can now mint, Alice cannot

Intermediate example: A contract wants to elect a sudoer to issue `MINT_PERMITs`

- Owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- Owner issues a `SUDO_MINT_PERMIT` to Sudoer
- Sudoer can now issue `MINT_PERMITs` to Alice & Bob (Sudoer cannot mint)

Complex example: A contract wants to elect a manager to elect sudoers

- Owner binds `MINT_PERMIT` -> `SUDO_MINT_PERMIT`
- Owner binds `SUDO_MINT_PERMIT` -> `SUDO_MINT_MANAGER`
- Owner issues a `SUDO_MINT_MANAGER` permit to Manager
- Manager can issue `SUDO_MINT` permits to Sudoer1 & Sudoer2
- Sudoer1 & Sudoer2 can issue `MINT_PERMITs` to Alice, Bob, etc.

In this example Alice & Bob are the only users able to mint. Sudoers 1 & 2 (& Owner) are the only users that can set new minters. Manager (& Owner) are the only users that can set new mint sudoers

### ERC20

This is a standard ERC20 contract that references the Manager contract for minting & burning permissions. To mint tokens a user or contract must have a `MINT_PERMIT`, and to burn tokens, they must have a `BURN_PERMIT`.

### Registry

This contract handles the logic for the creation and storage of Holes & Rabbits, referencing the Manager contract for these permissions. `CREATE_HOLE_PERMIT` & `CREATE_RABBIT_PERMIT` holders may create Holes/Rabbit respecively. There are no fees/rewards associated with this contract, that logic is intended to come from `CREATE_HOLE_PERMIT` & `CREATE_RABBIT_PERMIT` holding contracts. This structure allows the project to be extended with few restraints.

User stats are also stored in this contract. Stats have the following fields:

- holes: The number of holes a user has dug
- rabbits: The number of rabbits a user has burned
- depth: The length of all the rabbits a user has burned

#### Creating a Hole

A Hole is created using a `title`. This title is the topic for the Hole, and is stored in the contract as a `felt252`, meaning it must be 31 characters or less.

#### Creating a Rabbit

A Rabbit is created using a `hole_id` & a `msg`, this Hole must already exist. The `msg` is an array of `felt252s`, and the length of this array is referred to as the Rabbit's `depth`. Once a Rabbit is placed in a Hole, the Hole's digs are incremented by 1, and its depth is increased by the Rabbit's depth.

#### Utilizing Contract Suite Design

The design of the contract suite allows RabbitHoles to be extended in a variety of ways. Some examples below:

- A Shovel NFT collection is released that allows owners to dig holes for a discount
- RabbitholesV1_Shovel is deployed, handling the logic for this discount & ownership verification
- With the neccessary permits, V1 & V1_Shovel are operating synchronously

...

- Months later a V2 is drafted, introducing public/private holes
- A vote takes place, V1 & V1_Shovel are disabled, and V2 is deployed using the same core contracts (Manager, ERC20, Registry)

### RabbitholesV1

This contract is the first implementation of Rabbitholes.

#### Digging a Hole

- To dig a Hole, a user must pay the `dig_fee` (using the `dig_token`, $ETH, $STRK, etc.)
- Digging a hole mints the digger a `dig_reward` amount of RBITS

#### Burning a Rabbit

- To burn a Rabbit, a user will spend RBITS
  - The amount of RBITS a Rabbit will cost is equal to its depth (the number of `felt252s` the Rabbit's msg spans)
  - i.e. "If this was a msg I wanted to leave in a hole", it would span across two felts:
    - `['If this was a msg I wanted to l', 'eave in a hole']`
- Using the `digger_bps` (`0 <= digger_bps <= 10,000`), some RBITS are transfered to the Hole's digger, and the rest are burned
  - i.e. In the above example, if the `digger_bps` is 2,500, my msg costs me 2.000000 RBITS; 0.500000 are sent to the Hole's digger, and 1.500000 are burned
