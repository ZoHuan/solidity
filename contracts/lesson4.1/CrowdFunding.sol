// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    enum State {
        Fundraising,
        Success,
        Failed,
        PaidOut
    }

    State public currentState;
    uint public targetAmount;
    uint public totalFunded;
    uint public deadline;
    address public owner;
    mapping(address => uint) public contributions;

    event Funded(address indexed contributor, uint amount);
    event StateChanged(State newState);
    event Withdrawn(address indexed recipient, uint amount);

    modifier inState(State _state) {
        require(currentState == _state, "Invalid state");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint _targetAmount, uint _duration) {
        owner = msg.sender;
        targetAmount = _targetAmount;
        deadline = block.timestamp + _duration;
        currentState = State.Fundraising;
    }

    function contribute() external payable inState(State.Fundraising) {
        require(block.timestamp < deadline, "Deadline passed");
        require(msg.value > 0, "Amount must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalFunded += msg.value;

        emit Funded(msg.sender, msg.value);
    }

    function checkGoalReached() public inState(State.Fundraising) {
        if (block.timestamp >= deadline || totalFunded >= targetAmount) {
            currentState = totalFunded >= targetAmount
                ? State.Success
                : State.Failed;
            emit StateChanged(currentState);
        }
    }

    function withdrawFunds() external onlyOwner inState(State.Success) {
        require(totalFunded > 0, "No funds to withdraw");

        // CEI (Checks-Effects-Interactions) pattern
        uint amount = totalFunded;
        totalFunded = 0;
        currentState = State.PaidOut;

        // Transfer funds to owner
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(owner, amount);
        emit StateChanged(currentState);
    }

    function refund() external inState(State.Failed) {
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution to refund");

        // CEI pattern
        contributions[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // Fallback to prevent accidental ETH transfers in wrong states
    fallback() external payable {
        revert("Cannot send ETH directly");
    }

    receive() external payable {
        revert("Cannot send ETH directly");
    }
}
