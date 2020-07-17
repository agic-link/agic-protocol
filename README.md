### using 
- truffle
- openzeppelin/cli
- openzeppelin/contracts

### run step


``` shell
npx oz compile [--optimizer on]

npx oz deploy

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

