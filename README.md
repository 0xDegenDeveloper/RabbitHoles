# RabbitHoles

RabbitHoles (RBITS): A Permanent & Censorship Resistant Discussion Board

## Overview

RabbitHoles (RBITS) is an abstracted ERC-20 contract aiming to offer a permanent and censorship-resistant platform for engaging in discussions.

RBITS enables users to dig holes and burn rabbits, which represent topics of discussion and individual messages respectively.

## Basic Flow

The basic flow of RabbitHoles involves the following steps:

Alice pays a small fee to dig a hole with the title "SHOWER THOUGHTS"
As a reward, she is minted some RBITS
Since they are ERC-20 tokens, she sends a few to Bob
Now that the "SHOWER THOUGHTS" hole is dug, anyone can burn a rabbit inside.
Bob decides to leave the message

> Who would have thought that the first shower thought to be immortalized on the blockchain would be about the very concept of storing shower thoughts on the blockchain?"

into the hole, burning some of his RBITS

## Technical Details

- something like 0.001 ETH (the `DIG_FEE`),
- (the `DIG_REWARD`)

### Holes

- A hole's title, such as "SHOWER THOUGHTS", is stored as a single `felt252`. This means that every title must be 31 characters or fewer in length.

-

### Rabbits

- Rabbits: Messages left by buring RBITS are stored in a single `LegacyMap<u64, felt252>` data structure. Each rabbit (message) occupies a contiguous range of slots based on its length in felts. For example, the message Bob left is 167 characters long. This spans across 6 felts, assuming this is the first rabbit burned, Bob's message will fill slots 0, 1, 2, ..., 5.

- Gas Costs: Burning a rabbit (message) in a hole has a fixed burn fee of 1.0 RBITS, regardless of the message length. However, gas costs will increase with message length.
- Contract Views: The contract has been designed to include several `#[view]` functions, keeping the frontend and UX in mind. These user-friendly functions make it easy to query and parse information, providing details such as the rabbits within each hole, the holes dug/rabbits burned by each user, the oldest/newest holes/rabbits, and more. This design ensures a smooth and enjoyable experience when interacting with the contract directly or through the frontend.
- Hole Title Syntax/Best Practices: The dApp will encourage hole title syntax and a guide outlining best practices for digging holes related to people, dates, events, and more will be released. This, along with off-chain parsing/indexing/caching should help reduce the chances of duplcate holes being dug.

## Current Development Status

The RabbitHoles project is currently under active development. Here are the current tasks being worked on:

- Tests: Writing comprehensive tests to ensure the contract behaves as intended.
- Deployment: Waiting for the alphaV7 upgrade to the network to practice deployment & verification
- Frontend Development: Finalizing the frontend interface for an intuitive and user-friendly experience.

### Scarb Commands

The RabbitHoles project utilizes Scarb, a toolset for building and interacting with StarkNet contracts. The following Scarb commands are useful for working with the project:

- `scarb build`: Builds the .sierra & .json files
- `scarb fmt`: Formats .cairo code

### Activate Environment (awaiting alphav7 upgrade, until live, take these steps with a grain of salt)

To activate the RabbitHoles project environment, follow these steps:

- Create a Python 3.9 virtual environment: `python3.9 -m venv ~/cairo_venv`
- Activate the virtual environment: `source ~/cairo_venv/bin/activate`
- Set the STARKNET_NETWORK variable to "alpha-goerli": `export STARKNET_NETWORK=alpha-goerli`
- Set the STARKNET_WALLET variable to "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount": `export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount`
- Set the CAIRO_COMPILER_DIR variable to the Cairo compiler directory path: `export CAIRO_COMPILER_DIR=~/.cairo/target/release/`
- Set the CAIRO_COMPILER_ARGS variable to include additional arguments for the Cairo compiler if needed: `export CAIRO_COMPILER_ARGS=--add-pythonic-hints`

### Declaring contract class

- To declare the RabbitHoles contract class, execute the following command: `starknet declare --contract target/rbits.json --account v0.11.0.2 --network alpha-goerli`

## Authors

- Matt Carter (DegenDeveloper.eth)
