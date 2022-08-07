// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";

contract CrowdFund {

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startTime;
        uint32 endTime;
        bool claimed;
    }

    event Launch(uint indexed id, address indexed creator, uint goal, uint32 startTime, uint32 endTime);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint value);
    event Unpledge(uint indexed id, address indexed caller, uint value);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    IERC20 public immutable token;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;
    uint public count;


    constructor (address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startTime, uint32 _endTime) external {
      require(_startTime >= block.timestamp, "Start < Current time");
      require(_endTime > _startTime, "End < Start");
      
      count += 1;
      campaigns[count] = Campaign ({
        creator: msg.sender,
        goal: _goal,
        pledged: 0,
        startTime: _startTime,
        endTime: _endTime
      });

      emit Launch(count, msg.sender, _goal, _startTime, endtime);
    }

    function cancel(uint _id) external {
      Campaign memory campaign = campaigns[_id];
      require(msg.sender = campaign.creator,"Not owner");
      require(block.timestamp < campaign.startTime,"Already started");

      delete campaigns[_id];
      emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
      Campaign storage campaign = campaigns[_id];
      require(block.timestamp >= campaign.startTime, "Not started");
      require(block.timestamp <= campaign.endTime, "Ended");

      token.transferFrom(msg.sender, address(this), _amount);
      campaign.pledged += amount;
      pledgedAmount[_id][msg.sender] += amount;
      
      emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
      Campaign storage campaign = campaigns[_id];
      require(block.timestamp <= campaign.endTime, "Ended");
      require(pledgedAmount[_id][msg.sender] >= _amount,"Insufficient funds");

      campaign.pledged -= amount;
      pledgedAmount[_id][msg.sender] -= amount;
      token.transferFrom(address(this), msg.sender, _amount);

      emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
      Campaign storage campaign = campaigns[_id];
      require(msg.sender = campaign.creator,"Not owner");
      require(block.timestamp > campaign.endTime, "Not ended");
      require(campaign.pledged >= campaign.goal, "Pledged < goal");
      require(!campaign.claimed, "claimed")

      campaign.claimed = true;
      token.transferFrom(address(this), campaign.creator, campaign.pledged);

      emit Claim(_id);
    }

    function refund(uint _id) external {
      Campaign storage campaign = campaigns[_id];
      require(block.timestamp > campaign.endTime, "Not ended");
      require(campaign.pledged < campaign.goal, "Goal met");

      uint amount = pledgedAmount[_id][msg.sender];
      pledgedAmount[_id][msg.sender] = 0;
      campaign.pledged -= amount;
      token.transferFrom(address(this), msg.sender, amount);
      
      emit Refund(_id, msg.sender, amount);
    }

}