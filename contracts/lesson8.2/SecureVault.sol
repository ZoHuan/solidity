// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 使用CEI模式修复
contract SecureVaultCEI {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        // Checks
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        // Effects
        balances[msg.sender] = 0;

        // Interactions
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}

// 使用重入锁修复
contract SecureVaultLock {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external noReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
