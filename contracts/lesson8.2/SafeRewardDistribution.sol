// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SafeRewardDistribution {
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimDeadline;
    uint256 public constant CLAIM_PERIOD = 30 days;

    function setReward(address user, uint256 amount) external {
        rewards[user] = amount;
        claimDeadline[user] = block.timestamp + CLAIM_PERIOD;
    }

    function claimReward() external {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No reward");
        require(block.timestamp <= claimDeadline[msg.sender], "Expired");

        rewards[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
