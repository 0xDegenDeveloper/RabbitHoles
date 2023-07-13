# Cairo Contracts

## Core

### Manager

The Manager contract controls permissions, or "permits", for users. Other contracts can reference this contract to restrict function calls to specific permit holders.These permits are controlled by the owner of the contract and can be issued to users as needed.

The contract consists primarily of two types of permits, regular and sudo. A regular permit allows its holder access to functions requiring the permit. A sudo permits allows its holders the ability to issue regular permits. The owner and users with the SUDO_PERMIT have the ability to bind regular permits to sudo permits.

Simple example: A mint function requires the caller to own a MINT_PERMIT:

- Owner issues Bob a MINT_PERMIT
- Bob can now mint, Alice cannot

Intermediate example: A contract wants to elect a sudoer to issue MINT_PERMITs

- Owner binds MINT_PERMIT -> SUDO_MINT_PERMIT
- Owner issues a SUDO_MINT_PERMIT to Sudoer
- Sudoer can now issue MINT_PERMITs to Alice & Bob

Complex example: A contract wants to elect a manager to elect sudoers

- Owner binds MINT_PERMIT -> SUDO_MINT_PERMIT
- Owner binds SUDO_MINT_PERMIT -> SUDO_MINT_MANAGER
- Owner issues a SUDO_MINT_MANAGER permit to Manager
- Manager can issue SUDO_MINT permits to Sudoer1 & Sudoer2
- Sudoer1 & Sudoer2 can issue MINT_PERMITs to Alice, Bob, etc.
  - In this example Alice & Bob are the only users able to mint
  - Sudoers 1 & 2 (& Owner) are the only users that can set new minters
  - Manager (& Owner) are the only users that can set new mint sudoers
