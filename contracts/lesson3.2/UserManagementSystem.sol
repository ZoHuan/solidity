// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagementSystem {
    // TODO: 定义User结构体
    struct User {
        // name, email, balance, registeredAt, exists
        string name;
        string email;
        uint256 balance;
        uint256 registeredAt;
        bool exists;
    }

    // TODO: 定义数据存储
    mapping(address => User) public users;
    address[] public userAddresses;
    uint256 public userCount;
    uint256 public constant MAX_USERS = 1000;

    event UserRegistered(address indexed user, string name);
    event UserUpdated(address indexed user);
    event Deposit(address indexed user, uint256 amount);

    // TODO: 实现注册功能
    function register(string memory name, string memory email) public {
        // 检查是否已注册
        require(!users[msg.sender].exists, "Already registered");
        // 检查是否达到上限
        require(userCount < MAX_USERS, "Max users reached");
        require(bytes(name).length > 0, "Name required");
        require(bytes(email).length > 0, "Email required");

        // 创建用户
        users[msg.sender] = User({
            name: name,
            email: email,
            balance: 0,
            registeredAt: block.timestamp,
            exists: true
        });
        // 添加到列表
        userAddresses.push(msg.sender);
        // 更新计数
        userCount++;

        emit UserRegistered(msg.sender, name);
    }

    // 更新个人资料
    function updateProfile(string memory name, string memory email) public {
        require(users[msg.sender].exists, "Not registered");

        users[msg.sender].name = name;
        users[msg.sender].email = email;

        emit UserUpdated(msg.sender);
    }

    function deposit() public payable {
        require(users[msg.sender].exists, "Not registered");
        require(msg.value > 0, "Must send ETH");

        users[msg.sender].balance += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function getUserInfo(address user) public view returns (User memory) {
        require(users[user].exists, "User not found");
        return users[user];
    }

    function getAllUsers() public view returns (address[] memory) {
        return userAddresses;
    }

    function getUsersByRange(
        uint256 start,
        uint256 end
    ) public view returns (address[] memory) {
        require(start < end, "Invalid range");
        require(end <= userAddresses.length, "End out of bounds");

        uint256 length = end - start;
        address[] memory result = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = userAddresses[start + i];
        }

        return result;
    }

    function isRegistered(address user) public view returns (bool) {
        return users[user].exists;
    }
}
