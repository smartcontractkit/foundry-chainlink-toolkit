// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface KeeperRegistrarInterface {
  // Enum representing the auto approval types
  enum AutoApproveType {
    DISABLED,
    ENABLED_SENDER_ALLOWLIST,
    ENABLED_ALL
  }

  function register(
    string calldata name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 amount,
    uint8 source,
    address sender
  ) external;

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
    AutoApproveType autoApproveConfigType,
    uint16 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minLINKJuels
  ) external;

  function setAutoApproveAllowedSender(address senderAddress, bool allowed) external;

  function getAutoApproveAllowedSender(address senderAddress) external view returns (bool);

  function getRegistrationConfig() external view returns (
    AutoApproveType autoApproveConfigType,
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

  function typeAndVersion() external pure returns (string memory);
}

