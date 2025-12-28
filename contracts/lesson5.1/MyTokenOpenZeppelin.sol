// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MyTokenOpenZeppelin is ERC20, Ownable, Pausable {
    uint256 public constant MAX_BATCH_SIZE = 50;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        // 修复：添加 Ownable(msg.sender)
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // 覆写暂停/恢复函数，添加 onlyOwner 修饰器
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // 覆写转账函数，添加 whenNotPaused 修饰器
    function transfer(
        address to,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    // Mint 新代币（仅限所有者）
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Burn 代币（任何人可销毁自己的代币）
    function burn(uint256 amount) public whenNotPaused {
        _burn(msg.sender, amount);
    }

    // 批量转账
    function batchTransfer(
        address[] memory recipients,
        uint256[] memory amounts
    ) public whenNotPaused returns (bool) {
        require(
            recipients.length == amounts.length,
            "BatchTransfer: array length mismatch"
        );
        require(
            recipients.length <= MAX_BATCH_SIZE,
            "BatchTransfer: max batch size exceeded"
        );

        uint256 totalAmount;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        require(
            balanceOf(msg.sender) >= totalAmount,
            "BatchTransfer: insufficient balance"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }
}
