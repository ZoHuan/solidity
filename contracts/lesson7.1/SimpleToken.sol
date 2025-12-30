// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleToken {
    string public name = "Simple Token";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    // Transfer事件
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    // Approval事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    // 构造函数：铸造初始供应量
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        
        // 铸造时from为address(0)
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // 转账函数
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        // 更新余额
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        // 触发Transfer事件
        emit Transfer(msg.sender, to, amount);
        
        return true;
    }
    
    // 授权函数
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Invalid spender");
        
        // 设置授权额度
        allowance[msg.sender][spender] = amount;
        
        // 触发Approval事件
        emit Approval(msg.sender, spender, amount);
        
        return true;
    }
    
    // 授权转账函数
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(from != address(0), "Invalid sender");
        require(to != address(0), "Invalid recipient");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        // 更新余额和授权额度
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        // 触发Transfer事件
        emit Transfer(from, to, amount);
        
        return true;
    }
    
    // 销毁代币
    function burn(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        // 更新余额和总供应量
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        
        // 销毁时to为address(0)
        emit Transfer(msg.sender, address(0), amount);
    }
}