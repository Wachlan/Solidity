// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;


contract Voting {
  uint256 public constant VOTE_DURATION = 2 minutes;
  uint256 private startTime_;
  string[] public candidates_;
  string public winner_;

  mapping(uint8 => uint256) public candidateTotals_;
  mapping(uint8 => string) private candidateIds_; // so we can get strings

 
  event voteCast(address voter, string candidate);
  event VoteStillActive(uint256 remainingTime);
  event VoteComplete(string winner);

  constructor() public {
    startTime_ = block.timestamp;

    // Hardcoded candidates
    candidates_.push("Adam");
    candidateIds_[0] = "Adam";
    candidates_.push("Becky");
    candidateIds_[1] = "Becky";

    /************************
     * Add other candidates *
     ***********************/

  }

  // Cast your vote
  function castVote(uint8 _candidate) external {
    if (block.timestamp <= startTime_ + VOTE_DURATION) {

       // Increment the vote for the candidate
       candidateTotals_[_candidate] += 1;

       // Emit an event to show a vote has been cast, passing in the candidate name
       emit voteCast(msg.sender, candidateIds_[_candidate]);

    } else {
      emit VoteComplete(winner_);
    }
  }

  // Tally the vote and publicize the results
  function tallyVote() public {
    if (block.timestamp > startTime_ + VOTE_DURATION) {

      uint8 currentWinner;

      // Find the winner, candidate with most votes
      for (uint8 i = 0; i < candidates_.length; i++) {
        if (candidateTotals_[i] > currentWinner) {
            currentWinner = i;
        }
      }

       // Set the winner
       winner_ = candidates_[currentWinner];


       // Emit event to show the winner
       emit VoteComplete(winner_);


    // Vote duration has not elapsed
    } else {
      emit VoteStillActive((startTime_ + VOTE_DURATION) - block.timestamp);
    }
  }
}