# RabbitHoles

A Permanent & Censorship-Resistant Discussion Board.

## Overview

RabbitHoles is a decentralized discussion platform built on Starknet using Cairo 1, offering an everlasting, censorship-resistant space for open conversations. Each discussion topic, called a "hole," houses messages known as "rabbits". RBITS, are ERC-20 token facilitating interactions within the platform. A demo can be found at https://rbits.space.

## Basic Flow

The basic flow involves the following steps:

- Alice pays a small fee to dig a hole with the title "SHOWER THOUGHTS"
- As a reward, she is minted some RBITS
- Since they are ERC-20 tokens, she sends a few to Bob.
- Now that the "SHOWER THOUGHTS" hole is dug, anyone can burn a rabbit inside
  Bob decides to leave the message,

> Who would have thought that the first shower thought to be immortalized on a blockchain would be about the very concept of storing shower thoughts on a blockchain?"

in the hole, giving some RBIT to Alice and burning the rest

- Bob's message is timestamped and stored in the contract.
- Several `#[view]` functions are available keeping the frontend and UX in mind.
  - These user-friendly functions make it easy to query and parse details such as the rabbits within each hole, the holes dug/rabbits burned by each user, the oldest/newest holes/rabbits, etc. This design ensures a smooth and enjoyable experience while interacting with the contracts directly or through the frontend.

## Technical Details

### Holes

- Digging a hole will cost a small fee, something like 0.001Ξ. This is the dig fee and is used to disincentive spam and fund future extensions to the project.

- Each dig will mint RBIT to its digger. This is the dig reward and will be in the range of 20-100 RBITS.

\*\* The exact numbers are still being thought about. Feedback, opinions, and thoughts are appreciated and ecouraged.

- A hole's title, ("SHOWER THOUGHTS"), is stored as a single `felt252`, meaning every title must be 31 characters or fewer in length.

- The dApp will encourage syntax and a guide outlining best practices for digging holes relating to people, dates, events, and more will be released. This, along with a dedicated backend should reduce the chances of similar holes being dug.

### Rabbits

- Messages (rabbits) are stored in a single `LegacyMap<u64, felt252>` data structure.
- Each message occupies a contiguous range of slots based on its length in felts

  - For example, the message Bob burned is 164 characters long. This spans across 6 felts, assuming this is the first rabbit burned, Bob's message will fill slots 0, 1, 2, ..., 5.

- Each `felt252` a message fills will cost its burner 1.0 RBIT. 75% is burned and 25% is sent to the digger of the hole.

  - In the above example, Bob's message costs him 6.0 RBIT. 1.5 is sent to Alice, and 4.5 are burned.

## Current Development Status

Current tasks include:

- Finalizing contract design/testing
  - Accounting for future expansion
- Waiting for alphaV7 network upgrade
  - To connect to the demo site
- Optimizing frontend on all devices

### Scarb Commands

- `scarb build`
- `scarb fmt`

### Activate Environment (awaiting alphav7 upgrade)

- `python3.9 -m venv ~/cairo_venv`
- `source ~/cairo_venv/bin/activate`
- `export STARKNET_NETWORK=alpha-goerli`
- `export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount`
- `export CAIRO_COMPILER_DIR=~/.cairo/target/release/`
- `export CAIRO_COMPILER_ARGS=--add-pythonic-hints`

### Other commands

- Declare contract class: `starknet declare --contract <path-to.json> --account v0.11.0.2 --network alpha-goerli`

## Authors

- Matt Carter (DegenDeveloper.eth)
