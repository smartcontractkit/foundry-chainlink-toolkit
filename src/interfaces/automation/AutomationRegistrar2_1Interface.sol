// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/libraries/AutomationUtils.sol";
import "./KeeperRegistrarInterface.sol";

struct InitialTriggerConfig {
  AutomationUtils.Trigger triggerType;
  AutomationUtils.AutoApproveType autoApproveType;
  uint32 autoApproveMaxAllowed;
}

struct TriggerRegistrationStorage {
  AutomationUtils.AutoApproveType autoApproveType;
  uint32 autoApproveMaxAllowed;
  uint32 approvedCount;
}

interface AutomationRegistrar2_1Interface is KeeperRegistrarInterface {
  function getConfig() external view returns (
    address keeperRegistry,
    uint256 minLINKJuels
  );
  function getTriggerRegistrationDetails(uint8 triggerType) external view returns (
    TriggerRegistrationStorage memory
  );
  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    uint8 triggerType,
    bytes memory checkData,
    bytes memory triggerConfig,
    bytes memory offchainConfig,
    uint96 amount,
    address sender
  ) external;

  // For test purpose only
  function setTriggerConfig(
    uint8 triggerType,
    AutomationUtils.AutoApproveType autoApproveType,
    uint32 autoApproveMaxAllowed
  ) external;
}

