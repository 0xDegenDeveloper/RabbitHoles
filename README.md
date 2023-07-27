# RabbitHoles

## Overview

RabbitHoles is a decentralized discussion platform built on Starknet, offering a space for permanent and censorship-resistant conversations. Each discussion topic is called a Hole and stores messages, called Rabbits, within them. A demo can be found at https://demo.rbits.space.

## Basic Flow

- Alice pays a fee to dig a `Hole` with the title: 'SHOWER THOUGHTS', she is minted $RBITS (erc20 tokens) in return
- Alice sends a few $RBITS to Bob
- Bob burns the `Rabbit`:

> Who would have thought that the first shower thought to be immortalized on a blockchain would be about the very concept of storing shower thoughts on a blockchain?"

in the 'SHOWER THOUGHTS' Hole, costing him some of his $RBITS

##### [/cairo_contracts](./cairo_contracts/) for technical details

## Current development status

- Finalizing [/client](./client)
- Connecting contracts -> client
