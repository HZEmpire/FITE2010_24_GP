// Author: Xu Haozhou
const CrowdfundingPlatform = artifacts.require("CrowdfundingPlatform");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(CrowdfundingPlatform);
    const crowdfundingPlatformInstance = await CrowdfundingPlatform.deployed();

    // 分配代币给两个账户
    const tokenAmount = 100;
    await crowdfundingPlatformInstance.transfer(accounts[0], tokenAmount);
    await crowdfundingPlatformInstance.transfer(accounts[1], tokenAmount);
};
