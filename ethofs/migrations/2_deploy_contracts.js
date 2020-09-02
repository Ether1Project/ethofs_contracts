var ethoFSController = artifacts.require("./ethoFSController.sol");
var ethoFSDashboard = artifacts.require("./ethoFSDashboard.sol");
var ethoFSHostingContracts = artifacts.require("./ethoFSHostingContracts.sol");
var PinDataAddress = "0xD3b80c611999D46895109d75322494F7A49D742F";

module.exports = function(deployer) {
  deployer.deploy(ethoFSController);
  deployer.deploy(ethoFSDashboard);
  deployer.deploy(ethoFSHostingContracts);
};

