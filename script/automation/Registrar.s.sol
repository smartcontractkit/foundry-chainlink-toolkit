// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { LinkTokenInterface } from "../src/interfaces/LinkTokenInterface.sol";
import { KeeperRegistrarInterface } from "../src/interfaces/KeeperRegistrarInterface.sol";
import { TypeAndVersionInterface } from "../src/interfaces/TypeAndVersionInterface.sol";

contract KeeperRegistrarScript is Script {

  function run() external {}

  function _registerUpkeep(
    address keeperRegistrarAddress,
    address linkTokenAddress,
    uint256 amountInJuels,
    string calldata upkeepName,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 source,
    address sender
  ) internal {
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);

    // Construct the data for transferAndCall
    bytes memory data = abi.encodeWithSelector(
      keeperRegistrar.register.selector,
      upkeepName,
      encryptedEmail,
      upkeepContract,
      gasLimit,
      adminAddress,
      checkData,
      source,
      sender
    );

    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, data);
    // Handle the response and events accordingly
  }

  function _registerUpkeep2_0(
    address keeperRegistrarAddress,
    address linkTokenAddress,
    uint256 amountInJuels,
    string calldata upkeepName,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 source,
    address sender
  ) internal {
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);

    // Construct the data for transferAndCall
    bytes memory data = abi.encodeWithSelector(
      keeperRegistrar.register.selector,
      upkeepName,
      encryptedEmail,
      upkeepContract,
      gasLimit,
      adminAddress,
      checkData,
      source,
      sender
    );

    linkToken.transferAndCall(keeperRegistrarAddress, amountInJuels, data);
    // Handle the response and events accordingly
  }

  function getPendingRequest(
    address keeperRegistrarAddress,
    bytes32 requestHash
  ) internal view returns (address adminAddress, uint256 balance) {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    (adminAddress, balance) = keeperRegistrar.getPendingRequest(requestHash);
  }

  function cancelRequest(
    address keeperRegistrarAddress,
    bytes32 requestHash
  ) internal {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    keeperRegistrar.cancel(requestHash);
  }

  function getRegistrationConfig(
    address keeperRegistrarAddress
  ) internal view returns (
    uint256 autoApproveConfigType,
    uint256 autoApproveMaxAllowed,
    uint256 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    KeeperRegistrarInterface keeperRegistrar = KeeperRegistrarInterface(keeperRegistrarAddress);
    (
      autoApproveConfigType,
      autoApproveMaxAllowed,
      approvedCount,
      keeperRegistry,
      minLINKJuels
    ) = keeperRegistrar.getRegistrationConfig();
  }

  function getTypeAndVersion(
    address keeperRegistrarAddress
  ) internal view returns (string memory typeAndVersion) {
    TypeAndVersionInterface typeAndVersionInterface = TypeAndVersionInterface(keeperRegistrarAddress);
    typeAndVersion = typeAndVersionInterface.typeAndVersion();
  }}
