// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
A multi-signature wallet where:
- Any owner can submit a transaction
- All owners can approve and revoke approval of pending transactions
- Anyone can execute a transaction after enough owners have approved it.
*/

contract MultiSigWallet {

  struct transaction {
    address to;
    uint value;
    bytes data;
    bool executed;
  }

  address[] public owners;
  mapping(address => bool) public isOwner;
  uint public required;  // Required number of approvals to send a transaction

  transaction[] public transactions;
  
  modifier onlyOwner() {
    require(isOwner[msg.sender], "Only owner");
    _;
  }

  constructor (address[] memory _owners, uint requiredApprovals) {
    require(_owners.length > 0, "Cannot have 0 owners");
    require(requiredApprovals > 0 && requiredApprovals <= _owners.length, "Invalid approval number");
    required = requiredApprovals;

    for (uint i = 0; i < _owners.length; i++) {
      address owner = _owners[i];
      require(owner != address(0), "Invalid address");
      require(!isOwner[owner], "Duplicate owner");

      owners.push(owner);
      isOwner[owner] = true;
    }

  }





}