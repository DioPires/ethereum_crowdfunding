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

From these inputs, a `struct` is created that includes them and a few more needed fields to enable the management of ideas.

### Sending investment
To send investment to the contract, the method with the following signature should be called **with the amount of ETH** the investor wants to submit to the contract:
```
function invest() public payable
```

After the investment is sent, the investor will have an amount of votes equal to the amount of ETH in Wei he submitted. For example, if he submitted 10 ETH to the contract, he will have `10000000000000000000` votes that he can use in the different ideas as he sees fit.
