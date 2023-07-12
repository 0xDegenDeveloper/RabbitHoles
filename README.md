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
- Bob decides to leave the message,

> Who would have thought that the first shower thought to be immortalized on a blockchain would be about the very concept of storing shower thoughts on a blockchain?"

in the hole, costing him RBITS

- Bob's message is timestamped and stored in the contract.

## Technical Details

### Holes

- Digging a hole will cost a small fee, something like 0.001Ξ. This is the dig fee and is used to disincentive spam and fund future extensions to the project.

- Each dig will mint RBITS to its digger. This is the dig reward and will be in the range of 20-100 RBITS.

\*\* The exact numbers are still being thought about. Feedback, opinions, and thoughts are appreciated and ecouraged.

- A hole's title, ("SHOWER THOUGHTS"), is stored as a single `felt252`, meaning every title must be 31 characters or fewer in length.

- The dApp will encourage syntax and a guide outlining best practices for digging holes relating to people, dates, events, and more will be released. This, along with a dedicated backend should reduce the chances of similar holes being dug (Jeffrey Epstein vs JEFFERY EPSTEIN).

### Rabbits

- Messages (rabbits) are stored in a single `LegacyMap<u64, felt252>` data structure.
- Each message occupies a contiguous range of slots based on its length in felts

  - For example, the message Bob burned is 164 characters long. This spans across 6 felts, assuming this is the first rabbit burned, Bob's message will fill slots 0, 1, 2, ..., 5.

- Each `felt252` a message fills will cost its burner 1.0 RBIT. A % of these RBITS are sent to the hole's digger, and the rest are burned.

  - In the above example, Bob's message costs him 6.0 RBIT. Some were sent to Alice, and the rest were burned.

## Current Development Status

Current tasks include:

- Finishing RabbitholesV1 tests
- Finalizing frontend
- Connecting frontend -> contracts

### Scarb Commands

- `scarb build`
- `scarb test`

### Other commands

- Declare contract class: `starknet declare --contract <path-to.json> --account v0.11.0.2 --network alpha-goerli`

## Authors

- Matt Carter (DegenDeveloper.eth)
