var ethoFSController = artifacts.require("./ethoFSController.sol");

module.exports = function(deployer) {
    deployer.deploy(ethoFSController);
};
