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
  mapping(uint => mapping(address => bool)) public approved;  // For a transaction ID, keep track of which addresses have approved a transaction

  transaction[] public transactions;

  event Deposit(address indexed sender, uint value);
  event Approve(address indexed owner, uint indexed id);
  event Submit(address indexed owner, uint indexed id);
  event Revoke(address indexed  owner, uint indexed id);
  event Execute(uint indexed id);
  
  // Only allow access for wallet owners 
  modifier onlyOwner() {
    require(isOwner[msg.sender], "Only owner");
    _;
  }

  // Make sure a transaction exists
  modifier tranExists(uint id) {
    require(id < transactions.length);
    _;
  }

  // Make sure a transaction has not been executed
  modifier notExecuted(uint id) {
    require(!transactions[id].executed, "Already executed");
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

  receive() external payable {
    emit Deposit(msg.sender, msg.value);
  }

  function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
    transaction memory trans;
    trans.to = _to;
    trans.value = _value;
    trans.data = _data;
    trans.executed = false;
    transactions.push(trans);
    emit Submit(msg.sender, transactions.length - 1);
  }

  function approve(uint id) external onlyOwner tranExists(id) notExecuted(id) {
    approved[id][msg.sender] = true;
    emit Approve(msg.sender, id);
  }

  function revokeApproval(uint id) external onlyOwner tranExists(id) notExecuted(id) {
    approved[id][msg.sender] = false;
    emit Revoke(msg.sender, id);
  }

  function getApprovalNumber(uint id) public returns (uint aprNum) {
    for (uint i = 0; i < owners.length; i++) {
      if (approved[id][owners[i]] = true) {
        aprNum += 1;
      }
    }
  }

  function execute(uint id) external onlyOwner tranExists(id) notExecuted(id) {
    uint approvalNum = getApprovalNumber(id);
    require(approvalNum >= required, "Not enough approvals");

    transaction storage Trans = transactions[id];
    Trans.executed = true;
    (bool success, ) = Trans.to.call{value: Trans.value}(Trans.data);
    require(success,"Transaction failed");
    emit Execute(id);
  }


}