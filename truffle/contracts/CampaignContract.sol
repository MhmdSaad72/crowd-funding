// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <0.9.0;

import "./UserContract.sol";

contract CampaignContract{

    struct Campaign {
        uint256 _id;
        string title;
        string desc;
        address creator;
        uint256 goal;
        uint256 pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
        bool cancelled;
    }

    UserContract user;
    uint256 public count;
    uint256 public maxDuration;
    Campaign[] public campaigns;

     modifier can_launch() {
        UserContract.User memory _user = user.getUser(msg.sender);
        require(_user._address != address(0) && _user.verified, "New campaigns can only be started by registered users.");
        _;
    }

    constructor(address _user, uint256 _maxDuration){
        user = UserContract(_user);
        maxDuration = _maxDuration;
    }

    function launch(uint256 _goal, uint256 _startAt, uint256 _endAt, string memory _title, string memory _desc) public can_launch(){
        require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        require(_endAt > _startAt,"End time is less than Start time");
        require(_endAt <= block.timestamp + maxDuration, "End time exceeds the maximum Duration");

        campaigns.push();
        Campaign storage campaign = campaigns[count];
        count++;
        campaign._id = count;
        campaign.creator = msg.sender;
        campaign.startAt = _startAt;
        campaign.endAt = _endAt;
        campaign.goal = _goal;
        campaign.title = _title;
        campaign.desc = _desc;
    }

    function cancel(uint256 _id) public {
        uint256 index = _id - 1 ;
        Campaign storage campaign = campaigns[index];
        require(campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp < campaign.startAt, "Campaign has already started");
        campaign.cancelled = true;
    }

    function getCampaigns() public view returns(Campaign[] memory result){
        result = campaigns;
    }

    function getCampaignById(uint256 _id) public view returns(Campaign memory result){
        uint256 index = _id - 1 ;
        result = campaigns[index];
    }

    function pledged(uint256 _id, uint256 _amount, bool inc) external {
        uint256 index = _id - 1 ;
        Campaign storage campaign = campaigns[index];
        if (inc) campaign.pledged += _amount; 
        else campaign.pledged -= _amount;
    }
    function claimed(uint256 _id) external {
        uint256 index = _id - 1 ;
        Campaign storage campaign = campaigns[index];
        campaign.claimed = true;
    }
}