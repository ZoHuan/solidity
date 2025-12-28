// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 public constant MAX_BATCH_SIZE = 50;
    bool private _paused;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // 暂停合约
    function pause() public onlyOwner {
        _paused = true;
    }

    // 恢复合约
    function unpause() public onlyOwner {
        _paused = false;
    }

    // 修饰器：检查是否暂停
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    // 覆写转账函数，添加暂停检查
    function transfer(
        address to,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    // 覆写授权函数，添加暂停检查
    function approve(
        address spender,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.approve(spender, amount);
    }

    // 覆写代理转账函数，添加暂停检查
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    // Mint新代币（仅限所有者）
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Burn代币（任何人可销毁自己的代币）
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
