// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <0.9.0;

import "./CampaignContract.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdfund{

    IERC20[] public payment_tokens;
    CampaignContract campaign;
    mapping(uint256 => mapping(address => mapping(IERC20 => uint256))) public pledgedAmount;

    constructor(address _campaign, IERC20[] memory _tokens) {
        payment_tokens = _tokens;
        campaign = CampaignContract(_campaign);
    }

    function pledge(uint256 _id, uint256 _amount, IERC20 _token) public {
        CampaignContract.Campaign memory _campaign = campaign.getCampaignById(_id);
        require(indexOf(payment_tokens, _token), "err");
        require(block.timestamp >= _campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= _campaign.endAt, "Campaign has already ended");
        require(!_campaign.cancelled, "Campaign has already cancelled");
        campaign.pledged(_id, _amount, true);
        pledgedAmount[_id][msg.sender][_token] += _amount;
        _token.transferFrom(msg.sender, address(this), _amount);
    }

    function unPledge(uint256 _id,uint256 _amount, IERC20 _token) public {
        CampaignContract.Campaign memory _campaign = campaign.getCampaignById(_id);
        require(block.timestamp >= _campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= _campaign.endAt, "Campaign has already ended");
        require(pledgedAmount[_id][msg.sender][_token] >= _amount,"You do not have enough tokens Pledged to withraw");
        campaign.pledged(_id, _amount, false);
        pledgedAmount[_id][msg.sender][_token] -= _amount;
        _token.transfer(msg.sender, _amount);
    }

    function claim(uint256 _id, IERC20 _token) external {
        CampaignContract.Campaign memory _campaign = campaign.getCampaignById(_id);
        require(_campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp > _campaign.endAt, "Campaign has not ended");
        require(_campaign.pledged >= _campaign.goal, "Campaign did not succed");
        require(!_campaign.claimed, "claimed");
        campaign.claimed(_id);
        pledgedAmount[_id][msg.sender][_token] = 0;
        _token.transfer(_campaign.creator, _campaign.pledged);
    }


    function refund(uint256 _id, IERC20 _token) public {
        CampaignContract.Campaign memory _campaign = campaign.getCampaignById(_id);
        require(block.timestamp > _campaign.endAt, "not ended");
        require(_campaign.pledged < _campaign.goal, "You cannot Withdraw, Campaign has succeeded");
        uint256 bal = pledgedAmount[_id][msg.sender][_token];
        pledgedAmount[_id][msg.sender][_token] = 0;
        _token.transfer(msg.sender, bal);
    }

    function getTokens() public view returns (IERC20[] memory) {
        return payment_tokens;
    }

    function indexOf(IERC20[] memory self, IERC20 value) internal pure returns (bool result) 
    {
      for (uint i = 0; i < self.length; i++) {
        if (self[i] == value) result = true;
      } 
    }
}