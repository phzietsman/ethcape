
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
    },
    rinkeby: {
      provider: () => new HDWalletProvider("exercise ankle empower select spell physical raise march sniff machine ask tourist", "https://rinkeby.infura.io/v3/07833b57821b47a9aec45dc69a107c17"),
      network_id: 4,
      gas: 4500000, // Gas limit used for deploys
      gasPrice: 25000000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};