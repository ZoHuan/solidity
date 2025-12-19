// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeArrayManager {
    uint[] public data;
    uint public constant MAX_SIZE = 100;

    event ElementAdded(uint value, uint index);
    event ElementRemoved(uint index, uint value);

    // TODO: 实现以下功能

    // 1. 安全添加
    function safePush(uint value) public {
        // 检查大小限制
        require(data.length < MAX_SIZE, "Array is full");
        // 添加元素
        data.push(value);

        emit ElementAdded(value, data.length - 1);
    }

    // 2. 保序删除
    function removeOrdered(uint index) public {
        // 检查索引
        require(index < data.length, "Index out of bounds");
        // 移动元素
        uint removedValue = data[index];
        for (uint i = index; i < data.length - 1; i++) {
            data[i] = data[i + 1];
        }
        // pop最后元素
        data.pop();

        emit ElementRemoved(index, removedValue);
    }

    // 3. 快速删除
    function removeUnordered(uint index) public {
        // 检查索引
        require(index < data.length, "Index out of bounds");
        // 替换为最后元素
        uint removedValue = data[index];
        data[index] = data[data.length - 1];
        // pop
        data.pop();

        emit ElementRemoved(index, removedValue);
    }

    // 4. 分批求和
    function sumRange(uint start, uint end) public view returns (uint) {
        // 检查范围
        require(start < end, "Invalid range");
        require(end <= data.length, "End out of bounds");

        // 计算总和
        uint total = 0;
        for (uint i = start; i < end; i++) {
            total += data[i];
        }
        return total;
    }

    // 5. 查找元素
    function findElement(uint value) public view returns (bool, uint) {
        uint len = data.length;
        // 遍历查找
        for (uint i = 0; i < len; i++) {
            if (data[i] == value) {
                return (true, i);
            }
        }
        // 返回是否找到和索引
        return (false, 0);
    }

    // 6. 获取所有元素
    function getAll() public view returns (uint[] memory) {
        // 返回整个数组
        return data;
    }

    // 辅助功能
    function getLength() public view returns (uint) {
        return data.length;
    }

    function isEmpty() public view returns (bool) {
        return data.length == 0;
    }

    function isFull() public view returns (bool) {
        return data.length >= MAX_SIZE;
    }
}
