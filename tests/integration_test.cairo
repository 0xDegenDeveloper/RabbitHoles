// use array::ArrayTrait;
// use array::SpanTrait;
// use box::BoxTrait;
// use option::OptionTrait;
// use traits::Into;
// use zeroable::Zeroable;
// use clone::Clone;

// use rabbitholes::rbits;
// use rabbitholes;
// use rbits;

#[cfg(test)]
mod integration_test {
    use starknet::contract_address;
    // use starknet::syscalls::handler;

    // use starknet::contract_address_const;
    use starknet::testing;
    use integer::u256;
    use integer::u256_from_felt252;
    use debug::PrintTrait;
// #[test]
// fn test_transfer() {
//     // let (sender, supply) = setup();
//     0x1.print();
//     let account = contract_address::contract_address_const::<1>();
//     testing::set_caller_address(account);
//     0x2.print();
//     // archive::archive::get_balance(1);

//     // let supply: u256 = u256_from_felt252(11111);

//     // '123'.print();

//     // let max_felt = u256_from_felt252(2 ** 252 - 1);
//     // let max = u64::MAX;

//     // max.print();

//     0x0.print();
//     0.print();
//     '0'.print();
//     // account.print();
//     // '456'.print();
//     assert(0x0 == 0, 'b');
// }
}
// // fn setup() -> (ContractAddress, u256) {
// let init_supply: u256 = u256_from_felt252(11111);
// let account: ContractAddress = contract_address_const::<1>();
// '111111111'.print();
// account.print();
// //rbits::constructor(init_supply, account);
// (account, init_supply)
// // }

// use integer::u256;
// use integer::u256_from_felt252;
// use starknet::ContractAddress;
// use starknet::contract_address_const;
// use starknet::testing::set_caller_address;
// use debug::PrintTrait;

// #[test]
// // #[available_gas(2000000)]
// fn test_transfer(){
//     // let (sender, supply) = setup();
//     let account: ContractAddress = contract_address_const::<1>();
//     set_caller_address(account);
//     assert(1 == 1, 'logic broke');
// }

//     // let recipient: ContractAddress = contract_address_const::<2>();
//     // let amount: u256 = u256_from_felt252(1000);
//     // let recipient_bal: u256 = contracts::rbits::rbits::balance_of(recipient);

//     // contracts::rbits::rbits::transfer(recipient, amount);

//     // assert(contracts::rbits::rbits::balance_of(recipient) == recipient_bal + amount, 'RBITS: wrong transfer amount');
//     // assert(contracts::rbits::rbits::balance_of(sender) == supply - amount, 'RBITS: wrong sender balance');
// // }


