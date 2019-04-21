
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    xdai: {
      provider: () => new HDWalletProvider("", "https://dai.poa.network"),
      network_id: 100
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