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

If the interest is greater than 1 finney, a fee of 1 finney will be charged for each withdrawal and deposited in the fund pool

Those who purchase AEC can withdraw a certain percentage of interest every month

## Ropsten Address 
- AgicAddressesProvider: [0x58237b0b0233b5b14057a3a6e5f83989bb9ce7f6]
- AgicFundPool: [0x4562e390eFB066D954bB487507Ce8C91d6BE1226]
- Agic: [0xc840A15f11Ec52DD6C3ea69dAb231B8846CDa23c]
- AgicEquityCard: [0xf59b61be952db69ab18ab29e32857420c62239b6]