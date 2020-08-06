## using 
- truffle
- openzeppelin/cli
- openzeppelin/contracts

## run step

#### [dev] run
`ganache-cli`

-----

``` shell
npx oz compile [--optimizer on]
npx oz deploy
```

## calls

#### write
`npx oz send-tx`
#### read 
`npx oz call`
## deploy order
1. AgicAddressesProvider
2. AgicFundPool
3. Agic
4. AgicEquityCard
5. add AgicEquityCard address to AgicAddressesProvider._whiteList

## building full code
`truffle-flattener <solidity-files> > output.sol`

## Run process
Pledge ETH to agic contract, Get Agic.

The pledged ETH to AAVE to earn interest

10% of the interest earned at the time of withdrawal goes to the fund pool

Those who purchase AEC can withdraw a certain percentage of interest every month

## Ropsten Address 
- AgicAddressesProvider: [0x58237b0b0233b5b14057a3a6e5f83989bb9ce7f6]
- AgicFundPool: [0xe0E882224F49fa78D5f0a0DBe2C1BDd80a7ebA03]
- Agic: [0x170B0A1ba2205953F9bE9f1dc11721cA1d28D289]
- AgicEquityCard: [0xf59b61be952db69ab18ab29e32857420c62239b6]

