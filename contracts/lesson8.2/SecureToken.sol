// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SecureToken is Ownable {
    mapping(address => uint256) public balances;

    constructor() Ownable(msg.sender) {}  // <-- Pass owner here

    function mint(address to, uint256 amount) external onlyOwner {
        balances[to] += amount;
    }

    function burn(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
    }
}