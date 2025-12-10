# A projext that is used to add a nominee to a crypto wallet
# This project demonstrates basic working of the service that automatically transfers available crypto currency to the nominee wallet after certain hearbeat time period
# The owner needs to sign the service for every heartbeat tine period to stop tranfering funds to the nominee wallet
# Used Hardhat for simulating local block chain network and generating Fake Funds with fake wallets woth address
# This also contains a kill switch for immedeiate funds trasfer to nominee account in case of urgency

After Installing hardhat v2 from npm 
Configure the Hardhat to the project then,
Try these shell commands to run the project directory



This command starts the block chain node
```shell
npx hardhat node
```
Open new terminal and run
```shell
npx hardhat run scritps/deploy.js --network localnet
```
In new terminal run the forntend server
```shell
cd frontend
npx serve .
```
Connect Metamask wallets for simulating the Transactions use custom network by hardhat and custom account by hardhat
Use Private keys of accounts for adding owner and nominee wallets
A value of 10,000 ETH are shown for generating fake transactions

Connect the wallet and add the contract address to see the user type in the frontend

Use below commands for configuring hardhat for test network
```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
