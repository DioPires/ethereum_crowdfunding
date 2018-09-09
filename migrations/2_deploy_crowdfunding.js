var Crowdfunding = artifacts.require("./Crowdfunding.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'development':
            deployer.deploy(Crowdfunding, process.env.SUBMISSION_END, process.env.INVESTMENT_END, process.env.VOTING_END);
            break;

        case 'ropsten':
	    deployer.deploy(Crowdfunding, process.env.SUBMISSION_END, process.env.INVESTMENT_END, process.env.VOTING_END);
            break;

        case 'main':
	    deployer.deploy(Crowdfunding, process.env.SUBMISSION_END, process.env.INVESTMENT_END, process.env.VOTING_END);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
