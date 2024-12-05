// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline;

  event Stake(address, uint256);

  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Staking process is completed");
    _;
  }

  

  constructor(address exampleExternalContractAddress) {
      require(exampleExternalContractAddress != address(0), "Invalid Address");
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() external payable notCompleted(){
    require(msg.value > 0, "amount cannot be 0");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() external notCompleted {
    require(block.timestamp > deadline, "try again later");
    require(address(this).balance >= threshold, "threshold has not been met");
    (bool success, ) = address(exampleExternalContract).call{ value: address(this).balance}(abi.encodeWithSignature('complete()'));
    require(success, "Could not complete the transaction");
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() external {
    require(block.timestamp >= deadline, "Deadline has not passed");
    require(address(this).balance < threshold, "Threshold met, cannot withdraw");
    require(balances[msg.sender] > 0, "No balance to withdraw");

    (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
    require(success, "Withdrawal Failed");

    balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() external view returns(uint256) {
    if(deadline > block.timestamp){
      return deadline - block.timestamp;
    }else {
      return 0;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  function recieve() external payable {
    
  }
}
