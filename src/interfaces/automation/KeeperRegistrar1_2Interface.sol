// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/libraries/AutomationUtils.sol";
import "../shared/TypeAndVersionInterface.sol";

interface KeeperRegistrar1_2Interface is TypeAndVersionInterface {
  function approve(
    string calldata name,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    bytes32 hash
  ) external;

  function cancel(bytes32 hash) external;

  function setRegistrationConfig(
    AutomationUtils.AutoApproveType autoApproveConfigType,
    uint16 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minLINKJuels
  ) external;

  function setAutoApproveAllowedSender(address senderAddress, bool allowed) external;

  function getAutoApproveAllowedSender(address senderAddress) external view returns (bool);

  function getRegistrationConfig() external view returns (
    AutomationUtils.AutoApproveType autoApproveConfigType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  );

  function getPendingRequest(bytes32 hash) external view returns (address, uint96);

  function onTokenTransfer(
    address sender,
    uint256 amount,
    bytes calldata data
  ) external;

  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 amount,
    uint8 source,
    address sender
  ) external;

}

