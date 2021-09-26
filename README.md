### using 
- truffle
- openzeppelin/contracts

### run step

#### [dev] run
`ganache-cli`

-----

```shell
truffle compile [--netwrok xx]
truffle deploy [--netwrok xx]
```
### deploy order
1. AgicAddressesProvider
2. AgicFundPool
3. Agic
4. AgicInterestCard
5. add AgicInterestCard address to AgicAddressesProvider._whiteList
6. add AgicFundPool address to AgicAddressesProvider
7. add Agic address to AgicAddressesProvider
8. add AgicInterestCard address to AgicAddressesProvider

### Verify etherscan
```shell
truffle run verify Agic --network kovan
truffle run verify AgicAddressesProvider --network kovan
truffle run verify AgicFundPool --network kovan
truffle run verify AgicInterestCard --network kovan
```

### Run process
Pledge ETH to agic contract, Get Agic.

The pledged ETH to AAVE to earn interest

If the interest is greater than 1 finney, a fee of 1 finney will be charged for each withdrawal and deposited in the fund pool

Those who purchase AEC can withdraw a certain percentage of interest every month

## Kovan Address 
- AgicAddressesProvider: [0x8408d17dcFcf8ba7336d13173867d570B90085EF]
- AgicFundPool: [0xb23a57B496C63084BDd52b5e8fAE221CB97Bb91A]
- Agic: [0xab8224dd1F4A469ea4465EC6558a3aDC37bc3A8B]
- AgicInterestCard: [0x6cb49575b58c4dEe20F6e2a5a407486406E1C47E]