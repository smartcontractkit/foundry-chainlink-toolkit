// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface KeeperRegistryInterface {
  function setKeepers(address[] calldata keepers, address[] calldata payees) external;
  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (uint256 id);
  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);
  function getUpkeep(uint256 id) external view returns (
    address target,
    uint32 executeGas,
    bytes memory checkData,
    uint96 balance,
    address lastKeeper,
    address admin,
    uint64 maxValidBlocknumber,
    uint96 amountSpent,
    bool paused
  );
}
