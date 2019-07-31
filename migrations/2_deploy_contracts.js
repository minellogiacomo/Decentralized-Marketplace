var DecentralizedStore = artifacts.require("DecentralizedStore");
var Marketplace = artifacts.require("Marketplace.sol");

module.exports = function(deployer) {
  deployer.deploy(DecentralizedStore).then(function() {
  	return deployer.deploy(Marketplace, DecentralizedStore.address);
  });
};
