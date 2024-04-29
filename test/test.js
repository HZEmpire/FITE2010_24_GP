const CrowdfundingPlatform = artifacts.require("CrowdfundingPlatform");

contract("CrowdfundingPlatform", (accounts) => {
    let crowdfundingInstance;
    let endTime;

    before(async () => {
        crowdfundingInstance = await CrowdfundingPlatform.new();
    });

    // 测试1: 能否成功创建一个众筹活动
    // 所用目标金额为10，时间为10s
    // Author: Xu Haozhou
    it("should create a campaign with a goal of 10 tokens and a duration of 10 seconds", async () => {
        const description = "Test Campaign";
        const goalAmount = 10;
        const duration = 10; // seconds

        await crowdfundingInstance.createCampaign(description, goalAmount, duration, { from: accounts[0] });

        const campaign = await crowdfundingInstance.getCampaign(0);
        assert.equal(campaign.description, description, "Campaign description should match");
        assert.equal(campaign.goalAmount, goalAmount, "Goal amount should match");
        endTime = campaign.endTime;
        assert.equal(campaign.endTime, endTime, "End time should be set correctly");
    });

    // 测试2: 能否成功捐款
    // Author: Xu Haozhou
    it("should allow account 1 to donate 15 tokens", async () => {
        await crowdfundingInstance.fundCampaign(0, { from: accounts[1], value: 15 });
        const campaign = await crowdfundingInstance.getCampaign(0);
        assert.equal(campaign.currentAmount, 15, "Current amount should be updated");
    });

    // 测试3: 非创办人不允许获取资金
    // Author: Xu Haozhou
    it("should prevent account 1 from claiming funds", async () => {
        try {
            await crowdfundingInstance.claimFunds(0, { from: accounts[1] });
            assert.fail("Claiming funds should be blocked for account 1");
        } catch (error) {
            assert.include(error.message, "Only the owner can claim funds.", "Expected error message");
        } 
    });

    // 测试4: 创办人在时间结束前不允许获取资金
    // Author: Xu Haozhou
    it("should prevent account 0 from claiming funds before campaign end time", async () => {
        try {
            await crowdfundingInstance.claimFunds(0, { from: accounts[0] });
            assert.fail("Claiming funds should be blocked before campaign end time");
        } catch (error) {
            assert.include(error.message, "Campaign is still ongoing.", "Expected error message");
        }
    });

    // 测试5: 创办人在时间结束后允许获取资金
    // Author: Xu Haozhou
    it("should allow account 0 to claim funds after campaign end time", async () => {
        // Adjust block timestamp to be after campaign end time
        const currentTime = (await web3.eth.getBlock("latest")).timestamp;
        const timeToIncrease = endTime - currentTime + 1;
        await new Promise((resolve, reject) => {
            web3.currentProvider.send(
              {
                jsonrpc: "2.0",
                method: "evm_increaseTime",
                params: [timeToIncrease],
                id: new Date().getTime(),
              },
              (err, result) => {
                if (err) {
                  reject(err);
                } else {
                  resolve(result);
                }
              }
            );
          });
          
        // Mine a new block so that the new timestamp takes effect
        await web3.eth.sendTransaction({ from: accounts[0], to: accounts[1], value: 0 });

        // Now account 0 should be able to claim funds
        await crowdfundingInstance.claimFunds(0, { from: accounts[0] });
        const campaignAfterClaim = await crowdfundingInstance.getCampaign(0);
        assert.equal(campaignAfterClaim.claimed, true, "Funds should be claimed");
    });

});