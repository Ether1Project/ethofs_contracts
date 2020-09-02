var ethoFSHostingContracts = artifacts.require("./ethoFSHostingContracts.sol");

module.exports = function(deployer) {
  deployer.deploy(ethoFSHostingContracts);
};

