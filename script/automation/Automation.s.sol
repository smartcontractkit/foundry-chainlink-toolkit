// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { LinkTokenInterface } from "src/interfaces/LinkTokenInterface.sol";
import { KeeperRegistrarInterface } from "src/interfaces/KeeperRegistrarInterface.sol";
import { KeeperRegistryInterface, State, Config, UpkeepFormat } from "src/interfaces/KeeperRegistryInterface.sol";
import "src/libraries/TypesAndVersions.sol";
import "../helpers/BaseScript.s.sol";
import "../helpers/TypeAndVersion.s.sol";

contract AutomationScript is BaseScript, TypeAndVersionScript {
  // @notice Keeper Registrar functions

  /**
   * @notice registerUpkeep function for KeeperRegistry
   * @param keeperRegistrarAddress address of the KeeperRegistrar contract
   * @param linkTokenAddress address of the LINK token
   * @param amountInJuels quantity of LINK upkeep is funded with (specified in Juels)
   * @param upkeepName string of the upkeep to be registered
   * @param upkeepAddress address to perform upkeep on
   * @param gasLimit amount of gas to provide the target contract when performing upkeep
   * @param adminAddress address to cancel upkeep and withdraw remaining funds
   * @param checkData data passed to the contract when checking for upkeep
   */
  function registerUpkeep(
    address keeperRegistrarAddress,
    address linkTokenAddress,
    uint256 amountInJuels,
    string calldata upkeepName,
    address upkeepAddress,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData
  ) nestedScriptContext external {
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    KeeperRegistryInterface keeperRegistrar = KeeperRegistryInterface(keeperRegistrarAddress);

    bytes memory additionalData;
    bytes memory emptyBytes = new bytes(0);
    uint8 registrationSource = 0;

    // Reference: https://docs.chain.link/chainlink-automation/guides/register-upkeep-in-contract
    bytes calldata encryptedEmail = emptyBytes; // Can leave blank. If registering via UI it will encrypt email and store it.
    bytes calldata offchainConfig = emptyBytes; // Leave as 0x, placeholder parameter for future use.


    bytes4 registerSelector = keeperRegistrar.register.selector;

    string memory typeAndVersion = keeperRegistrar.typeAndVersion();
    if (typeAndVersion == TypesAndVersions.KeeperRegistrar1_1()) {
      additionalData = abi.encodeWithSelector(
        registerSelector,
        upkeepName,
        encryptedEmail,
        upkeepAddress,
        gasLimit,
        adminAddress,
        checkData,
        amountInJuels,
        registrationSource,
        msg.sender
      );
    } else if (typeAndVersion == TypesAndVersions.KeeperRegistrar2_0()) {
      additionalData = abi.encodeWithSelector(
        registerSelector,
        upkeepName,
        encryptedEmail,
        upkeepAddress,
        gasLimit,
        adminAddress,
        checkData,
        offchainConfig,
        amountInJuels,
        msg.sender
      );
    } else {
      revert("Unsupported KeeperRegistrar typeAndVersion");
    }

    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, additionalData);
  }

  function cancelRequest(
    address keeperRegistrarAddress,
    bytes32 requestHash
  ) nestedScriptContext external {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    keeperRegistrar.cancel(requestHash);
  }

  function getPendingRequest(
    address keeperRegistrarAddress,
    bytes32 requestHash
  ) external view returns (address adminAddress, uint256 balance) {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    (adminAddress, balance) = keeperRegistrar.getPendingRequest(requestHash);
  }

  function getRegistrationConfig(
    address keeperRegistrarAddress
  ) external view returns (
    KeeperRegistrarInterface.AutoApproveType autoApproveConfigType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    return keeperRegistrar.getRegistrationConfig();
  }

  // @notice Keeper Registry functions

  function fundUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId,
    uint96 amountInJuels
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.addFunds(upkeepId, amountInJuels);
  }

  function cancelUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.cancelUpkeep(upkeepId);
  }

  function withdrawFunds(
    address keeperRegistryAddress,
    uint256 upkeepId,
    address receivingAddress
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.withdrawFunds(upkeepId, receivingAddress);
  }

  function migrateUpkeeps(
    address keeperRegistryAddress,
    uint256[] calldata upkeepIds,
    address destination
  ) nestedScriptContext external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    keeperRegistry.migrateUpkeeps(upkeepIds, destination);
  }

  function getState(
    address keeperRegistryAddress
  ) external view returns (
    State memory state,
    Config memory config,
    address[] memory keepers
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getState();
  }

  function getActiveUpkeepIDs(
    address keeperRegistryAddress,
    uint256 startIndex,
    uint256 maxCount
  ) external view returns (uint256[] memory) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getActiveUpkeepIDs(startIndex, maxCount);
  }

  function getMaxPaymentForGas(
    address keeperRegistryAddress,
    uint256 gasLimit
  ) external view returns (uint96) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getMaxPaymentForGas(gasLimit);
  }

  function getUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) external view returns (
    address target,
    uint32 executeGas,
    bytes memory checkData,
    uint96 balance,
    address lastKeeper,
    address admin,
    uint64 maxValidBlocknumber,
    uint96 amountSpent,
    bool paused
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getUpkeep(upkeepId);
  }

  function getMinBalanceForUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) external view returns (
    uint96 minBalance
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getMinBalanceForUpkeep(upkeepId);
  }

  function getKeeperInfo(
    address keeperRegistryAddress,
    address keeperAddress
  ) external view returns (address payee, bool active, uint96 balance) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.getKeeperInfo(keeperAddress);
  }

  function getUpkeepTranscoderVersion(
    address keeperRegistryAddress
  ) external view returns(UpkeepFormat) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.upkeepTranscoderVersion();
  }

  function isPaused(
    address keeperRegistryAddress
  ) external view returns (
    bool paused
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(keeperRegistryAddress);
    return keeperRegistry.paused();
  }
}
