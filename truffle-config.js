const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = process.env.ETHEREUM_ACCOUNT_MNEMONIC;
const etherscanKey= process.env.ETHERSCAN_KEY;;

module.exports = {

    networks: {

        development: {
            host: "127.0.0.1",     // Localhost (default: none)
            port: 8545,            // Standard Ethereum port (default: none)
            network_id: "*",       // Any network (default: none)
        },
        kovan: {
            provider: () => {
                return new HDWalletProvider({
                    mnemonic: mnemonic,
                    providerOrUrl: process.env.KOVAN_INFURA_ENDPOINT,
                    chainId: 42,
                });
            },
            network_id: "42",
        },
    },

    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.8.4",    // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {          // See the solidity docs for advice about optimization and evmVersion
            //     optimizer: {
            //         enabled: false,
            //         runs: 200
            //     },
            // evmVersion: "istanbul"
        }
    },
    db: {
        enabled: false
    },
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        etherscan: etherscanKey
    }
}
