// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MessageBoard {
    // 定义事件：用户地址indexed，便于查询某用户的所有留言
    event MessagePosted(
        address indexed user,       // indexed：查询某用户的留言
        string message,             // 不indexed：完整内容
        uint256 timestamp           // 不indexed：时间戳
    );
    
    // 发布留言函数
    function postMessage(string memory message) public {
        require(bytes(message).length > 0, "Message cannot be empty");
        require(bytes(message).length <= 280, "Message too long");
        
        // 触发事件
        emit MessagePosted(msg.sender, message, block.timestamp);
    }
}