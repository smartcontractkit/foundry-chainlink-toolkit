# Chainlink-Foundry Toolkit

**This is a toolkit that makes spinning up, managing and testing a local Chainlink node easier.**  

This project uses [Foundry](https://book.getfoundry.sh) tools to deploy and test smart contracts.  
It can be easily integrated into an existing Foundry project.

## Table of Contents<!-- TOC -->
* [Overview](#overview)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Chain RPC node](#chain-rpc-node)
  * [Chainlink shared folder](#chainlink-shared-folder)
  * [Solidity Scripting](#solidity-scripting)
  * [Environment variables](#environment-variables)
* [Usage](#usage)
  * [Available scripts](#available-scripts)
  * [Testing](#testing)
* [Acknowledgements](#acknowledgements)
<!-- TOC -->

## Overview
The purpose of this project is to simplify the immersion in the development and testing of smart contracts using Chainlink oracles. This project is aimed primarily at those who use the Foundry toolchain.

## Getting Started

### Prerequisites
1. Install Foundry toolchain. Reference the below commands or go to the [Foundry documentation](https://book.getfoundry.sh/getting-started/installation).

    - MacOS/Linux
      ```
      curl -L https://foundry.paradigm.xyz | bash
      ```
      This will download foundryup. Restart your terminal session, then install Foundry by running:
      ```
      foundryup
      ```

2. Install [GNU make](https://www.gnu.org/software/make/). The functionality of the project is wrapped in the [makefile](makefile). Reference the below commands based on your OS or go to [Make documentation](https://www.gnu.org/software/make/manual/make.html).

   - MacOS: install [Homebrew](https://brew.sh/) first, then run
      ```
      brew install make
      ```

    - Debian/Ubuntu
      ```
      apt install make
      ```

    - Fedora/RHEL
      ```
      yum install make
      ```

3. Install and run Docker; for convenience, the Chainlink node runs in a container. Instructions: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/).

### Chain RPC node
In order for a Chainlink node to be able to interact with the blockchain, and to interact with the blockchain using the [Forge](https://book.getfoundry.sh/forge/), you have to know an RPC node http endpoint and web socket for a chosen network compatible with Chainlink.
In addition to the networks listed in [this list](https://docs.chain.link/chainlink-automation/supported-networks/), Chainlink is compatible with any EVM-compatible networks.

For local testing, we recommend using [Anvil](https://book.getfoundry.sh/anvil/), which is a part of the Foundry toolchain.

Run Anvil using the following command:
```
anvil --block-time 10
```

By default, Anvil runs with the following options:
- http endpoint: http://localhost:8545
- web socket: [ws://localhost:8545](ws://localhost:8545)
- chain ID: 31337

### Chainlink shared folder
We use the [chainlink](chainlink) folder as shared folder with Chainlink node Docker image. Its contents as follows:
- [chainlink_api_credentials](chainlink%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](chainlink%2Fchainlink_password) - Chainlink password

> **Note**  
> More info on authentication can be found here [github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API](https://github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API).
> You can specify any credentials there. Password provided must be 16 characters or more.
- [directRequestJob.toml](chainlink%2FdirectRequestJob.toml) - example configuration file for a Chainlink Direct Request job  

> **Note**  
> More info about Chainlink v2 Jobs, their types and configuration can be found here: [docs.chain.link/chainlink-nodes/oracle-jobs/jobs/](https://docs.chain.link/chainlink-nodes/oracle-jobs/jobs/).
> You can change this configuration according to your requirements.

### Environment variables file
Based on the [env.template](env.template) - create or update an `.env` file in the root directory of your project.

Below are comments on some environment variables:
- `ETH_URL` - RPC node web socket used by the Chainlink node
- `RPC_URL` - RPC node http endpoint used by Forge
- `PRIVATE_KEY` - private key of an account used for deployment and interaction with smart contracts. Once Anvil is started, a set of private keys for local usage is provided. Use one of these for local development.
- `ROOT` - root directory of the Chainlink node
- `CHAINLINK_CONTAINER_NAME` - preferred name for the container of the Chainlink node for the possibility of automating communication with it

### Solidity Scripting
Functionality related to deployment and interaction with smart contracts is implemented using [Foundry Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=script#solidity-scripting).  
The [script](script) directory contains scripts for the Link Token, Oracle, Chainlink Consumer contracts, as well as the transfer of ETH and Link tokens.  
Scripts are run with the command: `forge script path/to/script`. Logs and artifacts dedicated to each script run, including a transaction hash and an address of deployed smart contract, are stored in a corresponding subdirectory of the [broadcast](broadcast) folder (created automatically).

All necessary scripts are also included in the [makefile](makefile). In order to run these scripts, you first need to install the necessary dependencies:
```
make install
```

This command installs [Forge Standard Library](https://github.com/foundry-rs/forge-std).

## Usage

### Available scripts

#### Spin up a Chainlink node
  ```
  make run-node
  ```
  This command fetches images, creates/recreates and starts containers according to the [docker-compose.yaml](docker-compose.yaml).  
  Once the container is launched, the node Operator GUI will be available at http://127.0.0.1:6688. For authorization, you must use the credentials specified in the [chainlink_api_credentials](chainlink%2Fchainlink_api_credentials).

#### Restart Chainlink node
  ```
  make restart-node
  ```
  This command restarts containers according to the [docker-compose.yaml](docker-compose.yaml).

#### Get Chainlink node info
  ```
  make get-info
  ```
  This command authorizes a Chainlink operator session and returns data related to it's EVM Chain Accounts, e.g.:
  - Account address (this is the address for a Chainlink node wallet)
  - Link token balance
  - ETH balance  

   > **Note**  
   > You also can find this information in the node Operator GUI under the Key Management configuration.

#### Deploy Link Token contract
  ```
  make deploy-link-token
  ```
  This command deploys an instance of [LinkToken.sol](src%2FLinkToken.sol) contract on behalf of the account specified in [.env](.env).

#### Deploy Oracle contract
  ```
  make deploy-oracle
  ```
  This command deploys an instance of [Oracle.sol](src%2FOracle.sol) contract on behalf of the account specified in [.env](.env) and whitelists Chainlink node address in the deployed contract.  
  During the execution of the command, you will need to enter:
  - Link Token contract address
  - Chainlink node address

#### Deploy Chainlink Consumer contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of [ChainlinkConsumer.sol](src%2FChainlinkConsumer.sol) contract on behalf of the account specified in [.env](.env).  
  During the execution of the command, you will need to enter:
  - Link Token contract address

#### Transfer ETH
  ```
  make transfer-eth
  ```
  With this command, you can send ETH to any specified recipient on behalf of the account specified in [.env](.env).  
  During the execution of the command, you will need to enter:
  - Recipient address

#### Transfer Link tokens
  ```
  make transfer-link
  ```
  With this command, you can send Link tokens to any specified recipient on behalf of the account specified in [.env](.env).  
  During the execution of the command, you will need to enter:
  - Link Token contract address
  - Recipient address

#### Create Chainlink job
  ```
  make create-job
  ```
  This command creates a Chainlink job according to [directRequestJob.toml](chainlink%2FdirectRequestJob.toml).  
  During the execution of the command, you will need to enter:
  - Oracle contract address

   > **Note**  
   > You can check list of created jobs with Chainlink Operator GUI http://127.0.0.1:6688/jobs

#### Request ETH price
  ```
  make request-eth-price-consumer
  ```
  This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.  
  During the execution of the command, you will need to enter:
  - Consumer contract address
  - Oracle contract address
  - Job ID **without dashes** - you can get one with Chainlink Operator GUI on the Jobs tab

   > **Note**  
   > You can check list of runs of jobs with Chainlink Operator GUI: http://127.0.0.1:6688/runs

#### Get ETH price
  ```
  make get-eth-price-consumer
  ```
  This command returns current value of `currentPrice` variable specified in the Consumer contract state.  
  During the execution of the command, you will need to enter:
  - Consumer contract address

### Testing
Testing flow is based on the [Chainlink fulfilling requests](https://docs.chain.link/chainlink-nodes/v1/fulfilling-requests) tutorial. 

In order to test your setup, follow these steps:
1. Spin up a Chainlink node.
2. Deploy Link Token contract.
3. Deploy Oracle contract.
4. Deploy Consumer contract.
5. Fund Chainlink node with ETH.
6. Fund Chainlink node with Link tokens.
7. Fund Consumer contract with Link tokens.
8. Create Chainlink Job.
9. Request ETH price with Consumer contract. A corresponding job will be launched.
10. Get ETH price after completing a job.

## Acknowledgements
This project based on https://github.com/protofire/hardhat-chainlink-plugin. 
