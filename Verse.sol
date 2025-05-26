// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVoting {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 deadline;
        address creator;
        bool exists;
        bool executed;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 proposalId, string description, uint256 deadline, address creator);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    modifier proposalExists(uint256 _proposalId) {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        _;
    }

    modifier beforeDeadline(uint256 _proposalId) {
        require(block.timestamp <= proposals[_proposalId].deadline, "Voting period has ended");
        _;
    }

    modifier notVotedYet(uint256 _proposalId) {
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        _;
    }

    // Create a new proposal
    function createProposal(string memory _description, uint256 _durationMinutes) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            deadline: block.timestamp + (_durationMinutes * 1 minutes),
            creator: msg.sender,
            exists: true,
            executed: false
        });

        emit ProposalCreated(proposalCount, _description, proposals[proposalCount].deadline, msg.sender);
    }

    // Vote on a proposal
    function vote(uint256 _proposalId) 
        public 
        proposalExists(_proposalId) 
        beforeDeadline(_proposalId) 
        notVotedYet(_proposalId) 
    {
        proposals[_proposalId].voteCount++;
        hasVoted[_proposalId][msg.sender] = true;

        emit Voted(_proposalId, msg.sender);
    }

    // Execute proposal (optional action - may trigger some logic later)
    function executeProposal(uint256 _proposalId) public proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting still active");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    // View if a user has voted on a proposal
    function hasUserVoted(uint256 _proposalId, address _user) public view returns (bool) {
        return hasVoted[_proposalId][_user];
    }

    // Get proposal details
    function getProposal(uint256 _proposalId) public view returns (
        string memory description,
        uint256 voteCount,
        uint256 deadline,
        address creator,
        bool executed
    ) {
        Proposal memory p = proposals[_proposalId];
        return (p.description, p.voteCount, p.deadline, p.creator, p.executed);
    }
}
