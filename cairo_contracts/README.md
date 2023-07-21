# RabbitHoles - Cairo Contracts

## Core

### Manager Contract

This contract serves as a permit control system for users and contracts. It allows other contracts to limit function calls to specific permit holders. The contract owner manages these permits and can issue them to users as required. The permits fall into two categories: regular and sudo.

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
> - Multi-access managers: Several sudo permits could be bound to the same manager permit. For instance, `SUDO_ROYALTY_PERMIT` & `SUDO_URI_PERMIT` could both be bound to `ARTIST_PERMIT`. With this, artists can issue `SUDO_ROYALTY/URI_PERMITs`, allowing recipients to then issue royalty and URI permits.
