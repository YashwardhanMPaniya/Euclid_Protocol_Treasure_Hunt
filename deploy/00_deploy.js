const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  if (chainId == 31337) {
    log("Local network detected! Deploying...");
    await deploy("TreasureHunt", {
      from: deployer,
      log: true,
    });

    log("Contract Deployed!");
  }
};
module.exports.tags = ["TreasureHunt"];
