# Ethereum Crowdfunding
Smart contracts for a crowdfunding platform built on top of Ethereum blockchain.

## Scope
This project enables the creation of crowdfunding campaigns in the Ethereum blockchain. By deploying the `Crowdfunding` smart contract, users submit ideas to be funded, and investors can send ETH to the smart contract and vote for the ideas they like the most. The amount of ETH in Wei each investor sends to the contract is the amount of votes available for voting in the different ideas.

The contract is coded in a way that accepts a single round of ideas submission, investment and voting. This means that once the contract is deployed, the owner of the contract sets the three end dates for submitting ideas, for submitting investments and for voting. Once these dates end, a new contract should be deployed and a new round of crowdfunding for ideas begins.

## Usage

The contract allows for the creation of ideas, to send ETH to invest and vote for ideas.

### Creating ideas
To create an idea for crowdfunding, the amount needed to fund the idea, the URL of the whitepaper and its commit hash need to be sent to the contract. A Dapp or any user directly can use the method with the following signature: 
```
function addIdea (uint _ethNeeded, string _whitepaperUrl, string _commitHash) public
```

The value of `_ethNeeded` should be sent in Wei. For example, if the idea needs 10 ETH to be funded, its creator should call the method with the value of `10000000000000000000`.

From these inputs, a `struct` is created that includes them and a few more needed fields to enable the management of ideas. Important fields that can be used later are:
* `bytes32 ideaId`: an ID that is the keccak256 computed from the commit hash, which is used to **access a given idea**
* `uint totalVotes`: total amount of votes for a given idea

### Sending investment
To send investment to the contract, the method with the following signature should be called **with the amount of ETH** the investor wants to submit to the contract:
```
function invest() public payable
```

After the investment is sent, the investor will have an amount of votes equal to the amount of ETH in Wei he submitted. For example, if he submitted 10 ETH to the contract, he will have `10000000000000000000` votes that he can use in the different ideas as he sees fit.

### Voting for ideas
Voting for ideas implies that an investment has already been made. For example, if a user wants to vote with `100000000000000000` votes, it means he should have already sent 0.1 ETH as investment to the contract. To vote for a given idea, the method with the following signature can be used:
```
function vote(bytes32 _ideaId, uint _votes) public
```

### End the crowdfunding round
Assuming the voting period has already ended, ending the crowdfunding round means that a method is called that verifies the idea with the most votes and transfers the amount of ETH it needed to its owner. More ETH can have been sent to the contract and the idea can have more votes than the ETH it needed (since votes are proportional to the ETH submitted as investment). In this case, some ETH should be sent back to the corresponding investors.

Starting from the investors of the winning idea, the contract checks the total amount of votes and computes the weight of the votes of each of the idea voters and sends the ETH. For example, let us assume an idea that needed 10 ETH to be funded and 20 ETH worth of votes had been cast to the idea. Let us also assume that there were 4 voters were one voted with 10 ETH worth of votes, another with 5 ETH worth of votes and the remaining 2 with 2.5 ETH worth of votes each.

In this scenario, the contract computes a weight of `0.5` to the one that voted with 10 ETH, `0.25` to the one that voted with 5 ETH, and `0.125` to each of the other two. Then, it would send `0.5 * 10 = 5 ETH` from the first voter, `0.25 * 10 = 2.5 ETH` from the second voter, and `0.125 * 10 = 1.25 ETH` from each of the remaining two. The remaining investment of each of these investors/voters is returned to them. Lastly, all the other investors that voted for ideas different from the winning one also get their ETH back.

The end of the crowdfunding round can be triggered by calling the method with the following signature:
```
function endCrowdfunding() public
```

**NOTE:** sending the ETH automatically can pose a security risk. Therefore, the contract implements a withdrawal pattern where triggering the end of the crowdfunding results in the remaining investments being available for withdrawal by their respective investors. Withdrawing the investment, assuming crowdfunding round is ended and there are investments to be withdrawn, can be done by calling the method with the following signature:
```
function withdraw() public
```

### Reading ideas and their fields
To get all the IDs of the submitted ideas, one can use the method with the following signature:
```
function getIdeasIds() public view returns (bytes32[])
```

To get the amount of ETH (in Wei) that an idea needs to be funded, one can use the method with the following signature:
```
function getIdeaEthNeeded(bytes32 _ideaId) public view returns (uint)
```

To get the URL of the whitepaper of an idea, one can use the method with the following signature:
```
function getIdeaWhitepaperUrl(bytes32 _ideaId) public view returns (string)
```

To get the commit hash of the whitepaper of an idea in GitHub, one can use the method with the following signature:
``` 
function getIdeaCommitHash(bytes32 _ideaId) public view returns (string)
```

To get the total votes for a given idea, one can use the method with the following signature:
```
function getIdeaTotalVotes(bytes32 _ideaId) public view returns (uint)
```

## Running the tests
To run the tests, one should just need to go to the project's directory and run:
```
truffle test
```
