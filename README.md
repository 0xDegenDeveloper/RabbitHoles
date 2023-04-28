# RabbitHoles

RabbitHoles (RBITS) is an ERC-20 contract abstracted to act as a permanent & censorship resistant discussion board.

## Basic Flow

- Alice pays a small fee ~0.001 ETH (DIG_FEE) to dig the hole "SHOWER THOUGHTS".

  - She is minted ~25.0 RBITS (DIG_REWARD).

    Now that the "SHOWER THOUGHTS" hole is dug, rabbits may be burned inside, and because RBITS are ERC-20 tokens, Alice sends 5.0 to Bob.

- Bob decides to leave the message "Who would have thought that the first shower thought to be immortalized on the blockchain would be about the very concept of storing shower thoughts on the blockchain?", this transaction burns 1.0 of Bob's RBITS.

## Technicals

- The `title`s for each hole dug ("SHOWER THOUGHTS") are stored in the contract as a `felt252`s, meaning each title must be < 32 characters long

  - The dApp will try to encourage hole title syntax and there will eventually be a syntax sheet released for best practices for digging holes about: persons, dates, events, etc.

- The messages left inside the holes are stored as `Array<felt252>` (felt arrays)

  - Storing a `Array<felt252>` message in the contract burns 1.0 RBITS regardless of length; however, gas costs will rise as the message length increases

- The contract has `#[view]` functions to return:
  - The rabbits inside each hole
  - The holes dug by each user
  - The rabbits burned by each user

# Activate Environment (awaiting alphav7 on goerli/mainnet)

`python3.9 -m venv ~/cairo_venv  `
`source ~/cairo_venv/bin/activate`
`export STARKNET_NETWORK=alpha-goerli`  
`export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount`
`export CAIRO_COMPILER_DIR=~/.cairo/target/release/`
`export CAIRO_COMPILER_ARGS=--add-pythonic-hints`

# Build Sierra

`scarb build`

# Format

`scarb fmt`

# Declaring contract class

`starknet declare --contract target/rbits.json --account v0.11.0.2 --network alpha-goerli`
