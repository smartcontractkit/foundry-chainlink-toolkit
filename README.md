# Foundry-Chainlink Toolkit

**A toolkit to spin up and manage a local Chainlink node with Foundry ([Forge CLI](https://book.getfoundry.sh/forge/)).**

## Getting Started
1. Make sure Forge CLI is installed ```forge --version```  or install it following the instructions: https://book.getfoundry.sh/getting-started/installation
2. Install GNU make to use makefile provided
3. Open Docker Desktop
4. Install forge CLI dependencies with `make install`

## Functionality
Project functionality is wrapped in makefile scripts for convenience.\
Interaction with the Chainlink node occurs through docker.\
Part of the functionality of this project related to interaction with smart contracts is made using [Foundry Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=script#solidity-scripting).\
In the `./script` directory presented scripts for deployment of Link Token and Oracle contracts, as well as transfer of ETH and Link tokens.

## Prerequisites
We use /chainlink folder as shared folder with Chainlink node Docker image, there are:
- [chainlink_api_credentials](chainlink%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](chainlink%2Fchainlink_password) - Chainlink password
- [createJob.toml](chainlink%2FcreateJob.toml) - example configuration file to create a Chainlink job
Based on env.example - create .env in the root.

## Available scripts
- Spin up Chainlink node [fetch images and build containers]: `make run-node`
- Restart Chainlink node: `make restart-node`
- Get Chainlink node info: `make get-info`
- Create Chainlink job: `make create-job` [provide a correct Chainlink node address to the [createJob.toml](chainlink%2FcreateJob.toml)]
- Deploy Link Token contract: `make deploy-link-token`
- Deploy Oracle contract: `make deploy-oracle`
- Transfer Link tokens: `make transfer-link`
- Transfer ETH: `make transfer-eth`
