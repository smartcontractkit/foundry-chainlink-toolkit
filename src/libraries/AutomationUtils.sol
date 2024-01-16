// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

/// @title Library of common constants and enums for the KeeperRegistry and KeeperRegistrar contracts
library AutomationUtils {
  // @notice Shared enums for the KeeperRegistry contracts
  enum PaymentModel {
    DEFAULT,
    ARBITRUM,
    OPTIMISM
  }

  enum MigrationPermission {
    NONE,
    OUTGOING,
    INCOMING,
    BIDIRECTIONAL
  }

  enum UpkeepFormat {
    V1,
    V2,
    V3
  }

  // @notice Shared interface for the KeeperRegistrar contracts

  /**
   * DISABLED: No auto approvals, all new upkeeps should be approved manually.
   * ENABLED_SENDER_ALLOWLIST: Auto approvals for allowed senders subject to max allowed. Manual for rest.
   * ENABLED_ALL: Auto approvals for all new upkeeps subject to max allowed.
   */
  enum AutoApproveType {
    DISABLED,
    ENABLED_SENDER_ALLOWLIST,
    ENABLED_ALL
  }

  enum Trigger {
    CONDITION,
    LOG
  }

  struct LogTriggerConfig {
    address contractAddress;
    uint8 filterSelector; // denotes which topics apply to filter ex 000, 101, 111...only last 3 bits apply
    bytes32 topic0;
    bytes32 topic1;
    bytes32 topic2;
    bytes32 topic3;
  }

  /**
   * @notice returns a log trigger config
   */
  function getLogTriggerConfig(
    address addr,
    uint8 selector, // denotes which topics apply to filter ex 000, 101, 111...only last 3 bits apply
    bytes32 topic0,
    bytes32 topic1,
    bytes32 topic2,
    bytes32 topic3
  ) external pure returns (bytes memory logTrigger) {
    LogTriggerConfig memory cfg = LogTriggerConfig({
      contractAddress: addr,
      filterSelector: selector,
      topic0: topic0,
      topic1: topic1,
      topic2: topic2,
      topic3: topic3
    });
    return abi.encode(cfg);
  }
}
