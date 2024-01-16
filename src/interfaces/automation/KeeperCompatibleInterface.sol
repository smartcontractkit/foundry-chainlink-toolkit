// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface KeeperCompatibleInterface {
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);
  function performUpkeep(bytes calldata performData) external;
}
