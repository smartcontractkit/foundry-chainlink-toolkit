// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/libraries/AutomationUtils.sol";
import "./KeeperRegistrarInterface.sol";

interface KeeperRegistrar2_0Interface is KeeperRegistrarInterface {
  function getRegistrationConfig() external view returns (
    AutomationUtils.AutoApproveType autoApproveConfigType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  );
  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    bytes calldata offchainConfig,
    uint96 amount,
    address sender
  ) external;

  // For test purpose only
  function setRegistrationConfig(
    AutomationUtils.AutoApproveType autoApproveConfigType,
    uint16 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minLINKJuels
  ) external;
}

