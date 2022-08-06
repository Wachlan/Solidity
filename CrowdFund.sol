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

    event Launch(uint id, address creator, uint goal, uint32 startTime, uint32 endTime);

    IERC20 public immutable token;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public contribution;
    uint public count;


    constructor (address _token) {
        token = IERC20(_token);
    }

    function launch (uint _goal, uint32 _startTime, uint32 _endTime) external {
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

}