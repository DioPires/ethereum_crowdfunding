var Crowdfunding = artifacts.require("./Crowdfunding.sol");
var chai = require('chai');
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised')
chai.use(chaiAsPromissed);

var crowdfundingInstance;

var investAcc1;
var investAcc2;
var investAcc3;
var investAcc4;

var ethNeeded1;
var ethNeeded2;
var ethNeeded3;

var whitepaperUrl1;
var whitepaperUrl2;
var whitepaperUrl3;

var commitHash1;
var commitHash2;
var commitHash3;

var expectRevert = RegExp('revert');

function wait(ms){
	var start = new Date().getTime();
	var end = start;
	while(end < start + ms) {
		end = new Date().getTime();
	}
}

contract('Crowdfunding', function(accounts) {
	beforeEach( async () => {
	    userAcc = accounts[0];
	    investAcc1 = accounts[1];
	    investAcc2 = accounts[2];
	    investAcc3 = accounts[3];
	    investAcc4 = accounts[4];
	    
	    ethNeeded1 = 1000000000000000000;
        whitepaperUrl1 = "https://github.com/steemit/whitepaper/blob/master/README.md";
        commitHash1 = "3aad9baab4aad829cb13a715a43989e9a2f0a9fe";

        ethNeeded2 = 2000000000000000000;
        whitepaperUrl2 = "https://github.com/joincivil/whitepaper/blob/master/README.md";
        commitHash2 = "ad1797a758c92b027b084296847eb3ceb3bcb92f";

        ethNeeded3 = 5000000000000000000;
        whitepaperUrl3 = "https://github.com/0xbitcoin/white-paper/blob/master/README.md";
        commitHash3 = "cbef62deab74635542dc9c5936581167132c1dda";
	})

	it("should submit three ideas", async function () {
		crowdfundingInstance = await Crowdfunding.new(3600, 86400, 86400);

		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded1, whitepaperUrl1, commitHash1);
		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded2, whitepaperUrl2, commitHash2);
		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded3, whitepaperUrl3, commitHash3);

		var ideaId1 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash1);
		var ideaId2 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash2);
		var ideaId3 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash3);

		var _ethNeeded1 = await crowdfundingInstance.getIdeaEthNeeded.call(ideaId1);
		var _ethNeeded2 = await crowdfundingInstance.getIdeaEthNeeded.call(ideaId2);
		var _ethNeeded3 = await crowdfundingInstance.getIdeaEthNeeded.call(ideaId3);

		var _whitepaperUrl1 = await crowdfundingInstance.getIdeaWhitepaperUrl.call(ideaId1);
		var _whitepaperUrl2 = await crowdfundingInstance.getIdeaWhitepaperUrl.call(ideaId2);
		var _whitepaperUrl3 = await crowdfundingInstance.getIdeaWhitepaperUrl.call(ideaId3);

		var _commitHash1 = await crowdfundingInstance.getIdeaCommitHash.call(ideaId1);
		var _commitHash2 = await crowdfundingInstance.getIdeaCommitHash.call(ideaId2);
		var _commitHash3 = await crowdfundingInstance.getIdeaCommitHash.call(ideaId3);

		expect(JSON.parse(_ethNeeded1)).to.be.equal(ethNeeded1);
		expect(JSON.parse(_ethNeeded2)).to.be.equal(ethNeeded2);
		expect(JSON.parse(_ethNeeded3)).to.be.equal(ethNeeded3);

		expect(_whitepaperUrl1).to.be.equal(whitepaperUrl1);
		expect(_whitepaperUrl2).to.be.equal(whitepaperUrl2);
		expect(_whitepaperUrl3).to.be.equal(whitepaperUrl3);

		expect(_commitHash1).to.be.equal(commitHash1);
		expect(_commitHash2).to.be.equal(commitHash2);
		expect(_commitHash3).to.be.equal(commitHash3);
	})

	it("should invest 2 ETH", async function () {
		crowdfundingInstance = await Crowdfunding.new(3600, 86400, 86400);

		var investment = 2000000000000000000;
		await crowdfundingInstance.invest.sendTransaction({from: investAcc1, value: investment});

		var totalInvestment = await crowdfundingInstance.getTotalInvestment.call(investAcc1);
		var remainingVotes = await crowdfundingInstance.getRemainingVotes.call(investAcc1);

		expect(JSON.parse(totalInvestment)).to.be.equal(investment);
		expect(JSON.parse(remainingVotes)).to.be.equal(investment);
	})

	it("should invest 2 ETH and invest 0.5 ETH worth of votes", async function () {
		crowdfundingInstance = await Crowdfunding.new(3600, 86400, 86400);

		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded1, whitepaperUrl1, commitHash1);
		var ideaId1 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash1);
		
		var investment1 = 2000000000000000000;
		var votes1 = 500000000000000000;
		var investment2 = 1000000000000000000;
		var votes2 = 100000000000000000;
		await crowdfundingInstance.invest.sendTransaction({from: investAcc1, value: investment1});
		await crowdfundingInstance.invest.sendTransaction({from: investAcc2, value: investment2});
		await crowdfundingInstance.vote.sendTransaction(ideaId1, votes1, {from: investAcc1});
		await crowdfundingInstance.vote.sendTransaction(ideaId1, votes2, {from: investAcc2});

		var totalInvestment1 = await crowdfundingInstance.getTotalInvestment.call(investAcc1);
		var remainingVotes1 = await crowdfundingInstance.getRemainingVotes.call(investAcc1);
		var totalInvestment2 = await crowdfundingInstance.getTotalInvestment.call(investAcc2);
		var remainingVotes2 = await crowdfundingInstance.getRemainingVotes.call(investAcc2);

		var ideaTotalVotes = await crowdfundingInstance.getIdeaTotalVotes.call(ideaId1);
		var ideaVotes1 = await crowdfundingInstance.getIdeaVotes.call(ideaId1, investAcc1);
		var ideaVotes2 = await crowdfundingInstance.getIdeaVotes.call(ideaId1, investAcc2);
		
		expect(JSON.parse(totalInvestment1)).to.be.equal(investment1);
		expect(JSON.parse(remainingVotes1)).to.be.equal(investment1-votes1);
		expect(JSON.parse(totalInvestment2)).to.be.equal(investment2);
		expect(JSON.parse(remainingVotes2)).to.be.equal(investment2-votes2);
		expect(JSON.parse(ideaTotalVotes)).to.be.equal(votes1+votes2);
		expect(JSON.parse(ideaVotes1)).to.be.equal(votes1);
		expect(JSON.parse(ideaVotes2)).to.be.equal(votes2);
	})

	it("should invest 2 ETH and invest 0.5 ETH worth of votes, should invest 1 ETH, should end crowdfunding round", async function () {
		crowdfundingInstance = await Crowdfunding.new(3, 3, 3);

		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded1, whitepaperUrl1, commitHash1, {from: userAcc});
		var ideaId1 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash1);
		
		var investment1 = 2000000000000000000;
		var votes1 = 500000000000000000;
		var investment2 = 1000000000000000000;
		await crowdfundingInstance.invest.sendTransaction({from: investAcc1, value: investment1});
		await crowdfundingInstance.invest.sendTransaction({from: investAcc2, value: investment2});
		await crowdfundingInstance.vote.sendTransaction(ideaId1, votes1, {from: investAcc1});

		// Ensure that the voting period ends before trying to end the crowdfunding round
		wait(5000);

		await crowdfundingInstance.endCrowdfunding.sendTransaction({from: userAcc});
		var withdrawAmount1 = await crowdfundingInstance.getWithdrawAmount.call({from: investAcc1});
		var withdrawAmount2 = await crowdfundingInstance.getWithdrawAmount.call({from: investAcc2});
		var withdrawAmount3 = await crowdfundingInstance.getWithdrawAmount.call({from: userAcc});

		await crowdfundingInstance.withdraw.sendTransaction({from: userAcc});
		await crowdfundingInstance.withdraw.sendTransaction({from: investAcc1});
		await crowdfundingInstance.withdraw.sendTransaction({from: investAcc2});

		expect(JSON.parse(withdrawAmount1)).to.be.equal(investment1-votes1);
		expect(JSON.parse(withdrawAmount2)).to.be.equal(investment2);
		expect(JSON.parse(withdrawAmount3)).to.be.equal(votes1);
	})

	it("should fail to end crowdfunding round because end time not reached yet", async function () {
		crowdfundingInstance = await Crowdfunding.new(3600, 86400, 86400);

		await crowdfundingInstance.addIdea.sendTransaction(ethNeeded1, whitepaperUrl1, commitHash1, {from: userAcc});
		var ideaId1 = await crowdfundingInstance.convertCommitHashToIdeaId.call(commitHash1);
		
		var investment1 = 2000000000000000000;
		var votes1 = 500000000000000000;
		var investment2 = 1000000000000000000;
		await crowdfundingInstance.invest.sendTransaction({from: investAcc1, value: investment1});
		await crowdfundingInstance.invest.sendTransaction({from: investAcc2, value: investment2});
		await crowdfundingInstance.vote.sendTransaction(ideaId1, votes1, {from: investAcc1});

		var reverted = false;
		await crowdfundingInstance.endCrowdfunding.sendTransaction({from : userAcc}).catch(
			(err) => {
				reverted = expectRevert.test(err.message);
			});
		expect(reverted).to.be.equal(true,"Revert expected");
	})

});
