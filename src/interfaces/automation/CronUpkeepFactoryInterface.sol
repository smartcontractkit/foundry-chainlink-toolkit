// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface CronUpkeepFactoryInterface {
  function newCronUpkeep() external;
  function newCronUpkeepWithJob(bytes memory encodedJob) external;
  function setMaxJobs(uint256 maxJobs) external;
  function cronDelegateAddress() external returns (address);
  function encodeCronString(string memory cronString) external pure returns (bytes memory);
  function encodeCronJob(
    address target,
    bytes memory handler,
    string memory cronString
  ) external returns (bytes memory);
}
