// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PracticeContract {
    uint256[] public numbers;
    address public immutable ADMIN; // ✅ 改为immutable
    uint256 public constant MULTIPLIER = 2; // ✅ 改为constant

    function batchProcess(
        uint256[] calldata inputs // ✅ 改为calldata
    ) external {
        require(msg.sender == ADMIN, "Not admin");

        uint256 length = inputs.length;

        for (uint i = 0; i < length; i++) {
            uint256 result = inputs[i] * MULTIPLIER; // ✅ 使用constant
            numbers.push(result);
        }
    }

    function getSum() external view returns (uint256) {
        require(msg.sender == ADMIN, "Not admin");

        uint256 sum = 0;
        uint256 length = numbers.length;
        for (uint i = 0; i < length; i++) {
            sum += numbers[i];
        }
        return sum;
    }
}
