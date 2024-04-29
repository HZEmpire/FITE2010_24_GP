// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingPlatform {
    struct Campaign {
        address payable owner;
        string description;
        uint256 goalAmount;
        uint256 currentAmount;
        uint256 endTime;
        bool claimed;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    event CampaignCreated(uint256 campaignId, address owner, string description, uint256 goalAmount, uint256 endTime);
    event FundingReceived(uint256 campaignId, address donor, uint256 amount);
    event CampaignClaimed(uint256 campaignId, address owner, uint256 totalAmount);

    // 创建一个募捐活动
    // _description: 活动描述
    // _goalAmount: 目标金额
    // _duration: 活动持续时间
    // 返回值: 活动信息，包括活动ID
    function createCampaign(string memory _description, uint256 _goalAmount, uint256 _duration) public {
        require(_goalAmount > 0, "Goal amount must be greater than 0");
        campaigns[campaignCount] = Campaign({
            owner: payable(msg.sender),
            description: _description,
            goalAmount: _goalAmount,
            currentAmount: 0,
            endTime: block.timestamp + _duration,
            claimed: false
        });

        emit CampaignCreated(campaignCount, msg.sender, _description, _goalAmount, block.timestamp + _duration);
        campaignCount++;
    }

    // 捐款
    // _campaignId: 活动ID
    // 捐款金额: msg.value
    function fundCampaign(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.endTime, "Campaign has ended.");
        require(msg.value > 0, "Donation amount must be greater than 0");

        campaign.currentAmount += msg.value;
        emit FundingReceived(_campaignId, msg.sender, msg.value);
    }

    // 领取募捐款项
    // _campaignId: 活动ID
    // 只有活动发起人，且活动已经结束可以领取
    function claimFunds(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.owner, "Only the owner can claim funds.");
        require(block.timestamp >= campaign.endTime, "Campaign is still ongoing.");
        require(!campaign.claimed, "Funds have already been claimed.");

        uint256 totalAmount = campaign.currentAmount;
        if (totalAmount >= 0) {
            campaign.owner.transfer(totalAmount);
            campaign.claimed = true;
            emit CampaignClaimed(_campaignId, msg.sender, totalAmount);
        }
    }
    // 获取活动信息
    function getCampaign(uint256 _campaignId) public view returns (Campaign memory) {
        return campaigns[_campaignId];
    }
}