account

# Activate Environment (awaiting alphav7 on goerli/mainnet)

`python3.9 -m venv ~/cairo_venv  `
`source ~/cairo_venv/bin/activate`

`export STARKNET_NETWORK=alpha-goerli`  
`export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount`
`export CAIRO_COMPILER_DIR=~/.cairo/target/release/`
`export CAIRO_COMPILER_ARGS=--add-pythonic-hints`

# Build Sierra

`scarb build`

# Format

`scarb fmt`

# Declaring contract class

starknet declare --contract target/rbits.json --account v0.11.0.2 --network alpha-goerli
--wallet STARKNET_WALLET
