// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TypeConversionPractice {
    function safeConvertToUint8(uint256 value) public pure returns (uint8) {
        // TODO: 添加范围检查
        require(value <= type(uint8).max, "Value too large for uint8");
        return uint8(value);
        // 如果value大于255，应该revert
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        // TODO: 实现字符串比较
        // 提示：使用keccak256
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function isZeroAddress(address addr) public pure returns (bool) {
        // TODO: 检查是否为零地址
        return addr == address(0);
    }

    // 额外测试函数
    function testConversion() public pure returns (uint8, uint8) {
        return (
            safeConvertToUint8(255), // 成功
            safeConvertToUint8(100) // 成功
        );
        // safeConvertToUint8(256) // 会revert
    }

    function testStringComparison() public pure returns (bool, bool) {
        return (
            compareStrings("Hello", "Hello"), // true
            compareStrings("Hello", "World") // false
        );
    }

    function testZeroAddress() public pure returns (bool, bool) {
        return (
            isZeroAddress(address(0)), // true
            isZeroAddress(0x0000000000000000000000000000000000001234) // false
        );
    }
}
