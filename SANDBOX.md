# Makefile Sandbox Scripts
Below are the scripts available in the [makefile-sandbox](makefile-sandbox) of the Foundry-Chainlink Toolkit.  

All scripts are prefixed with `fct-` to avoid makefile collisions when integrating with other projects.  

Some scripts accept arguments that can be provided either through the command line (e.g. ```make target PARAM={value}```), in the `.env` file, or interactively in the command line.  

<!-- TOC -->
* [Makefile Sandbox Scripts](#makefile-sandbox-scripts)
  * [Installation](#installation)
  * [Usage](#usage)
    * [Initialize testing environment](#initialize-testing-environment)
    * [Set up Chainlink Jobs](#set-up-chainlink-jobs)
      * [Direct Request Job](#direct-request-job)
      * [Cron Job](#cron-job)
      * [Webhook Job](#webhook-job)
      * [Keeper Job](#keeper-job)
      * [Flux Job](#flux-job)
      * [OCR Job](#ocr-job)
  * [Project Structure](#project-structure)
    * [Chainlink *](#chainlink-)
      * [Contracts *](#contracts-)
      * [Jobs *](#jobs-)
      * [Setting *](#setting-)
      * [SQL *](#sql-)
      * [Chainlink nodes logs directories](#chainlink-nodes-logs-directories)
      * [chainlink.env *](#chainlinkenv-)
    * [External *](#external-)
      * [OCRHelper *](#ocrhelper-)
    * [Script *](#script-)
    * [Src *](#src-)
      * [Interfaces *](#interfaces-)
      * [Mocks *](#mocks-)
    * [Utility Scripts](#utility-scripts)
      * [Show Help](#show-help)
      * [Run Anvil](#run-anvil)
      * [Initialize Test Environment](#initialize-test-environment)
    * [Chainlink Jobs Automatic Setup Scripts](#chainlink-jobs-automatic-setup-scripts)
      * [Set Up a Chainlink Job](#set-up-a-chainlink-job)
      * [Set Up Direct Request Job](#set-up-direct-request-job)
      * [Set Up Cron Job](#set-up-cron-job)
      * [Set Up Webhook Job](#set-up-webhook-job)
      * [Set Up Keeper Job](#set-up-keeper-job)
      * [Set Up Flux Job](#set-up-flux-job)
      * [Set Up OCR Job](#set-up-ocr-job)
    * [Chainlink Nodes Management Scripts](#chainlink-nodes-management-scripts)
      * [Spin Up a Chainlink Cluster](#spin-up-a-chainlink-cluster)
      * [Restart a Chainlink Cluster](#restart-a-chainlink-cluster)
      * [Get a Chainlink Node Info](#get-a-chainlink-node-info)
      * [Get Chainlink Node ETH Keys](#get-chainlink-node-eth-keys)
      * [Get Chainlink Node OCR Keys](#get-chainlink-node-ocr-keys)
      * [Get Chainlink Node P2P Keys](#get-chainlink-node-p2p-keys)
      * [Get Chainlink Node Address](#get-chainlink-node-address)
      * [Get Chainlink Node Configuration](#get-chainlink-node-configuration)
    * [Chainlink Jobs creation Scripts](#chainlink-jobs-creation-scripts)
      * [Create a Chainlink Job](#create-a-chainlink-job)
      * [Create Chainlink Direct Request Job](#create-chainlink-direct-request-job)
      * [Create Chainlink Cron Job](#create-chainlink-cron-job)
      * [Create Chainlink Webhook Job](#create-chainlink-webhook-job)
      * [Create Chainlink Keeper Job](#create-chainlink-keeper-job)
      * [Create Chainlink Flux Job](#create-chainlink-flux-job)
      * [Create Chainlink OCR (bootstrap) Job](#create-chainlink-ocr-bootstrap-job)
      * [Create Chainlink OCR (oracle) Job](#create-chainlink-ocr-oracle-job)
      * [Create Chainlink Keeper Jobs](#create-chainlink-keeper-jobs)
      * [Create Chainlink Flux Jobs](#create-chainlink-flux-jobs)
      * [Create Chainlink OCR Jobs](#create-chainlink-ocr-jobs)
    * [Chainlink Jobs Helper Scripts](#chainlink-jobs-helper-scripts)
      * [Chainlink Jobs Available Helpers](#chainlink-jobs-available-helpers)
      * [Get Chainlink Job ID](#get-chainlink-job-id)
      * [Get Chainlink External Job ID](#get-chainlink-external-job-id)
      * [Get Chainlink Webhook Job Latest ID](#get-chainlink-webhook-job-latest-id)
      * [Run Chainlink Webhook Job](#run-chainlink-webhook-job)
      * [Delete Job](#delete-job)
    * [Chainlink Smart Contracts Deployment Scripts](#chainlink-smart-contracts-deployment-scripts)
      * [Deploy a Chainlink Smart Contract](#deploy-a-chainlink-smart-contract)
      * [Deploy Link Token Contract](#deploy-link-token-contract)
      * [Deploy Oracle Contract](#deploy-oracle-contract)
      * [Deploy Direct Request Consumer Contract](#deploy-direct-request-consumer-contract)
      * [Deploy Cron Consumer Contract](#deploy-cron-consumer-contract)
      * [Deploy Keeper Consumer Contract](#deploy-keeper-consumer-contract)
      * [Deploy Registry Contract](#deploy-registry-contract)
      * [Deploy Flux Aggregator Contract](#deploy-flux-aggregator-contract)
      * [Deploy Offchain Aggregator Contract](#deploy-offchain-aggregator-contract)
    * [ETH and Link Token Helper Scripts](#eth-and-link-token-helper-scripts)
      * [ETH and Link Token Available Helpers](#eth-and-link-token-available-helpers)
      * [Transfer ETH](#transfer-eth)
      * [Transfer ETH to Chainlink Node](#transfer-eth-to-chainlink-node)
      * [Transfer ETH to Chainlink Nodes](#transfer-eth-to-chainlink-nodes)
      * [Transfer Link Tokens](#transfer-link-tokens)
      * [Transfer Link Tokens to Chainlink Node](#transfer-link-tokens-to-chainlink-node)
      * [Transfer Link Tokens to Chainlink Nodes](#transfer-link-tokens-to-chainlink-nodes)
      * [Get ETH Balance](#get-eth-balance)
      * [Get Link Token Balance](#get-link-token-balance)
    * [Direct Request Consumer Scripts](#direct-request-consumer-scripts)
      * [Request ETH Price](#request-eth-price)
      * [Request ETH Price (by Oracle)](#request-eth-price-by-oracle)
      * [Get ETH Price (Direct Request)](#get-eth-price-direct-request)
    * [Cron Consumer Scripts](#cron-consumer-scripts)
      * [Get ETH Price (Cron)](#get-eth-price-cron)
    * [Keeper Consumer Scripts](#keeper-consumer-scripts)
      * [Get Keeper Counter](#get-keeper-counter)
    * [Registry Scripts](#registry-scripts)
      * [Register Upkeep](#register-upkeep)
      * [Set Keepers](#set-keepers)
      * [Fund Latest Upkeep](#fund-latest-upkeep)
    * [Flux Aggregator Scripts](#flux-aggregator-scripts)
      * [Update Available Funds](#update-available-funds)
      * [Set Oracles](#set-oracles)
      * [Get Oracles](#get-oracles)
      * [Get Flux Latest Answer](#get-flux-latest-answer)
    * [Offchain Aggregator Scripts](#offchain-aggregator-scripts)
      * [Set Payees](#set-payees)
      * [Set Config](#set-config)
      * [Request New Round](#request-new-round)
      * [Get OCR Latest Answer](#get-ocr-latest-answer)
<!-- TOC -->

## Installation

## Usage
Scripts for automating the initialization of the test environment and setting up Chainlink jobs will be described below.

To display autogenerated help with a brief description of the most commonly used scripts, run:
```
make fct-help
```
For a more detailed description of the available scripts, you can refer to [SANDBOX.md](SANDBOX).

### Initialize testing environment
```
make fct-init
```
This command automatically initializes the test environment, in particular, it makes clean spin-up of a Chainlink cluster of 5 Chainlink nodes.

Once Chainlink cluster is launched, a Chainlink nodes' Operator GUI will be available at:
- http://127.0.0.1:6711 - Chainlink node 1
- http://127.0.0.1:6722 - Chainlink node 2
- http://127.0.0.1:6733 - Chainlink node 3
- http://127.0.0.1:6744 - Chainlink node 4
- http://127.0.0.1:6755 - Chainlink node 5

For authorization, you must use the credentials specified in the [chainlink_api_credentials](src%2Fsandbox%2Fclroot%2Fsettings%2Fchainlink_api_credentials).

You can also initialize the test environment manually by following these steps:
1. [Deploy Link Token contract](SANDBOX.md#deploy-link-token-contract)
2. Set `LINK_TOKEN_CONTRACT` in `.env`
3. [Spin up a Chainlink nodes cluster](SANDBOX.md#spin-up-a-chainlink-cluster)
4. [Fund Chainlink nodes with ETH](SANDBOX.md#transfer-eth-to-chainlink-nodes)
5. [Fund Chainlink nodes with Link tokens](SANDBOX.md#transfer-link-tokens-to-chainlink-nodes)

> **Note**  
> For **ARM64** users. When starting a docker container, there will be warnings:  
> ```The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested```  
> You can safely ignore these warnings, container will start normally.

### Set up Chainlink Jobs
```
make fct-setup-job
```
[This command](SANDBOX.md#set-up-a-chainlink-job) displays a list of available Chainlink jobs and sets up the selected one.

You can also set up a Chainlink job by calling the respective command.

#### Direct Request Job
```
make fct-setup-direct-request-job
```
[This command](SANDBOX.md#set-up-direct-request-job) automatically sets up a Direct Request job.

You can also set up a Direct Request job manually by following these steps:
1. [Deploy Oracle contract](SANDBOX.md#deploy-oracle-contract)
2. [Deploy Consumer contract](SANDBOX.md#deploy-direct-request-consumer-contract)
3. [Fund Consumer contract with Link tokens](SANDBOX.md#transfer-link-tokens)
4. [Create Direct Request Job](SANDBOX.md#create-chainlink-direct-request-job)
5. [Request ETH price with Consumer contract, a corresponding job will be launched](SANDBOX.md#request-eth-price)
6. [Get ETH price after completing a job](SANDBOX.md#get-eth-price-direct-request)

#### Cron Job
```
make fct-setup-cron-job
```
[This command](SANDBOX.md#set-up-cron-job) automatically sets up a Cron job.

You can also set up a Cron job manually by following these steps:
1. [Deploy Cron Consumer contract](SANDBOX.md#deploy-cron-consumer-contract)
2. [Create Cron Job](SANDBOX.md#create-chainlink-cron-job)
3. [Get ETH price after completing a job](SANDBOX.md#get-eth-price-cron)

#### Webhook Job
```
make fct-setup-webhook-job
```
[This command](SANDBOX.md#set-up-webhook-job) automatically sets up a Webhook job.

You can also set up a Webhook job manually by following these steps:
1. [Create Webhook Job](SANDBOX.md#create-chainlink-webhook-job)
2. [Run Webhook Job](SANDBOX.md#run-chainlink-webhook-job)

#### Keeper Job
```
make fct-setup-keeper-job
```
[This command](SANDBOX.md#set-up-keeper-job) automatically sets up a Keeper job.

You can also set up a Keeper job manually by following these steps:
1. [Deploy Keeper Consumer contract](SANDBOX.md#deploy-keeper-consumer-contract)
2. [Deploy Registry contract](SANDBOX.md#deploy-registry-contract)
3. [Create Keeper Jobs for Chainlink nodes in a cluster](SANDBOX.md#create-chainlink-keeper-jobs)
4. [Register Chainlink nodes as keepers in a Registry contract](SANDBOX.md#set-keepers)
5. [Register Keeper Consumer as upkeep in a Registry contract](SANDBOX.md#register-upkeep)
6. [Fund the latest upkeep in a Registry contract](SANDBOX.md#fund-latest-upkeep)
7. [Get value of `counter` variable in a Keeper contract](SANDBOX.md#get-keeper-counter)

#### Flux Job
```
make fct-setup-flux-job
```
[This command](SANDBOX.md#set-up-flux-job) automatically sets up a Flux job.

You can also set up a Flux job manually by following these steps:
1. [Deploy Flux Aggregator contract](SANDBOX.md#deploy-flux-aggregator-contract)
2. [Fund Flux Aggregator contract with Link tokens](SANDBOX.md#transfer-link-tokens)
3. [Update Flux Aggregator available funds](SANDBOX.md#update-available-funds)
4. [Set Flux Aggregator oracles](SANDBOX.md#set-oracles)
5. [Create Flux Jobs for the first 3 Chainlink nodes in a cluster](SANDBOX.md#create-chainlink-flux-jobs)
6. [Get the answer of the latest Flux round from the Flux Aggregator contract](SANDBOX.md#get-flux-latest-answer)

#### OCR Job
```
make fct-setup-ocr-job
```
[This command](SANDBOX.md#set-up-flux-job) automatically sets up an OCR job.

You can also set up a OCR job manually by following these steps:
1. [Deploy Offchain Aggregator contract](SANDBOX.md#deploy-offchain-aggregator-contract)
2. [Set Offchain Aggregator payees](SANDBOX.md#set-payees)
3. [Set Offchain Aggregator config](SANDBOX.md#set-config)
4. [Create OCR Job for a bootstrap Chainlink node (first in a cluster)](SANDBOX.md#create-chainlink-ocr-bootstrap-job)
5. [Create OCR Jobs for Chainlink nodes in a cluster except the first one (bootstrap)](SANDBOX.md#create-chainlink-ocr-jobs)
6. [Request new OCR round in the Offchain Aggregator contract (optional)](SANDBOX.md#request-new-round)
7. [Get the answer of the latest OCR round from the Offchain Aggregator contract](SANDBOX.md#get-ocr-latest-answer)

> **Note**
> Manual set up of a Chainlink Job is recommended when utilizing a custom Consumer or Aggregator contract, or when a different job configuration is desired.  
> You can create a custom TOML file and use it to create a Chainlink Job instance through the Operator GUI or develop a custom script using the existing scripts provided by this toolkit.

## Project Structure

### Chainlink [*](src/sandbox/clroot)
This directory contains configuration files, scripts and smart contracts source code.

#### Contracts [*](contracts)
- [ChainlinkDirectRequestConsumer.sol](contracts%2Fv0.8.19%2FChainlinkDirectRequestConsumer.sol) - example consumer contract for [Chainlink Direct Request Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs/#direct-request-jobs)
- [ChainlinkCronConsumer.sol](contracts%2Fv0.8.19%2FChainlinkCronConsumer.sol) - example consumer contract for [Chainlink Cron Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#solidity-cron-jobs)
- [ChainlinkKeeperConsumer.sol](contracts%2Fv0.8.19%2FChainlinkKeeperConsumer.sol) - example consumer contract for [Chainlink Keeper Job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#keeper-jobs)
- [LinkToken.sol](contracts%2Fv0.4.25%2FLinkToken.sol) - flattened [Link Token contract](https://github.com/smartcontractkit/LinkToken)

#### Jobs [*](src%2Fsandbox%2Fclroot%2Fjobs)
- [cron_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fcron_job.toml) - example configuration file for a Chainlink [Cron job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#solidity-cron-jobs)
- [direct_request_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fdirect_request_job.toml) - example configuration file for a Chainlink [Direct Request job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#direct-request-jobs)
- [flux_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fflux_job.toml) - example configuration file for a Chainlink [Flux job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#flux-monitor-jobs)
- [keeper_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fkeeper_job.toml) - example configuration file for a Chainlink [Keeper job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#keeper-jobs)
- [ocr_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job.toml) - example configuration file for a Chainlink [OCR job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs#off-chain-reporting-jobs)
- [ocr_job_bootstrap.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job_bootstrap.toml) - example configuration file for a Chainlink OCR (bootstrap) job
- [webhook_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fwebhook_job.toml) - example configuration file for a Chainlink [Webhook job](https://docs.chain.link/chainlink-nodes/oracle-jobs/all-jobs/#webhook-jobs)

> **Note**  
> More info on Chainlink v2 Jobs, their types and configuration can be found here: [docs.chain.link/chainlink-nodes/oracle-jobs/jobs/](https://docs.chain.link/chainlink-nodes/oracle-jobs/jobs/).  
> You can change these configuration according to your requirements.

#### Setting [*](src%2Fsandbox%2Fclroot%2Fsettings)
- [chainlink_api_credentials](src%2Fsandbox%2Fclroot%2Fsettings%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](src%2Fsandbox%2Fclroot%2Fsettings%2Fchainlink_password) - Chainlink password

> **Note**  
> More info on authentication can be found here [github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API](https://github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API).  
> You can specify any credentials there. Password provided must be 16 characters or more.

#### SQL [*](src%2Fsandbox%2Fclroot%2Fsql)
- [create_tables.sql](src%2Fsandbox%2Fclroot%2Fsql%2Fcreate_tables.sql) - sql script to create tables related to Chainlink nodes in a Postgres DB
- [chainlink_password](src%2Fsandbox%2Fclroot%2Fsettings%2Fchainlink_password) - sql script to delete tables related to Chainlink nodes in a Postgres DB

#### Chainlink nodes logs directories
Once Chainlink nodes are started, log directories will be created for each of them.

#### chainlink.env [*](src%2Fsandbox%2Fclroot%2Fchainlink.env)
This file contains environment variables related to Chainlink node configuration. You can modify it according to your requirements.  
More info on Chainlink environment variables can be found here: https://docs.chain.link/chainlink-nodes/v1/configuration.

> **Note**  
> Subdirectories: [jobs](src%2Fsandbox%2Fclroot%2Fjobs), [settings](src%2Fsandbox%2Fclroot%2Fsettings) and [sql](src%2Fsandbox%2Fclroot%2Fsql) are used as shared folders for running Chainlink nodes and Postgres DB containers.

### External [*](external)
This directory contains external libraries.

#### OCRHelper [*](external%2FOCRHelper)
This Go library is based on https://github.com/smartcontractkit/chainlink-testing-framework integration tests and is used to prepare configuration parameters for Offchain Aggregator contract.  
It has pre-built binaries for platforms: darwin/amd64(x86_64), darwin/arm64, linux/amd64(x86_64), linux/arm,linux/arm64.
> **Note**  
> If you use another platform, in the root of the project please run:  
> ```make fct-build-ocr-helper```  
> It will build the external library for your platform.  
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
More info on `forge script` can be found here: https://book.getfoundry.sh/reference/forge/forge-script.

### Src [*](src)
#### Interfaces [*](src%2Finterfaces)
This directory contains interfaces to interact with Solidity contracts deployed using its pre-built artifacts. This is necessary in order to reduce dependence on a specific version of Solidity compiler.

#### Mocks [*](src%2Fmocks)
This directory contains mock Solidity contracts used for testing purposes:
- [MockAccessController.sol](src%2Fmocks%2FMockAccessController.sol) - mock contract used during deployment of Offchain Aggregator contract
- [MockAggregatorValidator.sol](src%2Fmocks%2FMockAggregatorValidator.sol) - mock contract used during deployment of Flux Aggregator contract
- [MockEthFeed.sol](src%2Fmocks%2FMockEthFeed.sol) - mock contract used during deployment of Registry contract
- [MockGasFeed.sol](src%2Fmocks%2FMockGasFeed.sol) - mock contract used during deployment of Registry contract

### Utility Scripts

#### Show Help
  ```
  make fct-help
  ```
This command displays autogenerated help with a brief description of the most commonly used scripts.  
For a more detailed description of the scripts, you can refer to current file.

#### Run Anvil
  ```
  make fct-anvil
  ```
This command runs Anvil local Ethereum node with the following options:
- http endpoint: http://localhost:8545
- web socket: [ws://localhost:8545](ws://localhost:8545)
- chain ID: 1337
- block period: 10s
- mnemonic: `test test test test test test test test test test test junk`

#### Initialize Test Environment
  ```
  make fct-init
  ```
This command automatically initializes the test environment:
- Deploys the Link Token contract and writes its address to .env
- Spins up a Chainlink cluster
- Funds Chainlink nodes with ETH and Link tokens

### Chainlink Jobs Automatic Setup Scripts

#### Set Up a Chainlink Job
  ```
  make fct-setup-job
  ```
This command displays a list of available Chainlink jobs and sets up the selected one.

#### Set Up Direct Request Job
  ```
  make fct-setup-direct-request-job
  ```
This command automatically sets up a Direct Request job:
- Deploys the Oracle and the Chainlink Direct Request Consumer contracts
- Funds the Chainlink Direct Request Consumer with Link tokens
- Creates a Direct Request job on a Chainlink node
- Makes request to the Oracle contract to update ETH price value

#### Set Up Cron Job
  ```
  make fct-setup-cron-job
  ```
This command automatically sets up a Cron job:
- Deploys the Chainlink Cron Consumer contract
- Creates a Cron job on a Chainlink node

#### Set Up Webhook Job
  ```
  make fct-setup-webhook-job
  ```
This command automatically sets up a Webhook job:
- Creates a Webhook job on a Chainlink node
- Runs the most recently created Webhook job

#### Set Up Keeper Job
  ```
  make fct-setup-keeper-job
  ```
This command automatically sets up a Keeper job:
- Deploys the Registry and the Chainlink Keeper Consumer contracts
- Register the Chainlink Keeper Consumer in the Registry contract as an upkeep
- Sets Chainlink nodes as keepers in the Registry contract
- Creates a Keeper job on each Chainlink node in a Chainlink cluster
- Funds the latest registered upkeep in the Registry

#### Set Up Flux Job
  ```
  make fct-setup-flux-job
  ```
This command automatically sets up a Flux job:
- Deploys the Flux Aggregator contract
- Funds the Flux Aggregator with Link tokens and updates its available funds
- Sets Chainlink nodes 1-3 as oracles in the Flux Aggregator contract
- Creates a Flux job on Chainlink nodes 1-3

#### Set Up OCR Job
  ```
  make fct-setup-ocr-job
  ```
This command automatically sets up a OCR job:
- Deploys the Offchain Aggregator contract
- Sets Chainlink nodes 2-5 as payees in the Offchain Aggregator contract
- Sets OCR configuration generated by Chainlink nodes 2-5 in the Offchain Aggregator contract
- Creates an OCR (bootstrap) job on Chainlink node 1
- Creates an OCR (oracle) job on Chainlink nodes 2-5

### Chainlink Nodes Management Scripts

#### Spin Up a Chainlink Cluster
  ```
  make fct-run-nodes
  ```
This command spins up a cluster of 5 Chainlink nodes (necessary to run OCR jobs). It fetches images, creates/recreates and starts containers according to the [docker-compose.yaml](src/sandbox/docker-compose.yaml).

#### Restart a Chainlink Cluster
  ```
  make fct-restart-nodes
  ```
This command performs a clean restart of a Chainlink cluster: stops and removes containers and network, deletes all related volumes and logs, and starts containers according to the [docker-compose.yaml](src/sandbox/docker-compose.yaml).  

#### Get a Chainlink Node Info
  ```
  make fct-get-node-info
  ```
This command displays a list of available Chainlink node information and shows the selected one.

#### Get Chainlink Node ETH Keys
  ```
  make fct-get-node-eth-keys
  ```
This command returns data related to Chainlink node's EVM Chain Accounts, e.g.:
- Account address (this is the address for a Chainlink node wallet)
- Link token balance
- ETH balance

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Get Chainlink Node OCR Keys
  ```
  make fct-get-node-ocr-keys
  ```
This command returns Chainlink node's OCR keys.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Get Chainlink Node P2P Keys
  ```
  make fct-get-node-p2p-keys
  ```
This command returns Chainlink node's P2P keys.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Get Chainlink Node Address
  ```
  make fct-get-node-address
  ```
This command returns Chainlink node's account address.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

> **Note**  
> You also can find information on keys in the node Operator GUI under the Key Management configuration.

#### Get Chainlink Node Configuration
  ```
  make fct-get-node-config
  ```
This command returns a Chainlink node configuration. The result contains comma-separated values, including:
- `Node address`
- `On-chain signing address`
- `Off-chain public key`
- `Config public key`
- `Peer ID`

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

### Chainlink Jobs creation Scripts

#### Create a Chainlink Job
  ```
  make fct-create-job
  ```
This command displays a list of available Chainlink jobs and creates the selected one.

#### Create Chainlink Direct Request Job
  ```
  make fct-create-direct-request-job
  ```
This command creates a Chainlink job according to [direct_request_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fdirect_request_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `ORACLE_ADDRESS` - Oracle contract address

#### Create Chainlink Cron Job
  ```
  make fct-create-cron-job
  ```
This command creates a Chainlink job according to [cron_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fcron_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `CRON_CONSUMER_ADDRESS` - Cron consumer contract address

#### Create Chainlink Webhook Job
  ```
  make fct-create-webhook-job
  ```
This command creates a Chainlink job according to [webhook_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fwebhook_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Create Chainlink Keeper Job
  ```
  make fct-create-keeper-job
  ```
This command creates a Chainlink job according to [keeper_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fkeeper_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `REGISTRY_ADDRESS` - Registry contract address

> **Note**  
> For the Chainlink Keeper Job it was noticed that Chainlink nodes require a current blockchain height to be approximately at least 100 blocks.

#### Create Chainlink Flux Job
  ```
  make fct-create-flux-job
  ```
This command creates a Chainlink job according to [flux_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fflux_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Create Chainlink OCR (bootstrap) Job
  ```
  make fct-create-ocr-bootstrap-job
  ```
This command creates a Chainlink job according to [ocr_job_bootstrap.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job_bootstrap.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Create Chainlink OCR (oracle) Job
  ```
  make fct-create-ocr-job
  ```
This command creates a Chainlink job according to [ocr_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job.toml).

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address
- `BOOTSTRAP_P2P_KEY` - P2P key for an OCR bootstrap Chainlink node

#### Create Chainlink Keeper Jobs
  ```
  make fct-create-keeper-jobs
  ```
This command creates a Chainlink job for each Chainlink node in a cluster according to [keeper_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fkeeper_job.toml).

During the execution of the command, you will need to provide:
- `REGISTRY_ADDRESS` - Registry contract address

#### Create Chainlink Flux Jobs
  ```
  make fct-create-flux-jobs
  ```
This command creates a Chainlink job for the first 3 Chainlink nodes in a cluster according to [flux_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Fflux_job.toml).

During the execution of the command, you will need to provide:
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Create Chainlink OCR Jobs
  ```
  make fct-create-ocr-jobs
  ```
This command creates:
- Chainlink job for the first node (bootstrap) in a cluster according to [ocr_job_bootstrap.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job_bootstrap.toml).
- Chainlink jobs for each Chainlink node (oracles) except the first one (bootstrap) in a cluster according to [ocr_job.toml](src%2Fsandbox%2Fclroot%2Fjobs%2Focr_job.toml).

During the execution of the command, you will need to provide:
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

> **Note**  
> You can check list of created jobs and manage them in the node Operator GUI under the Jobs tab.

### Chainlink Jobs Helper Scripts

#### Chainlink Jobs Available Helpers
  ```
  make fct-job-helper
  ```
This command displays a list of available helpers for Chainlink jobs and executes the selected one.

#### Get Chainlink Job ID
  ```
  make fct-get-job-id
  ```
This command returns an ID of a Chainlink job whose name contains the specified contract address.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `CONTRACT_ADDRESS` - Contract address identifying a Chainlink job

#### Get Chainlink External Job ID
  ```
  make fct-get-external-job-id
  ```
This command returns an External ID of a Chainlink job whose name contains the specified contract address.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `CONTRACT_ADDRESS` - Contract address identifying a Chainlink job

#### Get Chainlink Webhook Job Latest ID
  ```
  make fct-get-last-webhook-job-id
  ```
This command returns a Job ID of the latest created Chainlink Webhook job.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Run Chainlink Webhook Job
  ```
  make fct-run-webhook-job
  ```
This command runs an existing Chainlink Webhook job.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `WEBHOOK_JOB_ID` - Webhook job ID

#### Delete Job
  ```
  make fct-delete-job
  ```
This command deletes a Chainlink job with a specified job ID.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `JOB_ID` - Chainlink job ID

> **Note**  
> You also can find information on jobs in the node Operator GUI under the Jobs tab.

### Chainlink Smart Contracts Deployment Scripts

> **Note**  
> All contracts are deployed on behalf of the account specified in [.env](.env).

#### Deploy a Chainlink Smart Contract
  ```
  make fct-job-helper
  ```
This command displays a list of available Chainlink Smart Contracts and deploys the selected one.

#### Deploy Link Token Contract
  ```
  make fct-deploy-link-token
  ```
This command deploys an instance of [LinkToken.sol](contracts%2Fv0.4.25%2FLinkToken.sol) contract.

#### Deploy Oracle Contract
  ```
  make fct-deploy-oracle
  ```
This command deploys an instance of [Oracle.sol](contracts%2Fv0.6.6%2FOracle.sol) contract and whitelists Chainlink node address in the deployed contract.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Direct Request Consumer Contract
  ```
  make fct-deploy-direct-request-consumer
  ```
This command deploys an instance of [ChainlinkDirectRequestConsumer.sol](contracts%2Fv0.8.19%2FChainlinkDirectRequestConsumer.sol) contract.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Cron Consumer Contract
  ```
  make fct-deploy-cron-consumer
  ```
This command deploys an instance of [ChainlinkCronConsumer.sol](contracts%2Fv0.8.19%2FChainlinkCronConsumer.sol) contract.

#### Deploy Keeper Consumer Contract
  ```
  make fct-deploy-keeper-consumer
  ```
This command deploys an instance of [ChainlinkKeeperConsumer.sol](contracts%2Fv0.8.19%2FChainlinkKeeperConsumer.sol) contract.

#### Deploy Registry Contract
  ```
  make fct-deploy-registry
  ```
This command deploys an instance of [KeeperRegistry1_3.sol](contracts%2Fv0.8.6%2FKeeperRegistry1_3.sol) contract.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Flux Aggregator Contract
  ```
  make fct-deploy-flux-aggregator
  ```
This command deploys an instance of [FluxAggregator.sol](contracts%2Fv0.6.6%2FFluxAggregator.sol) contract.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Deploy Offchain Aggregator Contract
  ```
  make fct-deploy-offchain-aggregator
  ```
This command deploys an instance of Chainlink [OffchainAggregator.sol](contracts%2Fv0.7.6%2FOffchainAggregator.sol) contract.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

### ETH and Link Token Helper Scripts

#### ETH and Link Token Available Helpers
  ```
  make fct-funds-helper
  ```
This command displays a list of available helpers for ETH and Link Token and executes the selected one.

#### Transfer ETH
  ```
  make fct-transfer-eth
  ```
With this command, you can send ETH to any specified recipient.

During the execution of the command, you will need to provide:
- `RECIPIENT` - Recipient address

#### Transfer ETH to Chainlink Node
  ```
  make fct-transfer-eth-to-node
  ```
With this command, you can send ETH to any specified Chainlink node.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID

#### Transfer ETH to Chainlink Nodes
  ```
  make fct-transfer-eth-to-nodes
  ```
With this command, you can send ETH to all Chainlink nodes in a cluster.

#### Transfer Link Tokens
  ```
  make fct-transfer-link
  ```
With this command, you can send Link tokens to any specified recipient.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address
- `RECIPIENT` - Recipient address

#### Transfer Link Tokens to Chainlink Node
  ```
  make fct-transfer-link-to-node
  ```
With this command, you can send Link tokens to any specified Chainlink node.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Transfer Link Tokens to Chainlink Nodes
  ```
  make fct-transfer-link-to-nodes
  ```
With this command, you can send Link tokens to all Chainlink nodes in a cluster.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

#### Get ETH Balance
  ```
  make fct-get-eth-balance
  ```
This command returns ETH balance of an account.

During the execution of the command, you will need to provide:
- `ACCOUNT` - Account

#### Get Link Token Balance
  ```
  make fct-get-link-balance
  ```
This command returns Link Token balance of an account.

During the execution of the command, you will need to provide:
- `LINK_CONTRACT_ADDRESS` - Link Token contract address
- `ACCOUNT` - Account

### Direct Request Consumer Scripts

#### Request ETH Price
  ```
  make fct-dr-consumer-request-eth-price
  ```
This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.

During the execution of the command, you will need to provide:
- `DIRECT_REQUEST_CONSUMER_ADDRESS` - Direct Request Consumer contract address
- `ORACLE_ADDRESS` - Oracle contract address
- `DIRECT_REQUEST_EXTERNAL_JOB_ID` - Direct request External Job ID - you can get one with Chainlink Operator GUI on the Jobs tab

#### Request ETH Price (by Oracle)
  ```
  make fct-dr-consumer-request-eth-price-by-oracle
  ```
This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.  
The respective Chainlink Direct Request job will be found using [get-external-job-id](#get-chainlink-external-job-id) script.

During the execution of the command, you will need to provide:
- `NODE_ID` - Chainlink node ID
- `DIRECT_REQUEST_CONSUMER_ADDRESS` - Consumer contract address
- `ORACLE_ADDRESS` - Oracle contract address

#### Get ETH Price (Direct Request)
  ```
  make fct-dr-consumer-get-eth-price
  ```
This command returns current value of `currentPrice` variable specified in the Direct Request Consumer contract state.

During the execution of the command, you will need to provide:
- `DIRECT_REQUEST_CONSUMER_ADDRESS` - Direct Request Consumer contract address

### Cron Consumer Scripts

#### Get ETH Price (Cron)
  ```
  make fct-cron-consumer-get-eth-price
  ```
This command returns current value of `currentPrice` variable specified in the Cron Consumer contract state.

During the execution of the command, you will need to provide:
- `CRON_CONSUMER_ADDRESS` - Cron Consumer contract address

### Keeper Consumer Scripts

#### Get Keeper Counter
  ```
  make fct-keeper-consumer-get-counter
  ```
This command returns the latest value of the `counter` variable stored in the Keeper Consumer contract. This variable reflects the number of times the keepers performed the Keeper job.

During the execution of the command, you will need to provide:
- `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

### Registry Scripts

#### Register Upkeep
  ```
  make fct-registry-register-upkeep
  ```
This command registers Keeper Consumer in the Registry contract as upkeep.

During the execution of the command, you will need to provide:
- `REGISTRY_ADDRESS` - Registry contract address
- `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

#### Set Keepers
  ```
  make fct-registry-set-keepers
  ```
This command sets Chainlink nodes in the cluster as keepers in the Registry contract.

During the execution of the command, you will need to provide:
- `REGISTRY_ADDRESS` - Registry contract address
- `KEEPER_CONSUMER_ADDRESS` - Keeper Consumer contract address

#### Fund Latest Upkeep
  ```
  make fct-registry-fund-latest-upkeep
  ```
This command funds the most recent upkeep in the Registry contract.

During the execution of the command, you will need to provide:
- `REGISTRY_ADDRESS` - Registry contract address
- `LINK_CONTRACT_ADDRESS` - Link Token contract address

### Flux Aggregator Scripts

#### Update Available Funds
  ```
  make fct-flux-update-available-funds
  ```
This command recalculate the amount of LINK available for payouts in the Flux Aggregator contract.

During the execution of the command, you will need to provide:
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Set Oracles
  ```
  make fct-flux-set-oracles
  ```
This command adds new oracles as well as updates the round related parameters in the Flux Aggregator contract.

During the execution of the command, you will need to provide:
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Get Oracles
  ```
  make fct-flux-get-oracles
  ```
This command returns an array of addresses containing the oracles of the Flux Aggregator contract.

During the execution of the command, you will need to provide:
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

#### Get Flux Latest Answer
  ```
  make fct-flux-get-latest-answer
  ```
This command returns the answer of the latest Flux round.

During the execution of the command, you will need to provide:
- `FLUX_AGGREGATOR_ADDRESS` - Flux Aggregator contract address

### Offchain Aggregator Scripts

#### Set Payees
  ```
  make fct-ocr-set-payees
  ```
This command sets Chainlink nodes 2-5 as `payees` in the Offchain Aggregator contract.

During the execution of the command, you will need to provide:
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Set Config
  ```
  make fct-ocr-set-config
  ```
This command sets OCR configuration in the Offchain Aggregator contract.

During the execution of the command, you will need to provide:
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

> **Note**  
> This package uses external Go library [OCRHelper](external%2FOCRHelper) to prepare an OCR configuration.

#### Request New Round
  ```
  make fct-ocr-request-new-round
  ```
This command requests new OCR round immediately.

During the execution of the command, you will need to provide:
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address

#### Get OCR Latest Answer
  ```
  make fct-ocr-get-latest-answer
  ```
This command returns the answer of the latest OCR round.

During the execution of the command, you will need to provide:
- `OFFCHAIN_AGGREGATOR_ADDRESS` - Offchain Aggregator contract address
