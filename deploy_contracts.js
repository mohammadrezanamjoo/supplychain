const SupplyChainInstant = artifacts.require("SupplyChain");

module.exports =  function (deployer) {
  deployer.deploy(SupplyChainInstant);
};
