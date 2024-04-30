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
        address[] donators; //捐助者地址
        uint256[] donationAmounts; //捐款金额
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    event CampaignCreated(uint256 campaignId, address owner, string description, uint256 goalAmount, uint256 endTime);
    event FundingReceived(uint256 campaignId, address donor, uint256 amount);
    event CampaignClaimed(uint256 campaignId, address owner, uint256 totalAmount);
    event RefundRequested(uint256 campaignId, address donator, uint256 donationAmount);

    // 创建一个募捐活动
    // _description: 活动描述
    // _goalAmount: 目标金额
    // _duration: 活动持续时间
    // 返回值: 活动信息，包括活动ID
    // Author: Xu Haozhou
    function createCampaign(string memory _description, uint256 _goalAmount, uint256 _duration) public {
        require(_goalAmount > 0, "Goal amount must be greater than 0");
        campaigns[campaignCount] = Campaign({
            owner: payable(msg.sender),
            description: _description,
            goalAmount: _goalAmount,
            currentAmount: 0,
            endTime: block.timestamp + _duration,
            claimed: false,
            donators: new address[](0),
            donationAmounts: new uint256[](0)
        });

        emit CampaignCreated(campaignCount, msg.sender, _description, _goalAmount, block.timestamp + _duration);
        campaignCount++;
    }

    // 捐款
    // _campaignId: 活动ID
    // 捐款金额: msg.value
    // Author: Xu Haozhou
    function fundCampaign(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.endTime, "Campaign has ended.");
        require(msg.value > 0, "Donation amount must be greater than 0");

        campaign.currentAmount += msg.value;
        campaign.donators.push(msg.sender); //添加地址
        campaign.donationAmounts.push(msg.value); //添加金额
        emit FundingReceived(_campaignId, msg.sender, msg.value);
    }

    // 领取募捐款项
    // _campaignId: 活动ID
    // 只有活动发起人，且活动已经结束可以领取
    // Author: Xu Haozhou
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
    // Author: Xu Haozhou
    function getCampaign(uint256 _campaignId) public view returns (Campaign memory) {
        return campaigns[_campaignId];
    }

    // Following getCampaign function
    // return: 有关 Campaign 的各种信息
    // Author: Song Wenhao
    function viewCampaign(uint256 _campaignId) public view returns (
        address owner,
        string memory description,
        uint256 goalAmount,
        uint256 currentAmount,
        uint256 endTime,
        string memory processingStatus,
        uint256 donatorsCount
    ) {
        Campaign memory campaign = getCampaign(_campaignId);
        
        processingStatus = campaign.claimed ? "No" : "Yes";
        
        return (
            campaign.owner,
            campaign.description,
            campaign.goalAmount,
            campaign.currentAmount,
            campaign.endTime,
            processingStatus,
            campaign.donators.length
        );
    }

    // 获取捐助者信息
    // _campaignId: 活动ID
    // _index: 捐款次序
    // return: 捐助者地址，捐款金额
    // Author: Song Wenhao
    function getDonator(uint256 _campaignId, uint256 _index) public view returns (address, uint256) {
        Campaign storage campaign = campaigns[_campaignId];
        require(_index < campaign.donators.length, "Invalid index");

        address donator = campaign.donators[_index];
        uint256 donationAmount = campaign.donationAmounts[_index];

        return (donator, donationAmount);
    }

    // 获取剩余时间
    // _campaignId: 活动ID
    // return: 剩余时间
    // Author: Song Wenhao
    function getRemainingTime(uint256 _campaignId) public view returns (uint256) {
        Campaign storage campaign = campaigns[_campaignId];
        if (block.timestamp >= campaign.endTime) {
            return 0;
        }
        return campaign.endTime - block.timestamp;
    }

    // 请求退款，如果 campaign 时间到期且没有达到目标金额
    // Author: Song Wenhao
    function requestRefund(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.claimed, "Funds have already been claimed.");
        require(block.timestamp >= campaign.endTime, "Campaign is still ongoing.");
        require(campaign.currentAmount < campaign.goalAmount, "Campaign goal is already met.");

        bool hasDonated = false;
        uint256 donationAmount = 0;
        for (uint256 i = 0; i < campaign.donators.length; i++) {//判断是否有捐助
            if (campaign.donators[i] == msg.sender) {
                hasDonated = true;
                donationAmount = campaign.donationAmounts[i];
                break;
            }
        }

        require(hasDonated, "You have not made a donation to this campaign.");

        address payable donator = payable(msg.sender);
        donator.transfer(donationAmount);

        emit RefundRequested(_campaignId, donator, donationAmount);
    }
}
