// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Voting {
  uint256 public VOTE_DURATION;
  uint256 private startTime_;
  string[] public candidates_;
  string public winner_;
  bool public voteStarted_;

  mapping(uint8 => uint256) public candidateTotals_;
  mapping(uint8 => string) public candidateIds_; // so we can get strings
  mapping(address => bool) private voters_;

 
  event voteCast(address voter, string candidate);
  event VoteStillActive(uint256 remainingTime);
  event VoteComplete(string winner);
  event voteStarted();

  constructor(uint256 voteDuration) public {
    VOTE_DURATION = voteDuration;
    voteStarted_ = false;
    
  }

  // Register as candidate
  function registerCandidate(string memory _candidate) external {
    require(!voteStarted_, "Vote started");

    candidates_.push(_candidate);
    candidateIds_[0] = _candidate;
  }

  // Register as voter
  function registerVoter() external {
    require(!voteStarted_, "Vote started");

    voters_[msg.sender] = true;
  }

  // Start the vote
  function startVote() external {
    require(!voteStarted_,"Vote started");
    require(candidates_.length > 1);
    voteStarted_ = true;
    startTime_ = block.timestamp;
    emit voteStarted();
  }

  // Cast your vote
  function castVote(uint8 _candidate) external {
    require(voters_[msg.sender],"Not registered");
    require(voteStarted_, "Vote not started");
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