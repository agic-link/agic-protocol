const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = process.env.ETHEREUM_ACCOUNT_MNEMONIC;

module.exports = {

    networks: {

        development: {
            host: "127.0.0.1",     // Localhost (default: none)
            port: 8545,            // Standard Ethereum port (default: none)
            network_id: "*",       // Any network (default: none)
        },
        ropsten: {
            provider: () => {
                return new HDWalletProvider(mnemonic, process.env.ROPSTEN_INFURA_ENDPOINT)
            },
            network_id: '3',
            gasPrice: 1000000000,
            gasLimit: 100000000000000
        },
        mainnet: {
            provider: () => {
                return new HDWalletProvider(mnemonic, process.env.MAINNET_INFURA_ENDPOINT);
            },
            network_id: '1',
            gasPrice: 8000000000,
        },
    },

    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.6.8",    // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            settings: {          // See the solidity docs for advice about optimization and evmVersion
             optimizer: {
               enabled: true,
               runs: 200
             },
            evmVersion: "byzantium"
            }
        }
    }
}
