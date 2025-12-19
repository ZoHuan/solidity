// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnoptimizedCode {
    uint[] public data;

    function process(uint[] calldata values) external {
        uint len = values.length;
        uint currentLen = data.length;
        uint count = 0;

        for (uint i = 0; i < len; i++) {
            if (values[i] > 10) {
                count++;
            }
        }

        if (count > 0) {
            uint newLen = currentLen + count;
            assembly {
                // 直接扩展数组长度，避免多次 push
                sstore(add(data.slot, 0), newLen)
            }

            uint index = currentLen;
            for (uint i = 0; i < len; i++) {
                if (values[i] > 10) {
                    data[index] = values[i];
                    index++;
                }
            }
        }
    }
}
