# Foundry Chainlink Toolkit Documentation
This document provides detailed information about each Chainlink service module and its related methods available in the Foundry Chainlink toolkit.

To use these Solidity scripts, import the necessary one into your project and interact with its functions as part of your smart contract development and testing workflow.
Ensure that your environment is configured according to the [README](README.md).

<!-- TOC -->
* [Foundry Chainlink Toolkit Documentation](#foundry-chainlink-toolkit-documentation)
  * [Data Feeds Services](#data-feeds-services)
    * [Data Feeds script: DataFeed.s.sol](#data-feeds-script-datafeedssol)
      * [Get Latest Round Data](#get-latest-round-data)
      * [Get Round Data](#get-round-data)
      * [Get Decimals](#get-decimals)
      * [Get Description](#get-description)
      * [Get Version](#get-version)
    * [ENS script: ENSFeedsResolver.s.sol](#ens-script-ensfeedsresolverssol)
      * [Resolve Aggregator Address](#resolve-aggregator-address)
      * [Resolve Aggregator Address With Subdomains](#resolve-aggregator-address-with-subdomains)
  * [VRF Service](#vrf-service)
    * [VRF script: VRF.s.sol](#vrf-script-vrfssol)
      * [Create Subscription](#create-subscription)
      * [Fund Subscription](#fund-subscription)
      * [Cancel Subscription](#cancel-subscription)
      * [Add Consumer](#add-consumer)
      * [Remove Consumer](#remove-consumer)
      * [Get Subscription Details](#get-subscription-details)
      * [Request Random Words](#request-random-words)
      * [Check Pending Request](#check-pending-request)
      * [Request Subscription Owner Transfer](#request-subscription-owner-transfer)
      * [Accept Subscription Owner Transfer](#accept-subscription-owner-transfer)
      * [Get Request Configuration](#get-request-configuration)
      * [Get Type and Version](#get-type-and-version)
  * [Automation Services](#automation-services)
    * [Automation script: Automation.s.sol](#automation-script-automationssol)
      * [Register Upkeep](#register-upkeep)
      * [Register Upkeep (Log Trigger)](#register-upkeep-log-trigger)
      * [Register Upkeep (Time Based)](#register-upkeep-time-based)
      * [Get Pending Request](#get-pending-request)
      * [Cancel Request](#cancel-request)
      * [Get Registration Config (Keeper Registrar v1.2, v2.0)](#get-registration-config-keeper-registrar-v12-v20)
      * [Get Registration Config (Keeper Registrar v2.1)](#get-registration-config-keeper-registrar-v21)
      * [Add Funds](#add-funds)
      * [Pause Upkeep](#pause-upkeep)
      * [Unpause Upkeep](#unpause-upkeep)
      * [Cancel Upkeep](#cancel-upkeep)
      * [Set Upkeep Gas Limit](#set-upkeep-gas-limit)
      * [Get Min Balance For Upkeep](#get-min-balance-for-upkeep)
      * [Get State](#get-state)
      * [Get Upkeep Transcoder Version](#get-upkeep-transcoder-version)
      * [Get Active Upkeep IDs](#get-active-upkeep-ids)
      * [Get Upkeep](#get-upkeep)
      * [Withdraw Funds](#withdraw-funds)
      * [Transfer Upkeep Admin](#transfer-upkeep-admin)
      * [Accept Upkeep Admin](#accept-upkeep-admin)
      * [Get Type And Version](#get-type-and-version-1)
  * [Functions Services](#functions-services)
    * [Functions script: Functions.s.sol](#functions-script-functionsssol)
      * [Create subscription](#create-subscription-1)
      * [Create subscription with consumer](#create-subscription-with-consumer)
      * [Fund subscription](#fund-subscription-1)
      * [Cancel subscription](#cancel-subscription-1)
      * [Get subscription details](#get-subscription-details-1)
      * [Add consumer](#add-consumer-1)
      * [Remove consumer](#remove-consumer-1)
      * [Propose Subscription new owner](#propose-subscription-new-owner)
      * [Accept Subscription new owner](#accept-subscription-new-owner)
      * [Timeout Subscription requests](#timeout-subscription-requests)
      * [Estimate Functions request cost](#estimate-functions-request-cost)
<!-- TOC -->

## Data Feeds Services

Chainlink [Data Feeds](https://docs.chain.link/data-feeds) are decentralized oracles that provide reliable off-chain data to smart contracts on the blockchain.
Using this service, developers can access the latest round answer and other relevant information from the Data Feeds,
enabling them to fetch real-world data in their web3 projects.

### Data Feeds script: [DataFeed.s.sol](script%2Ffeeds%2FDataFeed.s.sol)

This section provides methods and functionalities designed to interact with the OffchainAggregator smart contract,
which serves as the core component of Chainlink Data Feeds.

#### Get Latest Round Data

- **Method:** getLatestRoundData
- **Description:** Get the latest round data for a Data Feed
- **Returns:** `(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)`
    - `roundId`: Round ID of Data Feed
    - `answer`: Latest round answer for a Data Feed
    - `startedAt`: Timestamp of when the round started
    - `updatedAt`: Timestamp of when the round was updated
    - `answeredInRound`: Round ID of when the round was answered
- **Usage:** `DataFeedScript.getLatestRoundData()`

#### Get Round Data

- **Method:** getRoundData
- **Description:** Get the round data for a Data Feed
- **Arguments:** `(uint80 roundId)`
    - `roundId`: Round ID of Data Feed
- **Returns:** `(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)`
    - `roundId`: Round ID of Data Feed
    - `answer`: Latest round answer for a Data Feed
    - `startedAt`: Timestamp of when the round started
    - `updatedAt`: Timestamp of when the round was updated
    - `answeredInRound`: Round ID of when the round was answered
- **Usage:** `DataFeedScript.getRoundData(1)`

#### Get Decimals

- **Method:** getDecimals
- **Description:** Get the decimals for a Data Feed
- **Returns:** `decimals [uint8]`: Decimals for a Data Feed
- **Usage:** `DataFeedScript.getDecimals()`

#### Get Description

- **Method:** getDescription
- **Description:** Get the description for a Data Feed
- **Returns:** `description [string]`: Description for a Data Feed
- **Usage:** `DataFeedScript.getDescription()`

#### Get Version

- **Method:** getAggregatorVersion
- **Description:** Get the version for a Data Feed
- **Returns:** `version [uint256]`: Version for a Data Feed
- **Usage:** `DataFeedScript.getAggregatorVersion()`

### ENS script: [ENSFeedsResolver.s.sol](script%2Ffeeds%2FENSFeedsResolver.s.sol)

This section provides methods and functionalities designed to interact with the [Chainlink ENS Resolver](https://docs.chain.link/data-feeds/ens).

> **Note**
>  Chainlink ENS is exclusively available on the Ethereum mainnet.

#### Resolve Aggregator Address

- **Method:** `resolveAggregatorAddress`
- **Description:** Resolve Data Feed address for a token pair using the Chainlink ENS Resolver
- **Arguments:** `(string memory baseTick, string memory quoteTick)`
    - `baseTick`: Base tick of the token pair
    - `quoteTick`: Quote tick of the token pair
- **Returns:** `aggregatorAddress [address]`: Data Feed address for a token pair
- **Usage:** `ENSFeedResolverScript.resolveAggregatorAddress("ETH", "USD")`

#### Resolve Aggregator Address With Subdomains

- **Method:** `resolveAggregatorAddressWithSubdomains`
- **Description:** Resolve Data Feed address for a token pair using the Chainlink ENS Resolver with subdomains
- **Arguments:** `(string memory baseTick, string memory quoteTick)`
    - `baseTick`: Base tick of the token pair.
    - `quoteTick`: Quote tick of the token pair.
- **Returns:** (address proxyAggregatorAddress, address underlyingAggregatorAddress, address proposedAggregatorAddress)
    - `proxyAggregatorAddress`: Proxy Data Feed address for a token pair
    - `underlyingAggregatorAddress`: Underlying Data Feed address for a token pair
    - `proposedAggregatorAddress`: Proposed Data Feed address for a token pair
- **Usage:** `ENSFeedResolverScript.resolveAggregatorAddressWithSubdomains("ETH", "USD")`

## VRF Service

Chainlink [VRF](https://docs.chain.link/vrf/v2/introduction) (Verifiable Random Function) service is a critical component
provided by Chainlink that enables smart contracts on the blockchain to securely and transparently access cryptographically secure and unpredictable randomness.

### VRF script: [VRF.s.sol](script%2Fvrf%2FVRF.s.sol)

This section provides methods and functionalities designed to interact with the VRFCoordinator smart contract,
which serves as the intermediary between smart contracts on the blockchain and the VRF service.

#### Create Subscription

- **Method:** createSubscription
- **Description:** Create a new subscription to the VRF service
- **Returns:** `subscriptionId [uint64]`: VRF Subscription ID
- **Usage:** `VRFScript.createSubscription()`

#### Fund Subscription

- **Method:** fundSubscription
- **Description:** Fund a subscription to the VRF service with LINK tokens
- **Arguments:** `(uint256 amountInJuels, uint64 subscriptionId)`
    - `amountInJuels`: Amount of LINK tokens to be sent (in Juels)
    - `subscriptionId`: VRF Subscription ID
- **Usage:** `VRFScript.fundSubscription(1000000000000000000, 1)`

#### Cancel Subscription

- **Method:** cancelSubscription
- **Description:** Cancel a subscription to the VRF service and receive the remaining balance
- **Arguments:** `(uint64 subscriptionId, address receivingAddress)`
    - `subscriptionId`: VRF Subscription ID
    - `receivingAddress`: Address to receive the balance of the subscription
- **Usage:** `VRFScript.cancelSubscription(1, "0x0000000000000000000000000000000000000000")`

#### Add Consumer

- **Method:** addConsumer
- **Description:** Add a new consumer to an existing VRF subscription
- **Arguments:** `(uint64 subscriptionId, address consumerAddress)`
    - `subscriptionId`: VRF Subscription ID
    - `consumerAddress`: Address of the consumer
- **Usage:** `VRFScript.addConsumer("0x0000000000000000000000000000000000000000", 1)`

#### Remove Consumer

- **Method:** removeConsumer
- **Description:** Remove a consumer from an existing VRF subscription
- **Arguments:** `(uint64 subscriptionId, address consumerAddress)`
    - `subscriptionId`: VRF Subscription ID
    - `consumerAddress`: Address of the consumer
- **Usage:** `VRFScript.removeConsumer("0x0000000000000000000000000000000000000000", 1)`

#### Get Subscription Details

- **Method:** getSubscriptionDetails
- **Description:** Get details of an existing VRF subscription
- **Arguments:** `(uint64 subscriptionId)`
    - `subscriptionId`: VRF Subscription ID
- **Returns**: `(uint96 balance, uint64 reqCount, address owner, address[] memory consumers)`
    - `balance`: LINK balance of the subscription in juels
    - `reqCount`: Number of requests for the subscription, determines fee tier
    - `owner`: Owner of the subscription
    - `consumers`: List of consumers of the subscription
- **Usage:** `VRFScript.getSubscriptionDetails(1)`

#### Request Random Words

- **Method:** requestRandomWords
- **Description:** Request random words from the VRF service
- **Arguments:** `(uint64 subscriptionId, bytes32 keyHash, uint16 minimumRequestConfirmations, uint32 callbackGasLimit, uint32 numWords)`
    - `subscriptionId`: VRF Subscription ID. Must be funded with the minimum subscription balance required for the selected keyHash
    - `keyHash`: Key hash related to maxGasPrice of a VRF. Different keyHashes have different gas prices
    - `minimumRequestConfirmations`: How many blocks you'd like the oracle to wait before responding to the request
    - `callbackGasLimit`: How much gas you allow for fulfillRandomWords callback
    - `numWords`: The number of random values you'd like to receive in fulfillRandomWords callback
- **Usage:** `VRFScript.requestRandomWords(1, "0x83250c5584ffa93feb6ee082981c5ebe484c865196750b39835ad4f13780435d", 10, 500000, 3)`

#### Check Pending Request

- **Method:** isPendingRequestExists
- **Description:** Check if there is a pending request for an existing VRF subscription
- **Arguments:** `(uint64 subscriptionId)`
    - `subscriptionId`: VRF Subscription ID
- **Returns:** `isPendingRequestExists [bool]`: True if there is a pending request for the subscription
- **Usage:** `VRFScript.isPendingRequestExists(1)`

#### Request Subscription Owner Transfer

- **Method:** requestSubscriptionOwnerTransfer
- **Description:** Request to transfer ownership of a VRF subscription to a new owner
- **Arguments:** `(uint64 subscriptionId, address newOwnerAddress)`
    - `subscriptionId`: VRF Subscription ID
    - `newOwnerAddress`: Address of the new subscription owner
- **Usage:** `VRFScript.requestSubscriptionOwnerTransfer(1, "0x0000000000000000000000000000000000000000")`

#### Accept Subscription Owner Transfer

- **Method:** acceptSubscriptionOwnerTransfer
- **Description:** Accept the transfer of ownership of a VRF subscription
- **Arguments:** `(uint64 subscriptionId)`
    - `subscriptionId`: VRF Subscription ID
- **Usage:** `VRFScript.acceptSubscriptionOwnerTransfer(1)`

#### Get Request Configuration

- **Method:** getRequestConfig
- **Description:** Get the configuration details of VRF Coordinator requests
- **Returns:** `(uint16 minimumRequestConfirmations, uint32 maxGasLimit, bytes32[] memory s_provingKeyHashes)`
    - `minimumRequestConfirmations`: Global min for request confirmations
    - `maxGasLimit`: Global max for request gas limit
    - `s_provingKeyHashes`: List of registered key hashes
- **Usage:** `VRFScript.getRequestConfig()`

#### Get Type and Version

- **Method:** getTypeAndVersion
- **Description:** Get the type and version details of VRF Coordinator
- **Returns:** `typeAndVersion [string memory]`: Type and Version of VRF Coordinator
- **Usage:** `VRFScript.getTypeAndVersion()`

## Automation Services

Chainlink [Automation](https://docs.chain.link/vrf/v2/introduction) service enables conditional execution
of your smart contracts functions through a hyper-reliable and decentralized automation platform.

### Automation script: [Automation.s.sol](script%2Fautomation%2FAutomation.s.sol)

This section provides methods and functionalities designed to interact with the KeeperRegistry and KeeperRegistrar smart contracts.
Supported versions of Keeper Registry are v1.2, v1.3, v2.0, and v2.1.
Supported versions of Keeper Registrar are v1.2, v2.0, and v2.1.

#### Register Upkeep

- **Method:** registerUpkeep
- **Description:** Register an upkeep task for Chainlink Automation to perform on a specified contract
- **Arguments:** `(uint96 amountInJuels, string memory upkeepName, string memory email, address upkeepAddress, uint32 gasLimit, bytes memory checkData)`
    - `amountInJuels`: Amount of LINK in juels to fund the upkeep
    - `upkeepName`: Upkeep name to be registered
    - `email`: Email address of upkeep contact owner
    - `upkeepAddress`: Upkeep contract address to perform task on
    - `gasLimit`: Limit of gas to provide the target contract when performing upkeep
    - `checkData`: Data passed to the contract when checking upkeep
- **Returns:** `requestHash [bytes32]`: Hash of the registration request
- **Usage:** `AutomationScript.registerUpkeep(1000000000000000000, "upkeep", "email", "0x0000000000000000000000000000000000000000", 500000, "0x")`

#### Register Upkeep (Log Trigger)

- **Method:** registerUpkeep_logTrigger
- **Description:** Register an upkeep task for Chainlink Automation to perform on a specified contract with a log trigger
- **Arguments:** `(uint96 amountInJuels, string memory upkeepName, string memory email, address upkeepAddress, uint32 gasLimit, bytes memory checkData, bytes memory triggerConfig)`
    - `amountInJuels`: Amount of LINK in juels to fund the upkeep
    - `upkeepName`: Upkeep name to be registered
    - `email`: Email address of upkeep contact owner
    - `upkeepAddress`: Upkeep contract address to perform task on
    - `gasLimit`: Limit of gas to provide the target contract when performing upkeep
    - `checkData`: Data passed to the contract when checking upkeep
    - `triggerConfig`: Encoded log trigger configuration, use Utils.getLogTriggerConfig method to generate
- **Returns:** `requestHash [bytes32]`: Hash of the registration request
- **Usage:** `AutomationScript.registerUpkeep_logTrigger(1000000000000000000, "upkeep", "email", "0x0000000000000000000000000000000000000000", 500000, "0x", "0x")`

#### Register Upkeep (Time Based)

- **Method:** registerUpkeep_timeBased
- **Description:** Register an upkeep task for Chainlink Automation to perform on a specified contract with a time based trigger
- **Arguments:** `(uint96 amountInJuels, string memory upkeepName, string memory email, address upkeepAddress, uint32 gasLimit, bytes memory checkData, address cronUpkeepFactoryAddress, bytes4 upkeepFunctionSelector, string calldata cronString)`
    - `amountInJuels`: Amount of LINK in juels to fund the upkeep
    - `upkeepName`: Upkeep name to be registered
    - `email`: Email address of upkeep contact owner
    - `upkeepAddress`: Upkeep contract address to perform task on
    - `gasLimit`: Limit of gas to provide the target contract when performing upkeep
    - `checkData`: Data passed to the contract when checking upkeep
    - `cronUpkeepFactoryAddress`: Address of CronUpkeepFactory contract
    - `upkeepFunctionSelector`: Function selector of the upkeep function
    - `cronString`: Cron string with a schedule for performing upkeep
- **Returns:** `requestHash [bytes32]`: Hash of the registration request
- **Usage:** `AutomationScript.registerUpkeep_timeBased(1000000000000000000, "upkeep", "email", "0x0000000000000000000000000000000000000000", 500000, "0x", "0xCccCCCCcccCCcCccccCC00000000000000000000", "0x00000000", "0 0 * * *")`

#### Get Pending Request

- **Method:** getPendingRequest
- **Description:** Get information about a pending registration request for an upkeep task
- **Arguments:** `(bytes32 requestHash)`
    - `requestHash`: Hash of the registration request
- **Returns:** `(address admin, uint96 balance)`
    - `admin`: Address of the admin of the upkeep task
    - `balance`: LINK balance of the upkeep task in juels
- **Usage:** `AutomationScript.getPendingRequest("0x0000000000000000000000000000000000000000000000000000000000000000")`

#### Cancel Request

- **Method:** cancelRequest
- **Description:** Cancel a pending registration request for an upkeep task
- **Arguments:** `(bytes32 requestHash)`
    - `requestHash`: Hash of the registration request
- **Usage:** `AutomationScript.cancelRequest("0x0000000000000000000000000000000000000000000000000000000000000000")`

#### Get Registration Config (Keeper Registrar v1.2, v2.0)

- **Method:** getRegistrationConfig
- **Description:** Get the registration configuration for upkeep tasks from the Keeper Registrar
- **Returns:** `(AutomationUtils.AutoApproveType autoApproveType, uint32 autoApproveMaxAllowed, uint32 approvedCount, address keeperRegistry, uint256 minLINKJuels)`
    - `autoApproveType`: Setting for auto-approve registrations
    - `autoApproveMaxAllowed`: Max number of registrations that can be auto approved
    - `approvedCount`: Number of approved registrations
    - `keeperRegistry`: Keeper registry address
    - `minLINKJuels`: Minimum LINK that new registrations should fund their upkeep with
- **Usage:** `AutomationScript.getRegistrationConfig()`

#### Get Registration Config (Keeper Registrar v2.1)

- **Method:** getRegistrationConfig
- **Description:** Get the registration configuration for upkeep tasks from the Keeper Registrar
- **Arguments:** `(AutomationUtils.Trigger triggerType)`
    - `triggerType`: Trigger type of the upkeep task
- **Returns:** `(AutomationUtils.AutoApproveType autoApproveType, uint32 autoApproveMaxAllowed, uint32 approvedCount, address keeperRegistry, uint256 minLINKJuels)`
    - `autoApproveType`: Setting for auto-approve registrations
    - `autoApproveMaxAllowed`: Max number of registrations that can be auto approved
    - `approvedCount`: Number of approved registrations
    - `keeperRegistry`: Keeper registry address
    - `minLINKJuels`: Minimum LINK that new registrations should fund their upkeep with
- **Usage:** `AutomationScript.getRegistrationConfig(AutomationUtils.Trigger.CONDITION)`

#### Add Funds

- **Method:** addFunds
- **Description:** Add funds to an upkeep task
- **Arguments:** `(uint256 upkeepId, uint96 amountInJuels)`
    - `upkeepId`: Upkeep ID
    - `amountInJuels`: Amount of LINK in juels to fund the upkeep
- **Usage:** `AutomationScript.addFunds(1, 1000000000000000000)`

#### Pause Upkeep

- **Method:** pauseUpkeep
- **Description:** Pause an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Usage:** `AutomationScript.pauseUpkeep(1)`

#### Unpause Upkeep

- **Method:** unpauseUpkeep
- **Description:** Unpause an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Usage:** `AutomationScript.unpauseUpkeep(1)`

#### Cancel Upkeep

- **Method:** cancelUpkeep
- **Description:** Cancel an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Usage:** `AutomationScript.cancelUpkeep(1)`

#### Set Upkeep Gas Limit

- **Method:** setUpkeepGasLimit
- **Description:** Set the gas limit for an upkeep task
- **Arguments:** `(uint256 upkeepId, uint32 gasLimit)`
    - `upkeepId`: Upkeep ID
    - `gasLimit`: Limit of gas to provide the target contract when performing upkeep
- **Usage:** `AutomationScript.setUpkeepGasLimit(1, 500000)`

#### Get Min Balance For Upkeep

- **Method:** getMinBalanceForUpkeep
- **Description:** Get the minimum required balance for upkeep from the Keeper Registry
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Returns:** `minBalance [uint96]`: Minimum required balance for upkeep in juels
- **Usage:** `AutomationScript.getMinBalanceForUpkeep(1)`

#### Get State

- **Method:** getState
- **Description:** Get the state of an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Returns:** `registryState [RegistryState memory]`: State of the upkeep task (combined state structure of different versions of Keeper Registry)
- **Usage:** `AutomationScript.getState(1)`

#### Get Upkeep Transcoder Version

- **Method:** getUpkeepTranscoderVersion
- **Description:** Get the upkeep transcoder version from Keeper Registry
- **Returns:** `upkeepFormat [AutomationUtils.UpkeepFormat]`: Upkeep transcoder version
- **Usage:** `AutomationScript.getUpkeepTranscoderVersion()`

#### Get Active Upkeep IDs

- **Method:** getActiveUpkeepIDs
- **Description:** Get the list of active upkeep IDs from Keeper Registry
- **Arguments:** `(uint256 startIndex, uint256 maxCount)`
    - `startIndex`: Start index of the list of active upkeep IDs
    - `maxCount`: Max number of active upkeep IDs to return
- **Returns:** `upkeepIDs [uint256[] memory]`: List of active upkeep IDs
- **Usage:** `AutomationScript.getActiveUpkeepIDs(0, 10)`

#### Get Upkeep

- **Method:** getUpkeep
- **Description:** Get the details of an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Returns:** `(address target, uint32 executeGas, bytes memory checkData, uint96 balance, address admin, uint64 maxValidBlocknumber, uint96 amountSpent, bool paused)`
    - `target`: Target contract address of the upkeep task
    - `executeGas`: Gas limit for the upkeep task
    - `checkData`: Data passed to the contract when checking upkeep
    - `balance`: LINK balance of the upkeep task in juels
    - `admin`: Address of the admin of the upkeep task
    - `maxValidBlocknumber`: Max valid block number for the upkeep task
    - `amountSpent`: Amount spent on the upkeep task
    - `paused`: True if the upkeep task is paused
- **Usage:** `AutomationScript.getUpkeep(1)`

#### Withdraw Funds

- **Method:** withdrawFunds
- **Description:** Withdraw funds from an upkeep task
- **Arguments:** `(uint256 upkeepId, address receivingAddress)`
    - `upkeepId`: Upkeep ID
    - `receivingAddress`: Address to receive the withdrawn LINK
- **Usage:** `AutomationScript.withdrawFunds(1, "0x0000000000000000000000000000000000000000")`

#### Transfer Upkeep Admin

- **Method:** transferUpkeepAdmin
- **Description:** Transfer the admin of an upkeep task
- **Arguments:** `(uint256 upkeepId, address proposedAdmin)`
    - `upkeepId`: Upkeep ID
    - `proposedAdmin`: Address of the new admin of the upkeep task
- **Usage:** `AutomationScript.transferUpkeepAdmin(1, "0x0000000000000000000000000000000000000000")`

#### Accept Upkeep Admin

- **Method:** acceptUpkeepAdmin
- **Description:** Accept the transfer of admin of an upkeep task
- **Arguments:** `(uint256 upkeepId)`
    - `upkeepId`: Upkeep ID
- **Usage:** `AutomationScript.acceptUpkeepAdmin(1)`

#### Get Type And Version

- **Method:** getTypeAndVersion
- **Description:** Get the type and version for Keeper Registry
- **Returns:** `typeAndVersion [string memory]`: Type and Version of Keeper Registry
- **Usage:** `AutomationScript.getTypeAndVersion()`

## Functions Services

Chainlink [Functions](https://docs.chain.link/chainlink-functions) service provides your smart contracts access to
trust-minimized compute infrastructure, allowing you to fetch data from APIs and perform custom computation.

### Functions script: [Functions.s.sol](script%2Ffunctions%2FFunctions.s.sol)

This section provides methods and functionalities designed to interact with the Functions Router smart contract.

#### Create subscription

- **Method:** createSubscription
- **Description:** Create Functions subscription
- **Returns:** `subscriptionId [uint64]`: Functions Subscription ID
- **Usage:** `FunctionsScript.createSubscription()`

#### Create subscription with consumer

- **Method:** createSubscriptionWithConsumer
- **Description:** Create Functions subscription with consumer
- **Arguments:** `(address consumerAddress)`
  - `consumerAddress`: Address of Functions Consumer
- **Returns:** `subscriptionId [uint64]`: Functions Subscription ID
- **Usage:** `FunctionsScript.createSubscriptionWithConsumer("0x0000000000000000000000000000000000000000")`

#### Fund subscription

- **Method:** fundSubscription
- **Description:** Fund Functions subscription
- **Arguments:** `(address linkTokenAddress, uint256 amountInJuels, uint64 subscriptionId)`
  - `linkTokenAddress`: Address of Link Token
  - `amountInJuels`: Amount of LINK in Juels to fund Subscription
  - `subscriptionId`: Subscription ID
- **Usage:** `FunctionsScript.fundSubscription("0x0000000000000000000000000000000000000000", 1000000000000000000, 1)`

#### Cancel subscription

- **Method:** cancelSubscription
- **Description:** Cancel Functions subscription
- **Arguments:** `(uint64 subscriptionId, address receivingAddress)`
  - `subscriptionId`: Subscription ID
  - `receivingAddress`: Address to receive the balance of Subscription
- **Usage:** `FunctionsScript.cancelSubscription(1, "0x0000000000000000000000000000000000000000")`

#### Get subscription details

- **Method:** getSubscriptionDetails
- **Description:** Get subscription details
- **Arguments:** `(uint64 subscriptionId)`
  - `subscriptionId`: Subscription ID
- **Returns:** `subscriptionDetails [IFunctionsSubscriptions.Subscription]`: Subscription details
- **Usage:** `FunctionsScript.getSubscriptionDetails(1)`

#### Add consumer

- **Method:** addConsumer
- **Description:** Add a new consumer to an existing Functions subscription
- **Arguments:** `(uint64 subscriptionId, address consumerAddress)`
  - `subscriptionId`: Subscription ID
  - `consumerAddress`: Address of Functions Consumer
- **Usage:** `FunctionsScript.addConsumer(1, "0x0000000000000000000000000000000000000000")`

#### Remove consumer

- **Method:** removeConsumer
- **Description:** Remove a consumer from an existing Functions subscription
- **Arguments:** `(uint64 subscriptionId, address consumerAddress)`
  - `subscriptionId`: Subscription ID
  - `consumerAddress`: Address of Functions Consumer
- **Usage:** `FunctionsScript.removeConsumer(1, "0x0000000000000000000000000000000000000000")`

#### Propose Subscription new owner

- **Method:** proposeSubscriptionOwnerTransfer
- **Description:** Propose subscription owner transfer
- **Arguments:** `(uint64 subscriptionId, address newOwner)`
  - `subscriptionId`: Subscription ID
  - `newOwner`: Address of new owner of Subscription
- **Usage:** `FunctionsScript.proposeSubscriptionOwnerTransfer(1, "0x0000000000000000000000000000000000000000")`

#### Accept Subscription new owner

- **Method:** acceptSubscriptionOwnerTransfer
- **Description:** Accept subscription owner transfer
- **Arguments:** `(uint64 subscriptionId)`
  - `subscriptionId`: Subscription ID
- **Usage:** `FunctionsScript.acceptSubscriptionOwnerTransfer(1)`

#### Timeout Subscription requests

- **Method:** timeoutRequests
- **Description:** Timeout subscription requests
- **Arguments:** `(FunctionsResponse.Commitment[] memory commitments)`
  - `commitments`: Commitments to timeout
- **Usage:** `FunctionsScript.timeoutRequests(commitments)`

#### Estimate Functions request cost

- **Method:** estimateRequestCost
- **Description:** Estimate Functions request cost
- **Arguments:** `(string memory donId, uint64 subscriptionId, uint32 callbackGasLimit, uint256 gasPriceWei)`
  - `donId`: ID of the DON where Functions requests will be sent
  - `subscriptionId`: Subscription ID
  - `callbackGasLimit`: Callback gas limit
  - `gasPriceWei`: Gas price in Wei
- **Returns:** `estimatedCost [uint96]`: Estimated cost of Functions request
- **Usage:** `FunctionsScript.estimateRequestCost("donId", 1, 500000, 100000000000)`
