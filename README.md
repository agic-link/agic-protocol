### using 
- truffle
- openzeppelin/cli
- openzeppelin/upgrade
- openzeppelin/contracts-ethereum-package

### run step


``` shell
npx oz compile [--optimizer on]

npx openzeppelin deploy

? Choose the kind of deployment upgradeable
? Pick a network development
? Pick a contract to deploy Agic
✓ Deploying @openzeppelin/contracts-ethereum-package dependency to network dev-1591080876604
✓ Contract Agic deployed
All implementations have been deployed
? Call a function to initialize the instance after creating it? Yes
? Select which function * initialize()
✓ Setting everything up to create contract instances
✓ Instance created at 0x24aCCd517EEB7FB4510a226e0f141B99A6Ac24a3
To upgrade this instance run 'oz upgrade'
0x24aCCd517EEB7FB4510a226e0f141B99A6Ac24a3

npx oz upgrade

? Pick a network development
? Which instances would you like to upgrade? All instances
Nothing to compile, all contracts are up to date.
All implementations are up to date
✓ Instance upgraded at 0x24aCCd517EEB7FB4510a226e0f141B99A6Ac24a3. Transaction receipt: 0xcd6f749707c23d76f7772177d5a012f0da8a81ebd3b2000269a8351aaf2051bf
✓ Instance at 0x24aCCd517EEB7FB4510a226e0f141B99A6Ac24a3 upgraded

```

#### calls

##### write
npx oz send-tx  
 
##### read 
 
npx oz call

### deploy order
AgicFundPool
Agic
AgicEquityCard
update AgicFundPool owner to AgicEquityCard

#### building code
`truffle-flattener <solidity-files> > output.sol`