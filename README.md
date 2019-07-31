# Decentralized marketplace
## Consensys Bootcamp Final Project - Solidity Dapp
The project implement the Online Marketplace project proposal as described in the ConsenSys Academy’s 2019 Developer Program Final Project Specification. Please review such document for more specific information. 

***

# Setup
- Be sure to test the project in the standard environment suggested for the course. 
- Be sure to have installed npm or other pakage manager. The following guide will assume that npm has been installed.
- Install Truffle `npm install -g truffle`
- Install Ganache `npm install -g ganache-cli`

In the terminal run:
`ganache-cli` 
in order to start a local node for testing purposes. 

On a separate terminal run:
`npm install`
to download the node dependencies (openZeppelin in this case). 
Once done, run:
`truffle compile`
to compile the contracts.
Once compiled run:
`truffle migrate`
for deploying the compiled contract on the local node you started before. This guide assume a standar configuaration as used during the course. 
Finally:
`truffle test`
to run the test. All tests should pass. 

***

# TO DO:
- [] Ui
- [] Deploy
(sorry fot the bad english)
