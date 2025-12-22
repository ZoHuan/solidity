// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeBatchTransfer {
    mapping(address => uint) public balances;
    uint public constant MAX_BATCH_SIZE = 50;

    event Transfer(address indexed from, address indexed to, uint amount);
    event BatchTransfer(address indexed from, uint count, uint totalAmount);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function batchTransfer(
        address[] memory recipients,
        uint[] memory amounts
    ) public {
        // 1. 检查数组长度相等
        require(recipients.length == amounts.length, "Length mismatch");

        // 2. 限制批量大小
        require(recipients.length <= MAX_BATCH_SIZE, "Batch too large");

        // 3. 预先计算总金额
        uint totalAmount = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        // 4. 检查余额充足
        require(balances[msg.sender] >= totalAmount, "Insufficient balance");

        // 5. 验证所有地址和金额
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid address");
            require(amounts[i] > 0, "Invalid amount");
        }

        // 6. 执行转账（所有检查都通过后）
        for (uint i = 0; i < recipients.length; i++) {
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];

            emit Transfer(msg.sender, recipients[i], amounts[i]);
        }

        emit BatchTransfer(msg.sender, recipients.length, totalAmount);
    }

    function getBalance(address user) public view returns (uint) {
        return balances[user];
    }
}
