// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";

import "../helpers/BaseScript.s.sol";
import "../helpers/TypeAndVersion.s.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";
import "src/interfaces/automation/CronUpkeepFactoryInterface.sol";
import { KeeperRegistrar1_2Interface } from "src/interfaces/automation/KeeperRegistrar1_2Interface.sol";
import { KeeperRegistrar2_0Interface } from "src/interfaces/automation/KeeperRegistrar2_0Interface.sol";
import { AutomationRegistrar2_1Interface, TriggerRegistrationStorage } from "src/interfaces/automation/AutomationRegistrar2_1Interface.sol";
import "src/interfaces/automation/KeeperRegistryInterface.sol";
import { KeeperRegistry1_3Interface, State as StateV1_0, Config as ConfigV1_0 } from "src/interfaces/automation/KeeperRegistry1_3Interface.sol";
import { KeeperRegistry2_0Interface, State as StateV2_0, OnchainConfig as ConfigV2_0, UpkeepInfo as UpkeepInfoV2_0 } from "src/interfaces/automation/KeeperRegistry2_0Interface.sol";
import { KeeperRegistry2_1Interface, State as StateV2_1, OnchainConfig as ConfigV2_1, UpkeepInfo as UpkeepInfoV2_1 } from "src/interfaces/automation/KeeperRegistry2_1Interface.sol";
import "src/interfaces/automation/KeeperRegistrarInterface.sol";
import "src/libraries/AutomationGenerations.sol";
import "src/libraries/AutomationUtils.sol";
import "src/libraries/TypesAndVersions.sol";
import "src/libraries/Utils.sol";

struct CombinedState {
  uint32 nonce;
  uint96 ownerLinkBalance;
  uint256 expectedLinkBalance;
  uint256 numUpkeeps;
  uint96 totalPremium; // From the v2_0 and v2_1
  uint32 configCount; // From the v2_0 and v2_1
  uint32 latestConfigBlockNumber; // From the v2_0 and v2_1
  bytes32 latestConfigDigest; // From the v2_0 and v2_1
  uint32 latestEpoch; // From the v2_0 and v2_1
  bool paused; // From the  v2_0 and v2_1
}

struct CombinedConfig {
  uint32 paymentPremiumPPB;
  uint32 flatFeeMicroLink; // min 0.000001 LINK, max 4294 LINK
  uint32 checkGasLimit;
  uint24 stalenessSeconds;
  uint16 gasCeilingMultiplier;
  uint96 minUpkeepSpend;
  uint32 maxPerformGas;
  uint32 maxCheckDataSize; // From the v2_0 and v2_1
  uint32 maxPerformDataSize; // From the v2_0 and v2_1
  uint32 maxRevertDataSize; // From the v2_1
  uint256 fallbackGasPrice;
  uint256 fallbackLinkPrice;
  address transcoder;
  address[] registrars; // From the v2_1, v1_0 and v2_0 transformed to array
  address upkeepPrivilegeManager; // From the v2_1
  uint24 blockCountPerTurn; // From the v1_0
}

struct RegistryState {
  CombinedState combinedState;
  CombinedConfig combinedConfig;
  address[] signers; // From the v2_0 and v2_1, v1_0 keepers
  address[] transmitters; // From the v2_0 and v2_1, v1_0 keepers
  uint8 f; // From the v2_0 and v2_1
}

contract AutomationScript is BaseScript, TypeAndVersionScript {
  event NewCronUpkeepCreated(address upkeep, address owner);

  uint8 private constant REGISTRATION_SOURCE = 0;
  bytes private constant EMPTY_BYTES = new bytes(0);

  address public linkTokenAddress;
  address public keeperRegistryAddress;
  address public keeperRegistrarAddress;
  string public keeperRegistryTypeAndVersion;
  string public keeperRegistrarTypeAndVersion;

  constructor (address _keeperRegistryAddress) {
    keeperRegistryAddress = _keeperRegistryAddress;
    keeperRegistryTypeAndVersion = TypeAndVersionInterface(keeperRegistryAddress).typeAndVersion();

    if (AutomationGenerations.isV1_0(keeperRegistryTypeAndVersion)) {
      (,ConfigV1_0 memory config,) = KeeperRegistry1_3Interface(keeperRegistryAddress).getState();
      keeperRegistrarAddress = config.registrar;
    }
    else if (AutomationGenerations.isV2_0(keeperRegistryTypeAndVersion)) {
      (,ConfigV2_0 memory config,,,) = KeeperRegistry2_0Interface(keeperRegistryAddress).getState();
      keeperRegistrarAddress = config.registrar;
    }
    else if (AutomationGenerations.isV2_1(keeperRegistryTypeAndVersion)) {
      (,ConfigV2_1 memory config,,,) = KeeperRegistry2_1Interface(keeperRegistryAddress).getState();
      keeperRegistrarAddress = config.registrars[0];
    }
    else {
      revert("Unsupported KeeperRegistry typeAndVersion");
    }
    linkTokenAddress = KeeperRegistrarInterface(keeperRegistrarAddress).LINK();
    keeperRegistrarTypeAndVersion = TypeAndVersionInterface(keeperRegistrarAddress).typeAndVersion();
  }

  /// @notice Keeper Registrar functions

  /**
   * @notice registerUpkeep function to register upkeep
   * @param amountInJuels quantity of LINK upkeep is funded with (specified in Juels)
   * @param upkeepName string of the upkeep to be registered
   * @param upkeepAddress address to perform upkeep on
   * @param gasLimit amount of gas to provide the target contract when performing upkeep
   * @param checkData data passed to the contract when checking for upkeep
   */
  function registerUpkeep(
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData
  ) nestedScriptContext public returns (bytes32 requestHash) {
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);

    bytes memory encryptedEmail = bytes(email);

    // Reference: https://docs.chain.link/chainlink-automation/guides/register-upkeep-in-contract
    bytes memory offchainConfig = EMPTY_BYTES; // Leave as 0x, placeholder parameter for future use

    bytes memory additionalData;
    if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar1_2)) {
      bytes4 registerSelector = KeeperRegistrar1_2Interface.register.selector;
      additionalData = abi.encodeWithSelector(
        registerSelector,
        upkeepName,
        encryptedEmail,
        upkeepAddress,
        gasLimit,
        msg.sender,
        checkData,
        amountInJuels,
        REGISTRATION_SOURCE,
        msg.sender
      );
    } else if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_0)) {
      bytes4 registerSelector = KeeperRegistrar2_0Interface.register.selector;
      additionalData = abi.encodeWithSelector(
        registerSelector,
        upkeepName,
        encryptedEmail,
        upkeepAddress,
        gasLimit,
        msg.sender,
        checkData,
        offchainConfig,
        amountInJuels,
        msg.sender
      );
    } else if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_1)) {
      bytes4 registerSelector = AutomationRegistrar2_1Interface.register.selector;
      AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.CONDITION;
      bytes memory triggerConfig = EMPTY_BYTES;
      additionalData = abi.encodeWithSelector(
        registerSelector,
        upkeepName,
        encryptedEmail,
        upkeepAddress,
        gasLimit,
        msg.sender,
        uint8(triggerType),
        checkData,
        triggerConfig,
        offchainConfig,
        amountInJuels,
        msg.sender
      );
    } else {
      revert("Unsupported KeeperRegistrar typeAndVersion");
    }

    vm.recordLogs();
    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, additionalData);
    Vm.Log[] memory logEntries = vm.getRecordedLogs();

    return logEntries[2].topics[1];
  }

  /**
   * @notice registerUpkeep_logTrigger function to register upkeep with Log Trigger
   * @param amountInJuels quantity of LINK upkeep is funded with (specified in Juels)
   * @param upkeepName string of the upkeep to be registered
   * @param upkeepAddress address to perform upkeep on
   * @param gasLimit amount of gas to provide the target contract when performing upkeep
   * @param checkData data passed to the contract when checking for upkeep
   * @param triggerConfig the config for the trigger
   */
  function registerUpkeep_logTrigger(
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData,
    bytes memory triggerConfig
  ) nestedScriptContext public returns (bytes32 requestHash) {
    require(Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_1), "This function is only supported for KeeperRegistrar2_1");

    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    AutomationRegistrar2_1Interface keeperRegistrar = AutomationRegistrar2_1Interface(keeperRegistrarAddress);

    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.LOG;

    // Encrypt email
    bytes memory encryptedEmail = bytes(email);
    // Reference: https://docs.chain.link/chainlink-automation/guides/register-upkeep-in-contract
    bytes memory offchainConfig = EMPTY_BYTES; // Leave as 0x, placeholder parameter for future use.

    bytes4 registerSelector = keeperRegistrar.register.selector;

    bytes memory additionalData = abi.encodeWithSelector(
      registerSelector,
      upkeepName,
      encryptedEmail,
      upkeepAddress,
      gasLimit,
      msg.sender,
      uint8(triggerType),
      checkData,
      triggerConfig,
      offchainConfig,
      amountInJuels,
      msg.sender
    );

    vm.recordLogs();
    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, additionalData);
    Vm.Log[] memory logEntries = vm.getRecordedLogs();

    return logEntries[2].topics[0];
  }

  /**
   * @notice registerUpkeep_timeBased function to register upkeep with Time Based Trigger
   * @param amountInJuels quantity of LINK upkeep is funded with (specified in Juels)
   * @param upkeepName string of the upkeep to be registered
   * @param upkeepAddress address to perform upkeep on
   * @param gasLimit amount of gas to provide the target contract when performing upkeep
   * @param checkData data passed to the contract when checking for upkeep
   * @param cronUpkeepFactoryAddress address of the upkeep cron factory contract
   * @param upkeepFunctionSelector function signature on the target contract to call
   * @param cronString cron string to convert and encode
   */
  function registerUpkeep_timeBased(
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData,
    address cronUpkeepFactoryAddress,
    bytes4 upkeepFunctionSelector,
    string calldata cronString
  ) nestedScriptContext public returns (bytes32 requestHash) {
    require(Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_1), "This function is only supported for KeeperRegistrar2_1");

    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    AutomationRegistrar2_1Interface keeperRegistrar = AutomationRegistrar2_1Interface(keeperRegistrarAddress);

    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.CONDITION;

    // Encrypt email
    bytes memory encryptedEmail = bytes(email);
    // Reference: https://docs.chain.link/chainlink-automation/guides/register-upkeep-in-contract
    bytes memory offchainConfig = EMPTY_BYTES; // Leave as 0x, placeholder parameter for future use.
    bytes memory triggerConfig = EMPTY_BYTES;

    bytes4 registerSelector = keeperRegistrar.register.selector;

    CronUpkeepFactoryInterface cronUpkeepFactory = CronUpkeepFactoryInterface(cronUpkeepFactoryAddress);

    bytes memory encodedJob = cronUpkeepFactory.encodeCronJob(upkeepAddress, abi.encodeWithSelector(upkeepFunctionSelector), cronString);

    // @dev: This is a workaround to get the address of the deployed CronUpkeep contract.
    Vm.Log[] memory logEntries;

    vm.recordLogs();
    cronUpkeepFactory.newCronUpkeepWithJob(encodedJob);
    logEntries = vm.getRecordedLogs();
    address cronUpkeepAddress = logEntries[0].emitter;

    bytes memory additionalData = abi.encodeWithSelector(
      registerSelector,
      upkeepName,
      encryptedEmail,
      cronUpkeepAddress,
      gasLimit,
      msg.sender,
      uint8(triggerType),
      checkData,
      triggerConfig,
      offchainConfig,
      amountInJuels,
      msg.sender
    );

    vm.recordLogs();
    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, additionalData);
    logEntries = vm.getRecordedLogs();

    return logEntries[2].topics[0];
  }

  function getPendingRequest(
    bytes32 requestHash
  ) external view returns(address admin, uint96 balance) {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    return keeperRegistrar.getPendingRequest(requestHash);
  }

  function cancelRequest(
    bytes32 requestHash
  ) nestedScriptContext external {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    keeperRegistrar.cancel(requestHash);
  }

  function getRegistrationConfig() external view returns (
    AutomationUtils.AutoApproveType autoApproveType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_1)) {
      revert("'triggerType' must be provided for this typeAndVersion of the KeeperRegistrar");
    }

    if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar1_2)) {
      KeeperRegistrar1_2Interface keeperRegistrar = KeeperRegistrar1_2Interface(keeperRegistrarAddress);
      return keeperRegistrar.getRegistrationConfig();
    } else if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_0)) {
      KeeperRegistrar2_0Interface keeperRegistrar = KeeperRegistrar2_0Interface(keeperRegistrarAddress);
      return keeperRegistrar.getRegistrationConfig();
    } else {
      revert("Unsupported KeeperRegistrar typeAndVersion");
    }
  }

  function getRegistrationConfig(
    AutomationUtils.Trigger triggerType
  ) external view returns (
    AutomationUtils.AutoApproveType autoApproveType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    if (Utils.compareStrings(keeperRegistrarTypeAndVersion, TypesAndVersions.KeeperRegistrar2_1)) {
      AutomationRegistrar2_1Interface keeperRegistrar = AutomationRegistrar2_1Interface(keeperRegistrarAddress);
      TriggerRegistrationStorage memory triggerRegistrationStorage = keeperRegistrar.getTriggerRegistrationDetails(uint8(triggerType));
      (keeperRegistry, minLINKJuels) = keeperRegistrar.getConfig();
      return (
        triggerRegistrationStorage.autoApproveType,
        triggerRegistrationStorage.autoApproveMaxAllowed,
        triggerRegistrationStorage.approvedCount,
        keeperRegistry,
        minLINKJuels
      );
    } else {
      return this.getRegistrationConfig();
    }
  }

  /// @notice Keeper Registry functions

  function addFunds(
    uint256 upkeepId,
    uint96 amountInJuels
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.addFunds(upkeepId, amountInJuels);
  }

  function pauseUpkeep(
    uint256 upkeepId
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.pauseUpkeep(upkeepId);
  }

  function unpauseUpkeep(
    uint256 upkeepId
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.unpauseUpkeep(upkeepId);
  }

  function cancelUpkeep(
    uint256 upkeepId
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.cancelUpkeep(upkeepId);
  }

  function setUpkeepGasLimit(
    uint256 upkeepId,
    uint32 gasLimit
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.setUpkeepGasLimit(upkeepId, gasLimit);
  }

  function getMinBalanceForUpkeep(
    uint256 upkeepId
  ) external view returns (uint96 minBalance) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getMinBalanceForUpkeep(upkeepId);
  }

  function getState() external view returns (RegistryState memory registryState) {
    CombinedState memory combinedState;
    CombinedConfig memory combinedConfig;

    if (AutomationGenerations.isV1_0(keeperRegistryTypeAndVersion)) {
      (StateV1_0 memory state, ConfigV1_0 memory config, address[] memory keepers) = KeeperRegistry1_3Interface(keeperRegistryAddress).getState();
      combinedState = CombinedState(
        state.nonce,
        state.ownerLinkBalance,
        state.expectedLinkBalance,
        state.numUpkeeps,
        0,
        0,
        0,
        0,
        0,
        false
      );
      address[] memory registrars = new address[](1);
      registrars[0] = config.registrar;
      combinedConfig = CombinedConfig(
        config.paymentPremiumPPB,
        config.flatFeeMicroLink,
        config.checkGasLimit,
        config.stalenessSeconds,
        config.gasCeilingMultiplier,
        config.minUpkeepSpend,
        config.maxPerformGas,
        0,
        0,
        0,
        config.fallbackGasPrice,
        config.fallbackLinkPrice,
        config.transcoder,
        registrars,
        address(0),
        config.blockCountPerTurn
      );
      registryState.signers = keepers;
      registryState.transmitters = keepers;
      registryState.f = 0;
    } else if (AutomationGenerations.isV2_0(keeperRegistryTypeAndVersion)) {
      (StateV2_0 memory state, ConfigV2_0 memory config, address[] memory signers, address[] memory transmitters, uint8 f) = KeeperRegistry2_0Interface(keeperRegistryAddress).getState();
      combinedState = CombinedState(
        state.nonce,
        state.ownerLinkBalance,
        state.expectedLinkBalance,
        state.numUpkeeps,
        state.totalPremium,
        state.configCount,
        state.latestConfigBlockNumber,
        state.latestConfigDigest,
        state.latestEpoch,
        state.paused
      );
      address[] memory registrars = new address[](1);
      registrars[0] = config.registrar;
      combinedConfig = CombinedConfig(
        config.paymentPremiumPPB,
        config.flatFeeMicroLink,
        config.checkGasLimit,
        config.stalenessSeconds,
        config.gasCeilingMultiplier,
        config.minUpkeepSpend,
        config.maxPerformGas,
        config.maxCheckDataSize,
        config.maxPerformDataSize,
        0,
        config.fallbackGasPrice,
        config.fallbackLinkPrice,
        config.transcoder,
        registrars,
        address(0),
        0
      );
      registryState.signers = signers;
      registryState.transmitters = transmitters;
      registryState.f = f;
    }  else if (AutomationGenerations.isV2_1(keeperRegistryTypeAndVersion)) {
      (StateV2_1 memory state, ConfigV2_1 memory config, address[] memory signers, address[] memory transmitters, uint8 f) = KeeperRegistry2_1Interface(keeperRegistryAddress).getState();
      combinedState = CombinedState(
        state.nonce,
        state.ownerLinkBalance,
        state.expectedLinkBalance,
        state.numUpkeeps,
        state.totalPremium,
        state.configCount,
        state.latestConfigBlockNumber,
        state.latestConfigDigest,
        state.latestEpoch,
        state.paused
      );
      combinedConfig = CombinedConfig(
        config.paymentPremiumPPB,
        config.flatFeeMicroLink,
        config.checkGasLimit,
        config.stalenessSeconds,
        config.gasCeilingMultiplier,
        config.minUpkeepSpend,
        config.maxPerformGas,
        config.maxCheckDataSize,
        config.maxPerformDataSize,
        config.maxRevertDataSize,
        config.fallbackGasPrice,
        config.fallbackLinkPrice,
        config.transcoder,
        config.registrars,
        config.upkeepPrivilegeManager,
        0
      );
      registryState.signers = signers;
      registryState.transmitters = transmitters;
      registryState.f = f;
    } else {
      revert("Unsupported KeeperRegistry typeAndVersion");
    }

    registryState.combinedState = combinedState;
    registryState.combinedConfig = combinedConfig;

    return registryState;
  }

  function getUpkeepTranscoderVersion() external view returns(AutomationUtils.UpkeepFormat upkeepFormat) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.upkeepTranscoderVersion();
  }

  function getActiveUpkeepIDs(
    uint256 startIndex,
    uint256 maxCount
  ) external view returns (uint256[] memory upkeepIDs) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getActiveUpkeepIDs(startIndex, maxCount);
  }

  function getUpkeep(
    uint256 upkeepId
  ) external view returns (
    address target,
    uint32 executeGas,
    bytes memory checkData,
    uint96 balance,
    address admin,
    uint64 maxValidBlocknumber,
    uint96 amountSpent,
    bool paused
  ) {
    address lastKeeper;
    if (AutomationGenerations.isV1_0(keeperRegistryTypeAndVersion)) {
      (
        target,
        executeGas,
        checkData,
        balance,
        lastKeeper,
        admin,
        maxValidBlocknumber,
        amountSpent,
        paused
      ) = KeeperRegistry1_3Interface(keeperRegistryAddress).getUpkeep(upkeepId);
      return (
        target,
        executeGas,
        checkData,
        balance,
        admin,
        maxValidBlocknumber,
        amountSpent,
        paused
      );
    } else if (AutomationGenerations.isV2_0(keeperRegistryTypeAndVersion)) {
      UpkeepInfoV2_0 memory upkeepInfo = KeeperRegistry2_0Interface(keeperRegistryAddress).getUpkeep(upkeepId);
      return (
        upkeepInfo.target,
        upkeepInfo.executeGas,
        upkeepInfo.checkData,
        upkeepInfo.balance,
        upkeepInfo.admin,
        upkeepInfo.maxValidBlocknumber,
        upkeepInfo.amountSpent,
        upkeepInfo.paused
      );
    }  else if (AutomationGenerations.isV2_1(keeperRegistryTypeAndVersion)) {
      UpkeepInfoV2_1 memory upkeepInfo = KeeperRegistry2_1Interface(keeperRegistryAddress).getUpkeep(upkeepId);
      return (
        upkeepInfo.target,
        upkeepInfo.performGas,
        upkeepInfo.checkData,
        upkeepInfo.balance,
        upkeepInfo.admin,
        upkeepInfo.maxValidBlocknumber,
        upkeepInfo.amountSpent,
        upkeepInfo.paused
      );
    } else {
      revert("Unsupported KeeperRegistry typeAndVersion");
    }
  }

  function withdrawFunds(
    uint256 upkeepId,
    address receivingAddress
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.withdrawFunds(upkeepId, receivingAddress);
  }

  function transferUpkeepAdmin(
    uint256 upkeepId,
    address proposedAdmin
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.transferUpkeepAdmin(upkeepId, proposedAdmin);
  }

  function acceptUpkeepAdmin(
    uint256 upkeepId
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.acceptUpkeepAdmin(upkeepId);
  }
}
