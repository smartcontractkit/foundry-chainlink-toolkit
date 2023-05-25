// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface ChainlinkKeeperConsumerInterface {
  function counter() external view returns (uint);
  function interval() external view returns (uint);
  function lastTimeStamp() external view returns (uint);
  function checkUpkeep(bytes calldata) external view returns (bool, bytes memory);
  function performUpkeep(bytes calldata) external;
}
