// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    struct Todo {
        string task;
        bool completed;
        uint256 timestamp;
    }
    
    // 每个用户的待办列表
    mapping(address => Todo[]) private userTodos;
    uint public constant MAX_TODOS = 100;
    
    event TodoAdded(address indexed user, uint index, string task);
    event TodoCompleted(address indexed user, uint index);
    event TodoDeleted(address indexed user, uint index);
    
    // 添加待办
    function addTodo(string memory task) public {
        require(bytes(task).length > 0, "Task cannot be empty");
        require(bytes(task).length <= 200, "Task too long");
        require(userTodos[msg.sender].length < MAX_TODOS, "Todo list is full");
        
        userTodos[msg.sender].push(Todo({
            task: task,
            completed: false,
            timestamp: block.timestamp
        }));
        
        emit TodoAdded(msg.sender, userTodos[msg.sender].length - 1, task);
    }
    
    // 标记为完成
    function completeTodo(uint index) public {
        require(index < userTodos[msg.sender].length, "Index out of bounds");
        require(!userTodos[msg.sender][index].completed, "Already completed");
        
        userTodos[msg.sender][index].completed = true;
        emit TodoCompleted(msg.sender, index);
    }
    
    // 删除待办（快速删除，不保序）
    function deleteTodo(uint index) public {
        require(index < userTodos[msg.sender].length, "Index out of bounds");
        
        uint lastIndex = userTodos[msg.sender].length - 1;
        
        if(index != lastIndex) {
            userTodos[msg.sender][index] = userTodos[msg.sender][lastIndex];
        }
        
        userTodos[msg.sender].pop();
        emit TodoDeleted(msg.sender, index);
    }
    
    // 获取所有待办
    function getAllTodos() public view returns (Todo[] memory) {
        return userTodos[msg.sender];
    }
    
    // 获取待办数量
    function getTodoCount() public view returns (uint) {
        return userTodos[msg.sender].length;
    }
    
    // 获取未完成的待办
    function getPendingTodos() public view returns (Todo[] memory) {
        Todo[] memory allTodos = userTodos[msg.sender];
        uint pendingCount = 0;
        
        // 计算未完成数量
        for(uint i = 0; i < allTodos.length; i++) {
            if(!allTodos[i].completed) {
                pendingCount++;
            }
        }
        
        // 创建结果数组
        Todo[] memory pending = new Todo[](pendingCount);
        uint index = 0;
        
        // 填充结果
        for(uint i = 0; i < allTodos.length; i++) {
            if(!allTodos[i].completed) {
                pending[index] = allTodos[i];
                index++;
            }
        }
        
        return pending;
    }
    
    // 获取已完成的待办
    function getCompletedTodos() public view returns (Todo[] memory) {
        Todo[] memory allTodos = userTodos[msg.sender];
        uint completedCount = 0;
        
        for(uint i = 0; i < allTodos.length; i++) {
            if(allTodos[i].completed) {
                completedCount++;
            }
        }
        
        Todo[] memory completed = new Todo[](completedCount);
        uint index = 0;
        
        for(uint i = 0; i < allTodos.length; i++) {
            if(allTodos[i].completed) {
                completed[index] = allTodos[i];
                index++;
            }
        }
        
        return completed;
    }
}