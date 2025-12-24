// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedCrowdfunding {
    enum State {
        Fundraising,
        Successful,
        Failed,
        PaidOut
    }

    State public currentState = State.Fundraising;

    address public immutable CREATOR;
    uint public immutable GOAL;
    uint public immutable DEADLINE;
    uint public immutable MINIMUM_CONTRIBUTION = 0.01 ether;

    uint public totalFunded;
    uint public contributorCount;

    mapping(address => uint) public contributions;
    address[] public contributors;

    event StateChanged(State oldState, State newState, uint timestamp);
    event Contribution(
        address indexed contributor,
        uint amount,
        uint totalFunded
    );
    event FundsWithdrawn(address indexed creator, uint amount);
    event Refunded(address indexed contributor, uint amount);

    modifier inState(State expected) {
        require(currentState == expected, "Invalid state");
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == CREATOR, "Only creator");
        _;
    }

    constructor(uint goalAmount, uint durationDays) {
        require(goalAmount > 0, "Goal must be positive");
        require(durationDays >= 1 && durationDays <= 90, "Duration: 1-90 days");

        CREATOR = msg.sender;
        GOAL = goalAmount;
        DEADLINE = block.timestamp + (durationDays * 1 days);
    }

    // 贡献资金
    function contribute() public payable inState(State.Fundraising) {
        require(block.timestamp <= DEADLINE, "Fundraising ended");
        require(msg.value >= MINIMUM_CONTRIBUTION, "Below minimum");

        // 新贡献者
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
            contributorCount++;
        }

        contributions[msg.sender] += msg.value;
        totalFunded += msg.value;

        emit Contribution(msg.sender, msg.value, totalFunded);

        // 达到目标自动成功
        if (totalFunded >= GOAL) {
            State oldState = currentState;
            currentState = State.Successful;
            emit StateChanged(oldState, State.Successful, block.timestamp);
        }
    }

    // 检查并更新状态
    function checkGoalReached() public inState(State.Fundraising) {
        require(block.timestamp > DEADLINE, "Still active");

        State oldState = currentState;
        State newState;

        if (totalFunded >= GOAL) {
            newState = State.Successful;
        } else {
            newState = State.Failed;
        }

        currentState = newState;
        emit StateChanged(oldState, newState, block.timestamp);
    }

    // 创建者提取资金
    function withdrawFunds() public onlyCreator inState(State.Successful) {
        currentState = State.PaidOut;

        uint amount = address(this).balance;
        (bool sent, ) = CREATOR.call{value: amount}("");
        require(sent, "Transfer failed");

        emit FundsWithdrawn(CREATOR, amount);
    }

    // 退款
    function refund() public inState(State.Failed) {
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution");

        contributions[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Refund failed");

        emit Refunded(msg.sender, amount);
    }

    // 查询函数
    function getInfo()
        public
        view
        returns (
            State state,
            uint goal,
            uint funded,
            uint deadline,
            uint timeRemaining,
            uint contributors
        )
    {
        uint remaining = 0;
        if (block.timestamp < DEADLINE) {
            remaining = DEADLINE - block.timestamp;
        }

        return (
            currentState,
            GOAL,
            totalFunded,
            DEADLINE,
            remaining,
            contributorCount
        );
    }

    function getProgress() public view returns (uint percentage) {
        return (totalFunded * 100) / GOAL;
    }

    function isActive() public view returns (bool) {
        return currentState == State.Fundraising && block.timestamp <= DEADLINE;
    }
}
