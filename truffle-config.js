require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider')

const {INFURA_PROJECT_ID, MNEMONIC} = process.env

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
    },
    rinkeby: {
      provider() {
        return new HDWalletProvider(MNEMONIC, `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`)
      },
      network_id: 4,
    },
  },
  compilers: {
    solc: {
      version: '0.8.3',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
}
