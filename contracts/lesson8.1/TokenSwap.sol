// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSwap {
    IERC20 public tokenA;
    IERC20 public tokenB;

    event Swap(address indexed user, uint256 amountA, uint256 amountB);

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function swap(uint256 amountA) external {
        require(
            tokenA.transferFrom(msg.sender, address(this), amountA),
            "Transfer A failed"
        );

        uint256 amountB = amountA; // 1:1兑换
        require(tokenB.transfer(msg.sender, amountB), "Transfer B failed");

        emit Swap(msg.sender, amountA, amountB);
    }
}
