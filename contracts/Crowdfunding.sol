pragma solidity ^0.4.24;

contract Crowdfunding{
    
    struct Idea {
        uint ethNeeded;
        string whitepaperUrl;
        string commitHash;
        bytes32 ideaId;
        address owner;
        uint totalVotes;
        mapping (address => uint) votes;
        address[] voters;
    }
    
    mapping (bytes32 => Idea) ideas;
    mapping (address => uint) investments;
    mapping (address => uint) votesRemaining;
    
    bytes32[] ideasIds;
    uint submissionEnd;
    uint investEnd;
    uint votesEnd;
    address owner;
    
    event IdeaCreated (address, bytes32, uint, string, string);
    event NewInvestment (address, uint);
    event NewInvestment (address, bytes32, uint);
    
    
    constructor(uint _submissionEnd, uint _investEnd, uint _votesEnd) public {
        owner = msg.sender;
        submissionEnd = now + _submissionEnd;
        investEnd = now + _investEnd;
        votesEnd = now + _votesEnd;
    }
    
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    function getInvestEnd() public view returns (uint) {
        return investEnd;
    }
    
    
    function getVotingEnd() public view returns (uint) {
        return votesEnd;
    }
    
    
    function addIdea (uint _ethNeeded, string _whitepaperUrl, string _commitHash) public {
        require(now <= submissionEnd);
        
        bytes32 _ideaId = keccak256(abi.encodePacked(_commitHash));
        if (ideas[_ideaId].owner != 0x0) {
            revert();
        } else {
            Idea memory newIdea;
            newIdea.ethNeeded = _ethNeeded;
            newIdea.whitepaperUrl = _whitepaperUrl;
            newIdea.commitHash = _commitHash;
            newIdea.owner = msg.sender;
            newIdea.ideaId = _ideaId;
        
            ideas[_ideaId] = newIdea;
            ideasIds.push(_ideaId);
        
            emit IdeaCreated (msg.sender, _ideaId, _ethNeeded, _whitepaperUrl, _commitHash);
        }
    }
    
    
    function invest() public payable {
        require(now <= investEnd);
        
        if (investments[msg.sender] > 0) {
            investments[msg.sender] += msg.value;
        } else {
            investments[msg.sender] = msg.value;
        }
        
        if (votesRemaining[msg.sender] > 0) {
            votesRemaining[msg.sender] += msg.value;
        } else {
            votesRemaining[msg.sender] = msg.value;
        }
    }
    
    
    function vote(bytes32 _ideaId, uint _votes) public {
        require(now <= votesEnd);
        require(ideas[_ideaId].owner != 0x0);
        require(votesRemaining[msg.sender] >= _votes);
        
        votesRemaining[msg.sender] -= _votes;
        ideas[_ideaId].votes[msg.sender] += _votes;
        ideas[_ideaId].totalVotes += _votes;
        ideas[_ideaId].voters.push(msg.sender);
    }
    
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    
    function convertCommitHashToIdeaId(string _commitHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_commitHash));
    }
    
    
    function getIdeasIds() public view returns (bytes32[]) {
        return ideasIds;
    }
    
    
    function getTotalInvestment(address _investor) public view returns (uint) {
        return investments[_investor];
    }
    
    
    function getRemainingVotes(address _investor) public view returns (uint) {
        return votesRemaining[_investor];
    }
    
    
    function getIdeaEthNeeded(bytes32 _ideaId) public view returns (uint) {
        return ideas[_ideaId].ethNeeded;
    }
    
    
    function getIdeaWhitepaperUrl(bytes32 _ideaId) public view returns (string) {
        return ideas[_ideaId].whitepaperUrl;
    }
    
    
    function getIdeaCommitHash(bytes32 _ideaId) public view returns (string) {
        return ideas[_ideaId].commitHash;
    }
    
    
    function getIdeaOwner(bytes32 _ideaId) public view returns (address) {
        return ideas[_ideaId].owner;
    }
    
    
    function getIdeaTotalVotes(bytes32 _ideaId) public view returns (uint) {
        return ideas[_ideaId].totalVotes;
    }
    
    
    function getIdeaVotes(bytes32 _ideaId, address _investor) public view returns (uint) {
        return ideas[_ideaId].votes[_investor];
    }
    
    
    function getIdeaVoters(bytes32 _ideaId) public view returns (address[]) {
        return ideas[_ideaId].voters;
    }
}
