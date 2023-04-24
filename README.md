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
      
> **Note**  
> Tested with forge 0.2.0 (e99cf83 2023-04-21T00:15:57.602861000Z).
> 
> You may see the following error on MacOS: ```dyld: Library not loaded: /usr/local/opt/libusb/lib/libusb-1.0.0.dylib```.  
> In order to fix this, you should install libusb: ```brew install libusb```.  
> Reference: https://github.com/foundry-rs/foundry/blob/master/README.md#troubleshooting-installation

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
> Tested with GNU Make 3.81.

3. Install and run Docker; for convenience, the Chainlink nodes run in a container. Instructions: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/).

> **Note**  
> Tested with Docker version 20.10.23, build 7155243.

### Chain RPC node
In order for a Chainlink node to be able to interact with the blockchain, and to interact with the blockchain using the [Forge](https://book.getfoundry.sh/forge/), you have to know an RPC node http endpoint and web socket for a chosen network compatible with Chainlink.
In addition to the networks listed in [this list](https://docs.chain.link/chainlink-automation/supported-networks/), Chainlink is compatible with any EVM-compatible networks.

For local testing, we recommend using [Anvil](https://book.getfoundry.sh/anvil/), which is a part of the Foundry toolchain.

Run Anvil using the following command:
```
anvil --block-time 10 --chain-id 1337
```

By default, Anvil runs with the following options:
- http endpoint: http://localhost:8545
- web socket: [ws://localhost:8545](ws://localhost:8545)
- chain ID: 31337

### Chainlink shared folders
We use some subdirectories of the [chainlink](chainlink) folder as shared folders with Chainlink node containers and Postgres container.

#### Settings
- [chainlink_api_credentials](chainlink%2Fsettings%2Fchainlink_api_credentials) - Chainlink API credentials
- [chainlink_password](chainlink%2Fsettings%2Fchainlink_password) - Chainlink password

> **Note**  
> More info on authentication can be found here [github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API](https://github.com/smartcontractkit/chainlink/wiki/Authenticating-with-the-API).
> You can specify any credentials there. Password provided must be 16 characters or more.

#### Jobs
- [cron_job.toml](chainlink%2Fjobs%2Fcron_job.toml) - example configuration file for a Chainlink Cron job  
- [direct_request_job.toml](chainlink%2Fjobs%2Fdirect_request_job.toml) - example configuration file for a Chainlink Direct Request job  
- [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml) - example configuration file for a Chainlink Flux job  
- [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml) - example configuration file for a Chainlink Keeper job  
- [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml) - example configuration file for a Chainlink OCR job  
- [ocr_job_bootstrap.toml](chainlink%2Fjobs%2Focr_job_bootstrap.toml) - example configuration file for a Chainlink OCR (bootstrap) job  
- [webhook_job.toml](chainlink%2Fjobs%2Fwebhook_job.toml) - example configuration file for a Chainlink Webhook job  

> **Note**  
> More info on Chainlink v2 Jobs, their types and configuration can be found here: [docs.chain.link/chainlink-nodes/oracle-jobs/jobs/](https://docs.chain.link/chainlink-nodes/oracle-jobs/jobs/).
> You can change this configuration according to your requirements.

#### SQL scripts
- [create_tables.sql](chainlink%2Fsql%2Fcreate_tables.sql) - psql script to create tables related to Chainlink nodes in a Postgres DB
- [drop_tables.sql](chainlink%2Fsql%2Fdrop_tables.sql) - psql script to delete tables related to Chainlink nodes in a Postgres DB

#### Chainlink nodes logs directories
Once a Chainlink cluster is started, log directories will be created for each Chainlink node.  
Log directory name format: `${CHAINLINK_CONTAINER_NAME}${NODE_ID}`.

### Environment variables
Based on the [env.template](env.template) - create or update an `.env` file in the root directory of your project.  

Below are comments on some environment variables:
- `ETH_URL` - RPC node web socket used by the Chainlink node
- `RPC_URL` - RPC node http endpoint used by Forge
- `PRIVATE_KEY` - private key of an account used for deployment and interaction with smart contracts. Once Anvil is started, a set of private keys for local usage is provided. Use one of these for local development.
- `ROOT` - root directory of the Chainlink node
- `CHAINLINK_CONTAINER_NAME` - preferred name for the container of the Chainlink node for the possibility of automating communication with it
- `FOUNDRY_PROFILE` - selected Foundry profile in [foundry.toml](foundry.toml), more on Foundry profiles: https://book.getfoundry.sh/reference/config/overview?highlight=profile#profiles

Besides that, there is the [chainlink.env](chainlink%2Fchainlink.env) that contains environment variables related to a Chainlink node configuration.
> **Note**  
> More info on Chainlink node environment variables can be found here: [https://docs.chain.link/chainlink-nodes/v1/configuration](https://docs.chain.link/chainlink-nodes/v1/configuration).
> You can specify any parameters according to your preferences.

### Chainlink Consumer Contracts
The [contracts](chainlink%2Fcontracts) directory contains examples of Chainlink Consumer contracts:  
- [ChainlinkConsumer.sol](chainlink%2Fcontracts%2FChainlinkConsumer.sol) - sample Consumer contract for a Chainlink Direct Request job
- [ChainlinkCronConsumer.sol](chainlink%2Fcontracts%2FChainlinkCronConsumer.sol) - sample Consumer contract for a Chainlink Cron job
- [ChainlinkKeeperConsumer.sol](chainlink%2Fcontracts%2FChainlinkKeeperConsumer.sol) - sample Consumer contract for a Chainlink Keeper job

### Solidity Scripting
Functionality related to deployment and interaction with smart contracts is implemented using [Foundry Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=script#solidity-scripting).  
The [script](script) directory contains scripts for the Link Token, Oracle, Registry, Chainlink Consumer contracts, Flux and Offchain aggregators as well as the transfer of ETH and Link tokens.  
Scripts are run with the command: `forge script path/to/script [--args]`. Logs and artifacts dedicated to each script run, including a transaction hash and an address of deployed smart contract, are stored in a corresponding subdirectory of the [broadcast](broadcast) folder (created automatically).

All necessary scripts are also included in the [makefile](makefile). In order to run these scripts, you first need to install the necessary dependencies:
```
make install
```

This command installs:
- [Forge Standard Library](https://github.com/foundry-rs/forge-std)
- [Chainlink Contracts](https://github.com/smartcontractkit/chainlink-brownie-contracts) [version:0.6.1]
- [Chainlink Testing Framework Contracts](https://github.com/smartcontractkit/chainlink-testing-framework) [version:v1.11.5]
- [Link Token Contract](https://github.com/smartcontractkit/LinkToken)
- [Openzeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) [version:v4.8.2]

## Usage
Below are the scripts contained in the [makefile](makefile). Some scripts have parameters that can be passed either on the command line, interactively or in the `.env` file.

### Helper scripts

#### Build Chainlink Contracts
  ```
  make build-chainlink-contracts
  ```
  This command builds Chainlink contracts artifacts.
  The contracts to be built:
  - Contracts from external libraries: Link Token, Oracle, Registry related contracts, Flux and Offchain Aggregators
  - Chainlink Consumer contracts, located in the [contracts](chainlink%2Fcontracts) directory

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

  For authorization, you must use the credentials specified in the [chainlink_api_credentials](chainlink%2Fchainlink_api_credentials).
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

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Get Chainlink ETH keys
  ```
  make get-eth-keys
  ```
  This command returns data related to Chainlink node's EVM Chain Accounts, e.g.:
  - Account address (this is the address for a Chainlink node wallet)
  - Link token balance
  - ETH balance  

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Get Chainlink OCR keys
  ```
  make get-ocr-keys
  ```
  This command returns Chainlink node's OCR keys.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

#### Get Chainlink P2P keys
  ```
  make get-p2p-keys
  ```
  This command returns Chainlink node's P2P keys.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID

> **Note**  
> You also can find information on keys in the node Operator GUI under the Key Management configuration.

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

#### Deploy Chainlink Offchain Aggregator contract
  ```
  make deploy-chainlink-offchain-aggregator
  ```
  This command deploys an instance of Chainlink [OffchainAggregator.sol](src%2FOffchainAggregator%2FOffchainAggregator.sol) contract.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address

#### Deploy Chainlink Flux Aggregator contract
  ```
  make deploy-chainlink-flux-aggregator
  ```
  This command deploys an instance of Chainlink [OffchainAggregator.sol](src%2FOffchainAggregator%2FOffchainAggregator.sol) contract.

  During the execution of the command, you will need to enter:
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
  - WEBHOOK_JOB_ID - Webhook job ID

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
  This command creates a Chainlink job for each Chainlink node in a cluster according to [keeper_job.toml](chainlink%2Fjobs%2Fkeeper_job.toml).

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address

  > **Note**  
  > For the Chainlink Keeper Job it was noticed that Chainlink nodes require a current blockchain height to be approximately at least 100 blocks.

#### Create Chainlink OCR (bootstrap) job
  ```
  make create-ocr-bootstrap-job
  ```
  This command creates a Chainlink job for the first Chainlink node in a cluster according to [ocr_job_bootstrap.toml](chainlink%2Fjobs%2Focr_job_bootstrap.toml).

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

#### Create Chainlink OCR job
  ```
  make create-ocr-job
  ```
  This command creates a Chainlink job according to [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml).

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address
  - BOOTSTRAP_P2P_KEY - P2P key for an OCR bootstrap Chainlink node

#### Create Chainlink OCR jobs
  ```
  make create-ocr-jobs
  ```
  This command creates a Chainlink job for each Chainlink node except the first one (bootstrap) in a cluster according to [ocr_job.toml](chainlink%2Fjobs%2Focr_job.toml).

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

#### Create Chainlink Flux job
  ```
  make create-flux-job
  ```
  This command creates a Chainlink job according to [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml).

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

#### Create Chainlink Flux jobs
  ```
  make create-flux-jobs
  ```
  This command creates a Chainlink job for the first 3 Chainlink nodes in a cluster according to [flux_job.toml](chainlink%2Fjobs%2Fflux_job.toml).

  During the execution of the command, you will need to enter:
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

   > **Note**  
   > You can check list of created jobs with Chainlink Operator GUI.

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

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address
  - RECIPIENT - Recipient address

#### Transfer Link tokens to Chainlink node
  ```
  make transfer-link-to-node
  ```
  With this command, you can send Link tokens to any specified Chainlink node.

  During the execution of the command, you will need to enter:
  - NODE_ID - Chainlink node ID
  - LINK_CONTRACT_ADDRESS - Link Token contract address

#### Transfer Link tokens to Chainlink nodes
  ```
  make transfer-link-to-nodes
  ```
  With this command, you can send Link tokens to all Chainlink nodes in a cluster.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address

### Link Token Solidity Scripts

#### Transfer-and-Call Link Token
  ```
  make transfer-and-call-link
  ```
  This command transfers Link tokens to the Registry contract and calls it's `onTokenTransfer` method that verifies that an upkeep is funded.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address

#### Get Link Token balance
  ```
  make get-balance
  ```
  This command returns Link Token balance of an account.

  During the execution of the command, you will need to enter:
  - LINK_CONTRACT_ADDRESS - Link Token contract address
  - ACCOUNT - Account

### Chainlink Consumer Solidity Scripts

#### Request ETH price
  ```
  make request-eth-price-consumer
  ```
  This command calls `requestEthereumPrice` method of the Consumer contract, which asks the node to retrieve data specified in a Job configuration.  

  During the execution of the command, you will need to enter:
  - CONSUMER_ADDRESS - Consumer contract address
  - ORACLE_ADDRESS - Oracle contract address
  - DIRECT_REQUEST_EXTERNAL_JOB_ID - Direct request External Job ID **without dashes** - you can get one with Chainlink Operator GUI on the Jobs tab

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

### Chainlink Keeper Consumer Solidity Scripts

#### Get Keeper Counter
  ```
  make get-keeper-counter
  ```
  This command returns the latest value of the `counter` variable stored in the Keeper Consumer contract. This variable reflects the number of times the keepers performed the Keeper job.

  During the execution of the command, you will need to enter:
  - KEEPER_CONSUMER_ADDRESS - Keeper Consumer contract address

### Registry Solidity Scripts

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
  This command returns an ID of the last registered upkeep in the Registry contract.

  During the execution of the command, you will need to enter:
  - REGISTRY_ADDRESS - Registry contract address

### Offchain Aggregator Solidity Scripts

#### Set Payees
  ```
  make set-payees
  ```
  This command sets `payees` in the Offchain Aggregator contract.

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

#### Set Config
  ```
  make set-config
  ```
  This command sets OCR configuration in the Offchain Aggregator contract.

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

> **Note**  
> This package uses external Go library [OCRHelper](external%2FOCRHelper) to prepare an OCR configuration.  
> This Go library is based on https://github.com/smartcontractkit/chainlink integration tests.  
> It has pre-built binaries for platforms: darwin/amd64, darwin/arm64, linux/amd64, linux/arm,linux/arm64.  
> If you use another platform, please run in advance:  
> ```make build-ocr-helper```  
> to build external library for your platform. It requires Go (1.19) installed.

#### Request New Round
  ```
  make request-new-round
  ```
  This command requests new OCR round immediately.

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

#### Get OCR Latest Answer
  ```
  make get-latest-answer-ocr
  ```
  This command returns an answer of the latest OCR round.

  During the execution of the command, you will need to enter:
  - OFFCHAIN_AGGREGATOR_ADDRESS - Offchain Aggregator contract address

### Flux Aggregator Solidity Scripts

#### Update Available Funds
  ```
  make update-available-funds
  ```
  This command recalculate the amount of LINK available for payouts in the Flux Aggregator contract.

  During the execution of the command, you will need to enter:
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

#### Set Oracles
  ```
  make set-oracles
  ```
  This command adds new oracles as well as updates the round related parameters in the Flux Aggregator contract.

  During the execution of the command, you will need to enter:
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

#### Get Oracles
  ```
  make get-oracles
  ```
  This command returns an array of addresses containing the oracles in the Flux Aggregator contract.

  During the execution of the command, you will need to enter:
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

#### Get Flux Latest Answer
  ```
  make get-latest-answer-flux
  ```
  This command returns an answer of the latest Flux round.

  During the execution of the command, you will need to enter:
  - FLUX_AGGREGATOR_ADDRESS - Flux Aggregator contract address

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

### Testing flows
#### Initial setup
1. Build Chainlink contracts artifacts
2. Deploy Link Token contract
3. Set `LINK_TOKEN_CONTRACT` in `.env`
4. Spin up a Chainlink nodes cluster
5. Fund Chainlink nodes with ETH
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

#### OCR Job
1. Deploy Offchain Aggregator contract
2. Set Offchain Aggregator payees
3. Set Offchain Aggregator config
4. Create OCR Job for a bootstrap Chainlink node (first in a cluster)
5. Create OCR Jobs for Chainlink nodes in a cluster except the first one (bootstrap)
6. Request new OCR round in the Offchain Aggregator contract (optional)
7. Get the answer of the latest OCR round from the Offchain Aggregator contract

#### Flux Job
1. Deploy Flux Aggregator contract
2. Fund Flux Aggregator contract with Link tokens 
3. Update Flux Aggregator available funds
4. Set Flux Aggregator oracles
5. Create Flux Jobs for the first 3 Chainlink nodes in a cluster
6. Get the answer of the latest Flux round from the Flux Aggregator contract

## Acknowledgements
This project based on https://github.com/protofire/hardhat-chainlink-plugin. 
