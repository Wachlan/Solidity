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

    }

    event Launch(uint indexed id, address indexed creator, uint goal, uint32 startTime, uint32 endTime);
    event Cancel(uint indexed id);
    event Pledge(uint indexed id, addressed indexed contributor, uint value);
    event Unpledge(uint indexed id, addressed indexed contributor, uint value);

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

      emit unPledge(_id, msg.sender, _amount);
    }

}