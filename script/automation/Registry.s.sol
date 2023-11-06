// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { KeeperRegistryInterface, State, Config } from "../src/interfaces/KeeperRegistryInterface.sol";

contract KeeperRegistrarScript is Script {
  function run(string memory nodeId) public {}

  function getState() external view returns (
    address memory _keeperRegistryAddress,
    State memory state,
    Config memory config,
    address[] memory keepers
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getState();
  }

  function getActiveUpkeepIDs(
    address memory _keeperRegistryAddress,
    uint256 startIndex,
    uint256 maxCount
  ) external view returns (uint256[] memory) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getActiveUpkeepIDs(startIndex, maxCount);
  }

  function getMaxPaymentForGas(
    address memory _keeperRegistryAddress,
    uint256 gasLimit
  ) external view returns (uint256) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getMaxPaymentForGas(gasLimit);
  }

  function getUpkeep(
    address memory _keeperRegistryAddress,
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
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getUpkeep(upkeepId);
  }

  function getMinBalanceForUpkeep(
    address memory _keeperRegistryAddress,
    uint256 upkeepId
  ) external view returns (
    uint96 minBalance
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getMinBalanceForUpkeep(upkeepId);
  }

  function isPaused(
    address memory _keeperRegistryAddress
  ) external view returns (
    bool paused
  ) {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.paused();
  }

  function fundUpkeep(
    address memory _keeperRegistryAddress,
    uint256 upkeepId,
    uint96 amountInJuels
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.addFunds(upkeepId, amountInJuels);
  }

  function cancelUpkeep(
    address memory _keeperRegistryAddress,
    uint256 upkeepId
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.cancelUpkeep(upkeepId);
  }

  function withdrawFunds(
    address memory _keeperRegistryAddress,
    uint256 upkeepId,
    address receivingAddress
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.withdrawFunds(upkeepId, receivingAddress);
  }

  function migrateUpkeeps(
    address memory _keeperRegistryAddress,
    uint256[] calldata upkeepIds,
    address destination
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.migrateUpkeeps(upkeepIds, destination);
  }

  function getKeeperInfo(
    address memory _keeperRegistryAddress,
    address keeperAddress
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.getKeeperInfo(keeperAddress);
  }

  function getUpkeepTranscoderVersion(
    address memory _keeperRegistryAddress,
    address keeperAddress
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.upkeepTranscoderVersion(keeperAddress);
  }

  function getTypeAndVersion(
    address memory _keeperRegistryAddress
  ) external {
    KeeperRegistryInterface keeperRegistry = KeeperRegistryInterface(_keeperRegistryAddress);
    return keeperRegistry.typeAndVersion();
  }
}
