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
    address[] investors;
    
    mapping (address => uint) pendingWithdrawals;

    event IdeaCreated(address, bytes32, uint, string, string);
    event NewInvestment(address, uint);
    event NewVote(address, bytes32, uint);


    constructor(uint _submissionEnd, uint _investEnd, uint _votesEnd) public {
        owner = msg.sender;
        submissionEnd = now + _submissionEnd;
        investEnd = now + _investEnd;
        votesEnd = now + _votesEnd;
    }


    function getInvestEnd() public view returns (uint) {
        return investEnd;
    }


    function getVotingEnd() public view returns (uint) {
        return votesEnd;
    }


    function addIdea (uint _ethNeeded, string _whitepaperUrl, string _commitHash) public {
        require(now <= submissionEnd, "The submission time already ended");

        bytes32 _ideaId = keccak256(abi.encodePacked(_commitHash));
        if (ideas[_ideaId].owner != 0x0) {
            revert("Idea submitted already exists");
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
        require(now <= investEnd, "Investment time already ended");

        if (investments[msg.sender] == 0) {
            investors.push(msg.sender);
        }
        investments[msg.sender] += msg.value;
        votesRemaining[msg.sender] += msg.value;
        
        emit NewInvestment(msg.sender, msg.value);
    }
    
    
    function getInvestors() public view returns (address[]) {
        return investors;
    }


    function vote(bytes32 _ideaId, uint _votes) public {
        require(now <= votesEnd, "Voting time already ended");
        require(ideas[_ideaId].owner != 0x0, "Idea doesn't exist");
        require(votesRemaining[msg.sender] >= _votes, "The voter doesn't have the necessary votes");

        votesRemaining[msg.sender] -= _votes;
        ideas[_ideaId].votes[msg.sender] += _votes;
        ideas[_ideaId].totalVotes += _votes;
        ideas[_ideaId].voters.push(msg.sender);
        
        emit NewVote(msg.sender, _ideaId, _votes);
    }
    
    
    function endCrowdfunding() public {
        require(now > submissionEnd, "Deadline for the submission of ideas has not been reached yet");
        require(now > investEnd, "Investment period has not ended yet");
        require(now > votesEnd, "Voting period has not ended yet");
        
        uint maxVotes = 0;
        bytes32 winningIdea;
        bool isThereWinningCampaign = false;
        for(uint i = 0; i < ideasIds.length; i++) {
            if (maxVotes < ideas[ideasIds[i]].totalVotes) {
                maxVotes = ideas[ideasIds[i]].totalVotes;
                winningIdea = ideasIds[i];
                isThereWinningCampaign = true;
            }
        }
        
        if (!isThereWinningCampaign) {
            endCrowdfundingUpdateVotesRemaining();
        } else {
            for(uint k = 0; k < ideasIds.length; k++) {
                for (uint z = 0; z < ideas[ideasIds[k]].voters.length; z++) {
                    uint amount = ideas[ideasIds[k]].votes[ideas[ideasIds[k]].voters[z]];
                    ideas[ideasIds[k]].votes[ideas[ideasIds[k]].voters[z]] = 0;
                    if (ideasIds[k] != winningIdea) {
                        pendingWithdrawals[ideas[ideasIds[k]].voters[z]] += amount;
                    } else {
                        uint weight = amount / maxVotes;
                        uint contribution;
                        if (maxVotes < ideas[ideasIds[k]].ethNeeded) {
                            contribution = weight * maxVotes;
                        } else {
                            contribution = weight * ideas[ideasIds[z]].ethNeeded;
                        }
                        pendingWithdrawals[ideas[ideasIds[k]].owner] += contribution;
                        pendingWithdrawals[ideas[ideasIds[k]].voters[z]] += amount - contribution;
                    }
                }
            }
            endCrowdfundingUpdateVotesRemaining();
        }
    }

    
    function endCrowdfundingUpdateVotesRemaining() private {
        for (uint j = 0; j < investors.length; j++) {
            uint investorEth = votesRemaining[investors[j]];
            votesRemaining[investors[j]] = 0;
            pendingWithdrawals[investors[j]] = investorEth;
        }
    }

    
    function withdraw() public {
        require(now > submissionEnd, "Deadline for the submission of ideas has not been reached yet");
        require(now > investEnd, "Investment period has not ended yet");
        require(now > votesEnd, "Voting period has not ended yet");
        require(pendingWithdrawals[msg.sender] > 0, "The caller has nothing to withdraw");
        
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    
    function getWithdrawAmount() public view returns (uint) {
        return pendingWithdrawals[msg.sender];
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
