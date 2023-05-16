//// contract to store holes stuff, uses another contract to store rabbits, (r_constructor(currentRCount = 0, (size of prev if making new)))
//// seperate user contract ? or in hole registry ? 
//// r_contract.burnRabbit => rabbit_id, to use with user's etc

//// need to be able to toggle digging/burning through manager, incase depoloying new rabbit contract, no missed globals

#[contract]
mod archive {
    struct Storage {
        balance: felt252, 
    }

    // Increases the balance by the given amount.
    #[external]
    fn increase_balance(amount: felt252) {
        assert(amount != 0, 'Amount cannot be 0');
        balance::write(balance::read() + amount);
    }

    // Returns the current balance.
    #[view]
    fn get_balance() -> felt252 {
        balance::read()
    }
}
