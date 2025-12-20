// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义Proposal结构体（包含voters的mapping）
// 支持创建提案
// 支持投票（每人只能投一次）
// 查询提案信息
// 获取获胜提案
contract VotingSystem {
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 deadline;
        bool executed;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);

    function createProposal(
        string memory description,
        uint256 duration
    ) public returns (uint256) {
        require(bytes(description).length > 0, "Description required");
        require(duration > 0, "Duration must be positive");

        uint256 proposalId = proposalCount++;

        Proposal storage p = proposals[proposalId];
        p.description = description;
        p.voteCount = 0;
        p.deadline = block.timestamp + duration;
        p.executed = false;

        emit ProposalCreated(proposalId, description);
        return proposalId;
    }

    function vote(uint256 proposalId) public {
        require(proposalId < proposalCount, "Proposal does not exist");
        Proposal storage p = proposals[proposalId];

        require(block.timestamp < p.deadline, "Voting has ended");
        require(!p.voters[msg.sender], "Already voted");

        p.voters[msg.sender] = true;
        p.voteCount++;
        emit Voted(proposalId, msg.sender);
    }

    function hasVoted(
        uint256 proposalId,
        address voter
    ) public view returns (bool) {
        require(proposalId < proposalCount, "Proposal does not exist");
        return proposals[proposalId].voters[voter];
    }

    function getProposalInfo(
        uint256 proposalId
    )
        public
        view
        returns (
            string memory description,
            uint256 voteCount,
            uint256 deadline,
            bool executed
        )
    {
        require(proposalId < proposalCount, "Proposal does not exist");
        Proposal storage p = proposals[proposalId];
        return (p.description, p.voteCount, p.deadline, p.executed);
    }

    function getWinningProposal()
        public
        view
        returns (uint256 winningProposalId)
    {
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
        return winningProposalId;
    }
}
