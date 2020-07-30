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

