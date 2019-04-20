const Thing = artifacts.require("Thing");

module.exports = function(deployer) {
  deployer.deploy(Thing);
};
