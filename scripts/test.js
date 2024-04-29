// test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CrowdfundingPlatform", function () {
    let crowdfunding;
    let owner;

    before(async function () {
        const CrowdfundingPlatform = await ethers.getContractFactory("CrowdfundingPlatform");
        crowdfunding = await CrowdfundingPlatform.deploy();
        await crowdfunding.deployed();

        [owner] = await ethers.getSigners();
    });

    // 测试能否创建一个众筹活动
    it("should create a campaign", async function () {
        await crowdfunding.createCampaign("Test Campaign", 1, 60); // 60s duration
        const campaign = await crowdfunding.getCampaign(0);
        expect(campaign.description).to.equal("Test Campaign");
        expect(campaign.goalAmount).to.equal(1);
    });

    // 测试能否对一个众筹活动进行资助
    it("should allow funding a campaign", async function () {
        await crowdfunding.fundCampaign(0, { value: 0.01 });
        const campaign = await crowdfunding.getCampaign(0);
        expect(campaign.currentAmount).to.equal(0.01);
    });

    // 测试未结束的众筹活动不能提取资金
    it("should not allow claiming funds before the campaign ends", async function () {
        try {
            await crowdfunding.claimFunds(0);
            // 如果成功执行到这里，说明测试失败
            expect.fail("Claiming funds before campaign ends should throw an error");
        } catch (error) {
            // 预期会抛出错误
            expect(error.message).to.contain("Campaign is still ongoing.");
        }
    });

    // 测试结束后获取筹集的资金
    it("should allow claiming funds", async function () {
        // 等待60s
        await new Promise((resolve) => setTimeout(resolve, 60000));
        await crowdfunding.claimFunds(0);
        const campaign = await crowdfunding.getCampaign(0);
        expect(campaign.claimed).to.equal(true);
    });
});
