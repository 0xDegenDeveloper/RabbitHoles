// #[cfg(test)]
// mod rbits_tests {
//     use starknet::ContractAddress;
//     use starknet::contract_address_const;

//     use integer::u256;
//     use integer::u256_from_felt252;

//     // use rbits_contract;

//     // use rabbitholes::rbits;
//     #[test]
//     fn rbits_test_01_deployment() {
//         let (account, initial_supply) = setup();
//     }

//     #[test]
//     fn rbits_test_02_minting() {}

//     fn setup() -> (ContractAddress, u256) {
//         let initial_supply: u256 = u256_from_felt252(1111);
//         let account: ContractAddress = contract_address_const::<1>();
//         rabbitholes::rbits::constructor(initial_supply, account);
//         (account, initial_supply)
//     }
// //...
// }


