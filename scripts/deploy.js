const hre = require("hardhat");

async function main() {
  const CrowdfundingPlatform = await hre.ethers.getContractFactory("CrowdfundingPlatform");
  
  // Start deployment, returning a promise that resolves to a contract object
  const crowdfundingPlatform = await CrowdfundingPlatform.deploy();
  await crowdfundingPlatform.deployed();

  console.log("CrowdfundingPlatform deployed to:", crowdfundingPlatform.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });