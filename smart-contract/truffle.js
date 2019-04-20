
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    xdai: {
      provider: function() {
            return new HDWalletProvider(
           process.env.MNEMONIC,
           "https://dai.poa.network")
      },
      network_id: 100,
      gas: 5000000,
      gasPrice: 1000000000
    },
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // match any network
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};