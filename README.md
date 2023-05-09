# Chainlink-Foundry Toolkit

> **Warning**
>
> **This package is currently in BETA.**
>
> **Open issues to submit bugs.**

**This is a toolkit that makes spinning up, managing and testing a local Chainlink node easier.**  

This project uses [Foundry](https://book.getfoundry.sh) tools to deploy and test smart contracts.  
It can be easily integrated into an existing Foundry project.

<!-- TOC -->
* [Chainlink-Foundry Toolkit](#chainlink-foundry-toolkit)
  * [Overview](#overview)
  * [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Chain RPC node](#chain-rpc-node)
    * [Chainlink shared folders](#chainlink-shared-folders)
    * [Environment variables](#environment-variables)
    * [Chainlink Consumer Contracts](#chainlink-consumer-contracts)
    * [Solidity Scripting](#solidity-scripting)
  * [Usage](#usage)
    * [Helper scripts](#helper-scripts)
    * [Smart Contracts Deployment Scripts](#smart-contracts-deployment-scripts)
    * [Chainlink Jobs Scripts](#chainlink-jobs-scripts)
    * [Helper Solidity Scripts](#helper-solidity-scripts)
    * [Link Token Solidity Scripts](#link-token-solidity-scripts)
    * [Chainlink Consumer Solidity Scripts](#chainlink-consumer-solidity-scripts)
    * [Chainlink Cron Consumer Solidity Scripts](#chainlink-cron-consumer-solidity-scripts)
    * [Chainlink Keeper Consumer Solidity Scripts](#chainlink-keeper-consumer-solidity-scripts)
    * [Registry Solidity Scripts](#registry-solidity-scripts)
    * [Offchain Aggregator Solidity Scripts](#offchain-aggregator-solidity-scripts)
    * [Flux Aggregator Solidity Scripts](#flux-aggregator-solidity-scripts)
    * [Testing flows](#testing-flows)
      * [Initial setup](#initial-setup)
      * [Direct Request Job](#direct-request-job)
      * [Cron Job](#cron-job)
      * [Webhook Job](#webhook-job)
      * [Keeper Job](#keeper-job)
      * [OCR Job](#ocr-job)
      * [Flux Job](#flux-job)
  * [Acknowledgements](#acknowledgements)
<!-- TOC -->

## Overview
The purpose of this project is to simplify the immersion in the development and testing of smart contracts using Chainlink oracles. This project is aimed primarily at those who use the Foundry toolchain.

## Project Structure

### Chainlink [*](chainlink)
This directory contains configuration files, scripts and smart contracts source code.  

#### Contracts [*](chainlink%2Fcontracts)
- [ChainlinkConsumer.sol](chainlink%2Fcontracts%2FChainlinkConsumer.sol) - example consumer contract for [Chainlink Direct Request Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs/#direct-request-jobs)
- [ChainlinkCronConsumer.sol](chainlink%2Fcontracts%2FChainlinkCronConsumer.sol) - example consumer contract for [Chainlink Cron Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#solidity-cron-jobs)
- [ChainlinkKeeperConsumer.sol](chainlink%2Fcontracts%2FChainlinkKeeperConsumer.sol) - example consumer contract for [Chainlink Keeper Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#keeper-jobs)
- [LinkToken.sol](chainlink%2Fcontracts%2FLinkToken.sol) - flattened [Link Token contract](https://github.com/smartcontractkit/LinkToken)

#### Jobs [*](chainlink%2Fjobs)
- [cron_job.toml](chainlink%2Fjobs%2Fcron_job.toml) - example configuration file for a Chainlink [Cron job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#solidity-cron-jobs)
- [direct_request_job.toml](chainlink%2Fjobs%2Fdirect_request_job.toml) - example configuration file for a Chainlink [Direct Request job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#direct-request-jobs)
- [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml) - example configuration file for a Chainlink [Flux job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#flux-monitor-jobs)
- [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml) - example configuration file for a Chainlink [Keeper job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#keeper-jobs)
- [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml) - example configuration file for a Chainlink [OCR job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#off-chain-reporting-jobs)
- [ocr_job_bootstrap.toml](chainlink%2Fjobs%2Focr_job_bootstrap.toml) - example configuration file for a Chainlink OCR (bootstrap) job
- [webhook_job.toml](chainlink%2Fjobs%2Fwebhook_job.toml) - example configuration file for a Chainlink [Webhook job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs/#webhook-jobs)

> **Note**  
> More info on Chainlink v2 Jobs, their types and configuration can be found here: [docs.chain.link/chainlink-nodes/oracle-jobs/jobs/](https://docs.chain.link/chainlink-nodes/oracle-jobs/jobs/).  
> You can change these configuration according to your requirements.

#### Setting [*](chainlink%2Fsettings)
- [chainlink_api_credentials](chainlink%2Fsettings%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](chainlink%2Fsettings%2Fchainlink_password) - Chainlink password

> **Note**  
> More info on authentication can be found here [github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API](https://github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API).  
> You can specify any credentials there. Password provided must be 16 characters or more.

#### SQL [*](chainlink%2Fsql)
- [create_tables.sql](chainlink%2Fsql%2Fcreate_tables.sql) - sql script to create tables related to Chainlink nodes in a Postgres DB
- [drop_tables.sql](chainlink%2Fsql%2Fdrop_tables.sql) - sql script to delete tables related to Chainlink nodes in a Postgres DB

#### Chainlink nodes logs directories
Once Chainlink nodes are started, log directories will be created for each of them.

#### chainlink.env [*](chainlink%2Fchainlink.env)
This file contains environment variables related to Chainlink node configuration. You can modify it according to your requirements.  
More info on Chainlink environment variables can be found here: https://docs.chain.link/chainlink-nodes/v1/configuration.

> **Note**  
> Subdirectories: [jobs](chainlink%2Fjobs), [settings](chainlink%2Fsettings) and [sql](chainlink%2Fsql) are used as shared folders for running Chainlink nodes and Postgres DB containers.

### External [*](external)
This directory contains external libraries.

#### OCRHelper [*](external%2FOCRHelper)
This Go library is based on https://github.com/smartcontractkit/chainlink integration tests and is used to prepare configuration parameters for Offchain Aggregator contract.  
It has pre-built binaries for platforms: darwin/amd64(x86_64), darwin/arm64, linux/amd64(x86_64), linux/arm,linux/arm64.  
> **Note**  
> If you use another platform, please run in advance:  
> ```make build-ocr-helper```  
> To build the external library for your platform.  
> It requires Go (1.18 or higher) installed.

### Script [*](script)
This directory contains Solidity Scripts to deploy and interact with Solidity smart contracts:
- Link Token
- Oracle
- Registry
- Flux and Offchain aggregators
- Chainlink Consumer contracts
- Helper Solidity Scripts  

You can run these scripts with the command: `forge script path/to/script [--args]`. Logs and artifacts dedicated to each script run, including a transaction hash and an address of a deployed smart contract, are stored in a corresponding subdirectory of the [broadcast](broadcast) folder (created automatically).  
More info on Foundry Solidity Scripting can be found here: https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=script#solidity-scripting.

### Src [*](src)
#### Interfaces [*](src%2Finterfaces)
This directory contains interfaces to interact with Solidity contracts deployed using its pre-built artifacts ([build Chainlink contracts artifacts](#build-chainlink-contracts)). This is necessary in order to reduce dependence on a specific version of Solidity compiler.

#### Mocks [*](src%2Fmocks)
This directory contains mock Solidity contracts used for testing purposes:
- [MockAccessController.sol](src%2Fmocks%2FMockAccessController.sol) - mock contract used during deployment of Offchain Aggregator contract
- [MockAggregatorValidator.sol](src%2Fmocks%2FMockAggregatorValidator.sol) - mock contract used during deployment of Flux Aggregator contract
- [MockEthFeed.sol](src%2Fmocks%2FMockEthFeed.sol) - mock contract used during deployment of Registry contract
- [MockGasFeed.sol](src%2Fmocks%2FMockGasFeed.sol) - mock contract used during deployment of Registry contract

## Getting Started

### Prepare local environment
1. Install Foundry toolchain. Reference the below commands or go to the [Foundry documentation](https://book.getfoundry.sh/getting-started/installation).

    - MacOS/Linux
      ```
      curl -L https://foundry.paradigm.xyz | bash
      ```
      This will download foundryup. Restart your terminal session, then install Foundry by running:
      ```
      foundryup
      ```
      
    > **Note**  
    Tested with forge 0.2.0 (e99cf83 2023-04-21T00:15:57.602861000Z).  
    > ---
    > You may see the following error on MacOS:  
    ```dyld: Library not loaded: /usr/local/opt/libusb/lib/libusb-1.0.0.dylib```  
    In order to fix this, you should install libusb:  
    ```brew install libusb```   
    Reference: https://github.com/foundry-rs/foundry/blob/master/README.md#troubleshooting-installation

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

    > **Note**  
      Tested with GNU Make 3.81.

3. Install and run Docker; for convenience, the Chainlink nodes run in a container. Instructions: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/).

    > **Note**  
    Tested with Docker version 20.10.23, build 7155243.

### Set up chain RPC node
In order for a Chainlink node to be able to interact with the blockchain, and to interact with the blockchain using the [Forge](https://book.getfoundry.sh/forge/), you have to know an RPC node http endpoint and web socket for a chosen network compatible with Chainlink.
In addition to the networks listed in [this list](https://docs.chain.link/chainlink-automation/supported-networks/), Chainlink is compatible with any EVM-compatible networks.

For local testing, we recommend using [Anvil](https://book.getfoundry.sh/anvil/), which is a part of the Foundry toolchain.  
You can run it using the following command:
```
make anvil
```

This command runs Anvil with the following options:
- http endpoint: http://localhost:8545
- web socket: [ws://localhost:8545](ws://localhost:8545)
- chain ID: 1337
- block period: 10s
- mnemonic: test test test test test test test test test test test junk

### Set up environment variables
Based on the [env.template](env.template) - create or update an `.env` file in the root directory.  

Below are comments on some environment variables:
- `ETH_URL` - RPC node web socket used by the Chainlink node
- `RPC_URL` - RPC node http endpoint used by Forge
- `PRIVATE_KEY` - private key of an account used for deployment and interaction with smart contracts. Once Anvil is started, a set of private keys for local usage is provided. Use one of these for local development
- `ROOT` - root directory of the Chainlink node
- `CHAINLINK_CONTAINER_NAME` - preferred name for the container of the Chainlink node for the possibility of automating communication with it
- `FOUNDRY_PROFILE` - selected Foundry profile in [foundry.toml](foundry.toml), more on Foundry profiles: https://book.getfoundry.sh/reference/config/overview?highlight=profile#profiles

> **Note**  
> If environment variables related to a Chainlink node, such as the Link Token contract address, were changed during your work you should run the ```make run-nodes``` command in order for them to be applied.

### Install Forge dependencies
In order to install necessary Forge dependencies you need to run:
```
make install
```

This command installs:
- [Forge Standard Library](https://github.com/foundry-rs/forge-std)
- [Chainlink Contracts](https://github.com/smartcontractkit/chainlink-brownie-contracts) [version:0.6.1]
- [Chainlink Testing Framework Contracts](https://github.com/smartcontractkit/chainlink-testing-framework) [version:v1.11.5]
- [Link Token Contract](https://github.com/smartcontractkit/LinkToken)
- [Openzeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) [version:v4.8.2]

### Perform the initial setup
1. [Build Chainlink contracts artifacts](#build-chainlink-contracts)
2. [Deploy Link Token contract](#deploy-link-token-contract)
3. Set `LINK_TOKEN_CONTRACT` in `.env`
4. [Spin up a Chainlink nodes cluster](#spin-up-a-chainlink-cluster)
5. [Fund Chainlink nodes with ETH](#transfer-eth-to-chainlink-nodes)
6. [Fund Chainlink nodes with Link tokens](#transfer-link-tokens-to-chainlink-nodes)

### Chainlink Jobs setting up flows

#### Direct Request Job
1. [Deploy Oracle contract](#deploy-oracle-contract)
2. [Deploy Consumer contract](#deploy-consumer-contract)
3. [Fund Consumer contract with Link tokens](#transfer-link-tokens)
4. [Create Direct Request Job](#create-chainlink-direct-request-job)
5. [Request ETH price with Consumer contract, a corresponding job will be launched](#request-eth-price)
6. [Get ETH price after completing a job](#get-eth-price)

#### Cron Job
1. [Deploy Cron Consumer contract](#deploy-cron-consumer-contract)
2. [Create Cron Job](#create-chainlink-cron-job)
3. [Get ETH price after completing a job](#get-eth-price--cron-)

#### Webhook Job
1. [Create Webhook Job](#create-chainlink-webhook-job)
2. [Run Webhook Job](#run-chainlink-webhook-job)

#### Keeper Job
1. [Deploy Keeper Consumer contract](#deploy-keeper-consumer-contract)
2. [Deploy Registry contract](#deploy-keeper-registry-contract)
3. [Create Keeper Jobs for Chainlink nodes in a cluster](#create-chainlink-keeper-jobs)
4. [Register Chainlink nodes as keepers in a Registry contract](#set-keepers)
5. [Register Keeper Consumer as upkeep in a Registry contract](#register-keeper-consumer)
6. [Fund the latest upkeep in a Registry contract](#fund-latest-upkeep)
7. [Get value of `counter` variable in a Keeper contract](#get-keeper-counter)

#### OCR Job
1. [Deploy Offchain Aggregator contract](#deploy-chainlink-offchain-aggregator-contract)
2. [Set Offchain Aggregator payees](#set-payees)
3. [Set Offchain Aggregator config](#set-config)
4. [Create OCR Job for a bootstrap Chainlink node (first in a cluster)](#create-chainlink-ocr--bootstrap--job)
5. [Create OCR Jobs for Chainlink nodes in a cluster except the first one (bootstrap)](#create-chainlink-ocr-jobs)
6. [Request new OCR round in the Offchain Aggregator contract (optional)](#request-new-round)
7. [Get the answer of the latest OCR round from the Offchain Aggregator contract](#get-ocr-latest-answer)

#### Flux Job
1. [Deploy Flux Aggregator contract](#deploy-chainlink-flux-aggregator-contract)
2. [Fund Flux Aggregator contract with Link tokens](#transfer-link-tokens)
3. [Update Flux Aggregator available funds](#update-available-funds)
4. [Set Flux Aggregator oracles](#set-oracles)
5. [Create Flux Jobs for the first 3 Chainlink nodes in a cluster](#create-chainlink-flux-jobs)
6. [Get the answer of the latest Flux round from the Flux Aggregator contract](#get-flux-latest-answer)

## Makefile scripts
Below are the scripts contained in the [makefile](makefile).  
Some scripts have parameters that can be provided either with the command line (e.g. ```make target PARAM={value}```), in the `.env` file, or interactively in the command line.
> **Note**  
> Ethereum addresses should be provided in the EIP55 format.  
> If you are referring to the address of a contract deployed with a script below, you can find it in the correct format:
> - in a corresponding subdirectory of the [broadcast](broadcast) directory in the "returns" section of an artifacts *.json file
> - in the "== Return ==" section of the command line output of a deployment script  
> 
> You can also use an online tool to get EIP55 formatted address, e.g. https://web3-tools.netlify.app/.

### Helper scripts

#### Build Chainlink Contracts
  ```
  make build-chainlink-contracts
  ```
  This command builds Chainlink contracts artifacts.
  The contracts to be built:
  - Contracts from external libraries: Oracle, Registry related contracts, Flux and Offchain Aggregators
  - Link Token contract located in the [contracts](chainlink%2Fcontracts) directory
  - Chainlink Consumer contracts examples located in the [contracts](chainlink%2Fcontracts) directory

#### Spin up a Chainlink cluster
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

  For authorization, you must use the credentials specified in the [chainlink_api_credentials](chainlink%2Fsettings%2Fchainlink_api_credentials).
   > **Note**  
   > To run a single Chainlink node you can use [docker-compose-single.yaml](docker-compose-single.yaml).  
   > Node Operator GUI: http://127.0.0.1:6688  

   > **Note**  
   > For **ARM64** users. When starting a docker container, there will be warnings:  
   > ```The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested```  
   > You can safely ignore these warnings, container will start normally.

#### Restart a Chainlink cluster
  ```
  make restart-nodes
  ```
  This command restarts Chainlink nodes cluster according to the [docker-compose.yaml](docker-compose.yaml).  
  Pass argument `CLEAN_RESTART` if you want to make a clean restart: delete all volumes and logs.

#### Login a Chainlink node
  ```
  make login
  ```
  This command authorizes a Chainlink operator session.  

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

#### Get Chainlink ETH keys
  ```
  make get-eth-keys
  ```
  This command returns data related to Chainlink node's EVM Chain Accounts, e.g.:
  - Account address (this is the address for a Chainlink node wallet)
  - Link token balance
  - ETH balance  

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

#### Get Chainlink OCR keys
  ```
  make get-ocr-keys
  ```
  This command returns Chainlink node's OCR keys.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

#### Get Chainlink P2P keys
  ```
  make get-p2p-keys
  ```
  This command returns Chainlink node's P2P keys.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

> **Note**  
> You also can find information on keys in the node Operator GUI under the Key Management configuration.

### Smart Contracts Deployment Scripts
> **Note**  
> All contracts are deployed on behalf of the account specified in [.env](.env).

#### Deploy Link Token contract
  ```
  make deploy-link-token
  ```
  This command deploys an instance of [LinkToken.sol](chainlink%2Fcontracts%2FLinkToken.sol) contract.

#### Deploy Oracle contract
  ```
  make deploy-oracle
  ```
  This command deploys an instance of Chainlink Oracle.sol contract and whitelists Chainlink node address in the deployed contract.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Consumer contract
  ```
  make deploy-consumer
  ```
  This command deploys an instance of [ChainlinkConsumer.sol](chainlink%2Fcontracts%2FChainlinkConsumer.sol) contract.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Cron Consumer contract
  ```
  make deploy-cron-consumer
  ```
  This command deploys an instance of [ChainlinkCronConsumer.sol](chainlink%2Fcontracts%2FChainlinkCronConsumer.sol) contract.

#### Deploy Keeper Consumer contract
  ```
  make deploy-keeper-consumer
  ```
  This command deploys an instance of [ChainlinkKeeperConsumer.sol](chainlink%2Fcontracts%2FChainlinkKeeperConsumer.sol) contract.

#### Deploy Keeper Registry contract
  ```
  make deploy-keeper-registry
  ```
  This command deploys an instance of Chainlink Registry.sol contract.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Chainlink Offchain Aggregator contract
  ```
  make deploy-chainlink-offchain-aggregator
  ```
  This command deploys an instance of Chainlink OffchainAggregator.sol contract.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Chainlink Flux Aggregator contract
  ```
  make deploy-chainlink-flux-aggregator
  ```
  This command deploys an instance of Chainlink FluxAggregator.sol contract.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

### Chainlink Jobs Scripts

#### Create Chainlink Direct Request job
  ```
  make create-direct-request-job
  ```
  This command creates a Chainlink job according to [direct_request_job.toml](chainlink%2Fjobs%2Fdirect_request_job.toml). 

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `ORACLE_ADDRESS` - Oracle contract address

#### Create Chainlink Cron job
  ```
  make create-cron-job
  ```
  This command creates a Chainlink job according to [cron_job.toml](chainlink%2Fjobs%2Fcron_job.toml).

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `CRON_CONSUMER_ADDRESS` - Cron consumer contract address

#### Create Chainlink Webhook job
  ```
  make create-webhook-job
  ```
  This command creates a Chainlink job according to [webhook_job.toml](chainlink%2Fjobs%2Fwebhook_job.toml).

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

#### Run Chainlink Webhook job
  ```
  make run-webhook-job
  ```
  This command runs an existing Chainlink Webhook job.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `WEBHOOK_JOB_ID` - Webhook job ID

#### Create Chainlink Keeper job
  ```
  make create-keeper-job
  ```
  This command creates a Chainlink job according to [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml).

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `REGISTRY_ADDRESS` - Registry contract address

#### Create Chainlink Keeper jobs
  ```
  make create-keeper-jobs
  ```
  This command creates a Chainlink job for each Chainlink node in a cluster according to [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml).

  During the execution of the command, you will need to provide:
  - `REGISTRY_ADDRESS` - Registry contract address

  > **Note**  
  > For the Chainlink Keeper Job it was noticed that Chainlink nodes require a current blockchain height to be approximately at least 100 blocks.

#### Create Chainlink OCR (bootstrap) job
  ```
  make create-ocr-bootstrap-job
  ```
  This command creates a Chainlink job for the first Chainlink node in a cluster according to [ocr_job_bootstrap.toml](chainlink%2Fjobs%2Focr_job_bootstrap.toml).

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Create Chainlink OCR job
  ```
  make create-ocr-job
  ```
  This command creates a Chainlink job according to [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml).

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address
  - `BOOTSTRAP_P2P_KEY` - P2P key for an OCR bootstrap Chainlink node

#### Create Chainlink OCR jobs
  ```
  make create-ocr-jobs
  ```
  This command creates a Chainlink job for each Chainlink node except the first one (bootstrap) in a cluster according to [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml).

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Create Chainlink Flux job
  ```
  make create-flux-job
  ```
  This command creates a Chainlink job according to [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml).

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Create Chainlink Flux jobs
  ```
  make create-flux-jobs
  ```
  This command creates a Chainlink job for the first 3 Chainlink nodes in a cluster according to [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml).

  During the execution of the command, you will need to provide:
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

   > **Note**  
   > You can check list of created jobs with Chainlink Operator GUI.

### Helper Solidity Scripts

#### Transfer ETH
  ```
  make transfer-eth
  ```
  With this command, you can send ETH to any specified recipient.

  During the execution of the command, you will need to provide:
  - `RECIPIENT` - Recipient address

#### Transfer ETH to Chainlink node
  ```
  make transfer-eth-to-node
  ```
  With this command, you can send ETH to any specified Chainlink node.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID

#### Transfer ETH to Chainlink nodes
  ```
  make transfer-eth-to-nodes
  ```
  With this command, you can send ETH to all Chainlink nodes in a cluster.

#### Transfer Link tokens
  ```
  make transfer-link
  ```
  With this command, you can send Link tokens to any specified recipient.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address
  - `RECIPIENT` - Recipient address

#### Transfer Link tokens to Chainlink node
  ```
  make transfer-link-to-node
  ```
  With this command, you can send Link tokens to any specified Chainlink node.

  During the execution of the command, you will need to provide:
  - `NODE_ID` - Chainlink node ID
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Transfer Link tokens to Chainlink nodes
  ```
  make transfer-link-to-nodes
  ```
  With this command, you can send Link tokens to all Chainlink nodes in a cluster.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

### Link Token Solidity Scripts

#### Get Link Token balance
  ```
  make get-balance
  ```
  This command returns Link Token balance of an account.

  During the execution of the command, you will need to provide:
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address
  - `ACCOUNT` - Account

### Chainlink Consumer Solidity Scripts

#### Request ETH price
  ```
  make request-eth-price-consumer
  ```
  This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.  

  During the execution of the command, you will need to provide:
  - `CONSUMER_ADDRESS` - Consumer contract address
  - `ORACLE_ADDRESS` - Oracle contract address
  - `DIRECT_REQUEST_EXTERNAL_JOB_ID` - Direct request External Job ID - you can get one with Chainlink Operator GUI on the Jobs tab

   > **Note**  
   > You can check list of runs of jobs with Chainlink Operator GUI.

#### Get ETH price
  ```
  make get-eth-price-consumer
  ```
  This command returns current value of `currentPrice` variable specified in the Consumer contract state.  

  During the execution of the command, you will need to provide:
  - `CONSUMER_ADDRESS` - Consumer contract address

### Chainlink Cron Consumer Solidity Scripts

#### Get ETH price (cron)
  ```
  make get-eth-price-cron-consumer
  ```
  This command returns current value of `currentPrice` variable specified in the Consumer contract state.

  During the execution of the command, you will need to provide:
  - `CRON_CONSUMER_ADDRESS` - Cron Consumer contract address

### Chainlink Keeper Consumer Solidity Scripts

#### Get Keeper Counter
  ```
  make get-keeper-counter
  ```
  This command returns the latest value of the `counter` variable stored in the Keeper Consumer contract. This variable reflects the number of times the keepers performed the Keeper job.

  During the execution of the command, you will need to provide:
  - `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

### Registry Solidity Scripts

#### Register Keeper Consumer
  ```
  make register-upkeep
  ```
  This command registers Keeper Consumer in the Registry contract as upkeep.

  During the execution of the command, you will need to provide:
  - `REGISTRY_ADDRESS` - Registry contract address
  - `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

#### Set Keepers
  ```
  make set-keepers
  ```
  This command sets Chainlink nodes in the cluster as keepers in the Registry contract.

  During the execution of the command, you will need to provide:
  - `REGISTRY_ADDRESS` - Registry contract address
  - `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

#### Fund Latest Upkeep
  ```
  make fund-latest-upkeep
  ```
  This command funds the latest upkeep in the Registry contract.

  During the execution of the command, you will need to provide:
  - `REGISTRY_ADDRESS` - Registry contract address
  - `LINK_CONTRACT_ADDRESS` - Link Token contract address

### Offchain Aggregator Solidity Scripts

#### Set Payees
  ```
  make set-payees
  ```
  This command sets `payees` in the Offchain Aggregator contract.

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Set Config
  ```
  make set-config
  ```
  This command sets OCR configuration in the Offchain Aggregator contract.

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

> **Note**  
> This package uses external Go library [OCRHelper](external%2FOCRHelper) to prepare an OCR configuration.  
> 

#### Request New Round
  ```
  make request-new-round
  ```
  This command requests new OCR round immediately.

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Get OCR Latest Answer
  ```
  make get-latest-answer-ocr
  ```
  This command returns an answer of the latest OCR round.

  During the execution of the command, you will need to provide:
  - `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

### Flux Aggregator Solidity Scripts

#### Update Available Funds
  ```
  make update-available-funds
  ```
  This command recalculate the amount of LINK available for payouts in the Flux Aggregator contract.

  During the execution of the command, you will need to provide:
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Set Oracles
  ```
  make set-oracles
  ```
  This command adds new oracles as well as updates the round related parameters in the Flux Aggregator contract.

  During the execution of the command, you will need to provide:
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Get Oracles
  ```
  make get-oracles
  ```
  This command returns an array of addresses containing the oracles in the Flux Aggregator contract.

  During the execution of the command, you will need to provide:
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Get Flux Latest Answer
  ```
  make get-latest-answer-flux
  ```
  This command returns an answer of the latest Flux round.

  During the execution of the command, you will need to provide:
  - `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

  > **Note**  
  > Current version of the package intended to support different compiler versions in range `[>=0.6.2 <0.9.0]`.  
  > It was tested e2e with solc versions specified in [foundry.toml](foundry.toml) profiles:
  > - 0.6.2
  > - 0.6.12 [profile:0_6_x]
  > - 0.7.6 [profile:0_7_x]
  > - 0.8.12 [profile:default]
  > 
  > Therefore, you can specify any supported version of Solidity compiler in [foundry.toml](foundry.toml).  
  > In case you find any problems when using other versions of the compiler from range `[>=0.6.2 <0.9.0]` you are welcome to open an issue.

## Acknowledgements
This project based on https://github.com/protofire/hardhat-chainlink-plugin. 
