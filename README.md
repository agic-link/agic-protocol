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
6. add AgicFundPool address to AgicAddressesProvider
7. add Agic address to AgicAddressesProvider
8. add AgicEquityCard address to AgicAddressesProvider

## building full code
`truffle-flattener <solidity-files> > output.sol`

## Run process
Pledge ETH to agic contract, Get Agic.

The pledged ETH to AAVE to earn interest

If the interest is greater than 1 finney, a fee of 1 finney will be charged for each withdrawal and deposited in the fund pool

Those who purchase AEC can withdraw a certain percentage of interest every month

## Kovan Address 
- AgicAddressesProvider: [0xa65CaE64DAf799a38Ca0AD6818e131007DCe14eD]
- AgicFundPool: [0xc1f97c26bfB686cc17fE48f5eb317922662B2E56]
- Agic: [0x5fB11598DDfEF37be63dC3665cFb68A8F940F8F9]
- AgicEquityCard: [0x107ce128dB494865F3062c8DD1977A5b78ea1ADA]

## Main Address 
- AgicAddressesProvider: []
- AgicFundPool: []
- Agic: []
- AgicEquityCard: []