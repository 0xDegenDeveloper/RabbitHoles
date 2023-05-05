# RabbitHoles

RabbitHoles (RBITS): A Permanent & Censorship Resistant Discussion Board

## Overview

RabbitHoles (RBITS) is an abstracted ERC-20 contract aiming to offer a permanent and censorship-resistant platform for engaging in discussions.

RBITS enables users to dig holes and burn rabbits, which represent topics of discussion and individual messages respectively.

## Basic Flow

The basic flow of RabbitHoles involves the following steps:

- Alice pays a small fee to dig a hole with the title "SHOWER THOUGHTS".
- Her dig count is incremented, and as a reward, she is minted some RBITS.
- Since they are ERC-20 tokens, she sends a few to Bob.
- Now that the "SHOWER THOUGHTS" hole is dug, anyone can burn a rabbit inside.
  Bob decides to leave the message,

> Who would have thought that the first shower thought to be immortalized on the blockchain would be about the very concept of storing shower thoughts on the blockchain?"

into the hole, burning some of his RBITS.

- Bob's message is timestamped, stored in the contract, and his burn count is incremented.
  Several `#[view]` functions are available keeping the frontend and UX in mind. These user-friendly functions make it easy to query and parse information, providing details such as the rabbits within each hole, the holes dug/rabbits burned by each user, the oldest/newest holes/rabbits, and more. This design ensures a smooth and enjoyable experience when interacting with the contract directly or through the frontend.

## Technical Details

### Holes

- Digging a hole will cost a small fee, something like 0.001Ξ. This is the dig fee and is used to disincentive spam and fund future extensions to the project.

- Each dig will mint RBITS to its digger. This is the dig reward and will probably be in the ball park of 20-100 RBITS.

\*\* The exact numbers are still being thought about and feedback, opinions, and thoughts are appreciated.

- A hole's title, ("SHOWER THOUGHTS"), is stored as a single `felt252`, meaning every title must be 31 characters or fewer in length.

- The dApp will encourage syntax and a guide outlining best practices for digging holes relating to people, dates, events, and more will be released. This, along with additional backend techniques should reduce the chances of similar holes being dug.

### Rabbits

- Messages left (rabbits burned) are stored in a single `LegacyMap<u64, felt252>` data structure.
- Each message occupies a contiguous range of slots based on its length in felts

  - For example, the message Bob burned is 167 characters long. This spans across 6 felts, assuming this is the first rabbit burned, Bob's message will fill slots 0, 1, 2, ..., 5.

- Burning a rabbit will burn 1.0 RBITS for each `felt252` the message fills.

  - Therefore, Bob's message cost him 6.0 RBITS to burn.

## Current Development Status

### A demo for the project can be found at https://rbits.space.

Current tasks include:

- Finalizing contract design to account for future expansion
- Testing to ensure intended behavior.
- Waiting for the alphaV7 network upgrade to deploy on goerli and connect to the demo site
- Tweaking the frontend to ensure a smooth experience on all devices

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
