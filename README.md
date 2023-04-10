# Chainlink-Foundry Toolkit

> **Warning**
>
> **This package is currently in BETA.**
>
> **Open issues to submit bugs.**

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

3. Install and run Docker; for convenience, the Chainlink nodes run in a container. Instructions: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/).

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
We use the [chainlink](chainlink) folder as shared folder with Chainlink node Docker images. Its contents as follows:

#### Settings
- [chainlink_api_credentials](chainlink%2Fsettings%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](chainlink%2Fsettings%2Fchainlink_password) - Chainlink password

> **Note**  
> More info on authentication can be found here [github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API](https://github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API).
> You can specify any credentials there. Password provided must be 16 characters or more.
#### Jobs
- [cron_job.toml](chainlink%2Fjobs%2Fcron_job.toml) - example configuration file for a Chainlink Cron job  
- [direct_request_job.toml](chainlink%2Fjobs%2Fdirect_request_job.toml) - example configuration file for a Chainlink Direct Request job  
- [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml) - example configuration file for a Chainlink Keeper job  
- [webhook_job.toml](chainlink%2Fjobs%2Fwebhook_job.toml) - example configuration file for a Chainlink Webhook job  

> **Note**  
> More info on Chainlink v2 Jobs, their types and configuration can be found here: [docs.chain.link/chainlink-nodes/oracle-jobs/jobs/](https://docs.chain.link/chainlink-nodes/oracle-jobs/jobs/).
> You can change this configuration according to your requirements.

### Environment variables
Based on the [env.template](env.template) - create or update an `.env` file in the root directory of your project.  

Below are comments on some environment variables:
- `ETH_URL` - RPC node web socket used by the Chainlink node
- `RPC_URL` - RPC node http endpoint used by Forge
- `PRIVATE_KEY` - private key of an account used for deployment and interaction with smart contracts. Once Anvil is started, a set of private keys for local usage is provided. Use one of these for local development.
- `ROOT` - root directory of the Chainlink node
- `CHAINLINK_CONTAINER_NAME` - preferred name for the container of the Chainlink node for the possibility of automating communication with it

Besides that, there is the [chainlink.env](chainlink%2Fchainlink.env) that contains environment variables related to a Chainlink node configuration.
> **Note**  
> More info on Chainlink node environment variables can be found here: [https://docs.chain.link/chainlink-nodes/v1/configuration](https://docs.chain.link/chainlink-nodes/v1/configuration).
> You can specify any parameters according to your preferences.

### Solidity Scripting
Functionality related to deployment and interaction with smart contracts is implemented using [Foundry Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=script#solidity-scripting).  
The [script](script) directory contains scripts for the Link Token, Oracle, Chainlink Consumer contracts, as well as the transfer of ETH and Link tokens.  
Scripts are run with the command: `forge script path/to/script`. Logs and artifacts dedicated to each script run, including a transaction hash and an address of deployed smart contract, are stored in a corresponding subdirectory of the [broadcast](broadcast) folder (created automatically).

All necessary scripts are also included in the [makefile](makefile). In order to run these scripts, you first need to install the necessary dependencies:
```
make install
```

This command installs:
- [Forge Standard Library](https://github.com/foundry-rs/forge-std)
- [Chainlink Contracts](https://github.com/smartcontractkit/chainlink)
- [Openzeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

## Usage
Below are the scripts contained in the makefile[makefile](makefile). Some scripts have parameters that can be passed either on the command line, interactively or in the `.env` file.

### Helper scripts

#### Spin up a Chainlink node
  ```
  make run-nodes
  ```
  This command spins up a cluster of 5 Chainlink nodes (necessary to run OCR jobs). It fetches images, creates/recreates and starts containers according to the [docker-compose.yaml](docker-compose.yaml).
  Once Chainlink nodes are launched, a node Operator GUI will be available at:
  - http://127.0.0.1:6711 - Chainlink node 1
  - http://127.0.0.1:6722 - Chainlink node 2
  - http://127.0.0.1:6733 - Chainlink node 3
  - http://127.0.0.1:6744 - Chainlink node 4
  - http://127.0.0.1:6755 - Chainlink node 5 

  For authorization, you must use the credentials specified in the [chainlink_api_credentials](chainlink%2Fchainlink_api_credentials).
   > **Note**  
   > To run a single Chainlink node you can use [docker-compose-single.yaml](docker-compose-single.yaml).  
   > Node Operator GUI: http://127.0.0.1:6688  

   > **Note**  
   > For **ARM64** users. When starting a docker container, there will be warnings:  
   > ```The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested```  
   > You can safely ignore these warnings, container will start normally.

#### Restart Chainlink node
  ```
  make restart-nodes
  ```
  This command restarts Chainlink nodes cluster according to the [docker-compose.yaml](docker-compose.yaml).

#### Login Chainlink node
  ```
  make login
  ```
  This command authorizes a Chainlink operator session.  

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Get Chainlink node info
  ```
  make get-info
  ```
  This command returns data related to Chainlink node's EVM Chain Accounts, e.g.:
  - Account address (this is the address for a Chainlink node wallet)
  - Link token balance
  - ETH balance  

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

   > **Note**  
   > You also can find this information in the node Operator GUI under the Key Management configuration.

### Smart Contracts Deployment Scripts
> **Note**  
> All contracts are deployed on behalf of the account specified in [.env](.env).

#### Deploy Link Token contract
  ```
  make deploy-link-token
  ```
  This command deploys an instance of [LinkToken.sol](src%2FLinkToken.sol) contract.

#### Deploy Oracle contract
  ```
  make deploy-oracle
  ```
  This command deploys an instance of [Oracle.sol](src%2FOracle.sol) contract and whitelists Chainlink node address in the deployed contract.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - LINK_CONTRACT_ADDRESS - Link Token contract address

#### Deploy Consumer contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of [ChainlinkCronConsumer.sol](src%2FChainlinkCronConsumer.sol) contract.

#### Deploy Cron Consumer contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of [ChainlinkConsumer.sol](src%2FChainlinkConsumer.sol) contract.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address

#### Deploy Keeper Consumer contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of [ChainlinkKeeperConsumer.sol](src%2FChainlinkKeeperConsumer.sol) contract.

#### Deploy Keeper Registry contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of Chainlink Registry.sol contract.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address

### Helper Solidity Scripts

#### Transfer ETH
  ```
  make transfer-eth
  ```
  With this command, you can send ETH to any specified recipient.  

  During the execution of the command, you will need to enter:
  - RECIPIENT - Recipient address

#### Transfer ETH to Chainlink node
  ```
  make transfer-eth-to-node
  ```
  With this command, you can send ETH to any specified Chainlink node.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Transfer Link tokens
  ```
  make transfer-link
  ```
  With this command, you can send Link tokens to any specified recipient.  

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address
  - RECIPIENT - Recipient address

#### Transfer Link tokens to Chainlink node
  ```
  make transfer-link-tonode
  ```
  With this command, you can send Link tokens to any specified Chainlink node.  

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - LINK_CONTRACT_ADDRESS - Link Token contract address

### Chainlink Jobs Scripts

#### Create Chainlink Direct Request job
  ```
  make create-direct-request-job
  ```
  This command creates a Chainlink job according to [direct_request_job.toml](chainlink%2Fjobs%2Fdirect_request_job.toml). 

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - ORACLE_ADDRESS - Oracle contract address

#### Create Chainlink Cron job
  ```
  make create-cron-job
  ```
  This command creates a Chainlink job according to [cron_job.toml](chainlink%2Fjobs%2Fcron_job.toml).

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - CRON_CONSUMER_ADDRESS - Cron consumer contract address

#### Create Chainlink Webhook job
  ```
  make create-webhook-job
  ```
  This command creates a Chainlink job according to [webhook_job.toml](chainlink%2Fjobs%2Fwebhook_job.toml).

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Run Chainlink Webhook job
  ```
  make run-webhook-job
  ```
  This command runs an existing Chainlink Webhook job.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - JOB_ID - Webhook job ID

#### Create Chainlink Keeper job
  ```
  make create-keeper-job
  ```
  This command creates a Chainlink job according to [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml).

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - REGISTRY_ADDRESS - Registry contract address

#### Create Chainlink Keeper jobs
  ```
  make create-keeper-jobs
  ```
  This command creates Chainlink job for each Chainlink node in a cluster according to [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml).

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address

   > **Note**  
   > You can check list of created jobs with Chainlink Operator GUI.

### Chainlink Consumer Solidity Scripts

#### Request ETH price
  ```
  make request-eth-price-consumer
  ```
  This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.  

  During the execution of the command, you will need to enter:
  - CONSUMER_ADDRESS - Consumer contract address
  - ORACLE_ADDRESS - Oracle contract address
  - JOB_ID - External Job ID **without dashes** - you can get one with Chainlink Operator GUI on the Jobs tab

   > **Note**  
   > You can check list of runs of jobs with Chainlink Operator GUI.

#### Get ETH price
  ```
  make get-eth-price-consumer
  ```
  This command returns current value of `currentPrice` variable specified in the Consumer contract state.  

  During the execution of the command, you will need to enter:
  - CONSUMER_ADDRESS - Consumer contract address

### Chainlink Cron Consumer Solidity Scripts

#### Get ETH price
  ```
  make get-eth-price-cron-consumer
  ```
  This command returns current value of `currentPrice` variable specified in the Consumer contract state.

  During the execution of the command, you will need to enter:
  - CRON_CONSUMER_ADDRESS - Cron Consumer contract address

### Chainlink Registry Solidity Scripts

#### Register Keeper Consumer
  ```
  make register-upkeep
  ```
  This command registers Keeper Consumer in the Registry contract as upkeep.

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address
  - KEEPER_CONSUMER_ADDRESS - Keeper Consumer contract address

#### Set Keepers
  ```
  make set-keepers
  ```
  This command sets Chainlink nodes in the cluster as keepers in the Registry contract.

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address
  - KEEPER_CONSUMER_ADDRESS - Keeper Consumer contract address

#### Get Upkeep ID
  ```
  make get-last-active-upkeep-id
  ```
  This command gets an ID of the last registered upkeep in the Registry contract.

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address

### Link Token Solidity Scripts

#### Transfer-and-Call Link Token
  ```
  make transfer-and-call-link
  ```
  This command transfers Link tokens to the Registry contract and calls it's `onTokenTransfer` method that verifies that an upkeep is funded.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address
  - REGISTRY_ADDRESS - Registry contract address
  - UPKEEP_ID - Keeper Consumer upkeep ID

### Chainlink Keeper Consumer Solidity Scripts

#### Get Keeper Counter
  ```
  make get-keeper-counter
  ```
  This command gets the latest value of the `counter` variable stored in the Keeper Consumer contract. This variable reflects the number of times the keepers performed the Keeper job.

  During the execution of the command, you will need to enter:
  - KEEPER_CONSUMER_ADDRESS - Keeper Consumer contract address

> **Note**  
> In the current version of the package, some smart contracts are developed for different compiler versions.  
> Therefore, specifying a version of Solidity compiler in ```foundry.toml``` or as a ```forge``` parameter (e.g. ```--use solc:0.7.0```) can lead to errors.  
> Use a default compiler version provided by ```forge```.  
> This issue will be fixed in future releases.

### Testing flows
#### Initial setup
1. Deploy Link Token contract
2. Set `LINK_TOKEN_CONTRACT` in `.env`
3. Spin up a Chainlink nodes cluster
4. Fund Chainlink nodes with ETH
6. Fund Chainlink nodes with Link tokens

#### Direct Request Job
1. Deploy Oracle contract
2. Deploy Consumer contract
3. Fund Consumer contract with Link tokens
4. Create Direct Request Job
5. Request ETH price with Consumer contract, a corresponding job will be launched
6. Get ETH price after completing a job

#### Cron Job
1. Deploy Cron Consumer contract
2. Create Cron Job
3. Get ETH price after completing a job

#### Webhook Job
1. Create Webhook Job
2. Run Webhook Job

#### Keeper Job
1. Deploy Keeper Consumer contract
2. Deploy Registry contract
3. Create Keeper Jobs for Chainlink nodes in a cluster
4. Register Chainlink nodes as keepers in a Registry contract
5. Register Keeper Consumer as upkeep in a Registry contract
6. Get last upkeep ID in the Registry contract and run `Transfer and Call Link` script
7. Get value of `counter` variable in a Keeper contract

## Acknowledgements
This project based on https://github.com/protofire/hardhat-chainlink-plugin. 
