// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract CronUpkeep {
  uint256 public calledTimes = 0;

  event CronUpkeepCalled(uint256 indexed calledTimes);

  function callUpkeep() public {
    calledTimes += 1;
    emit CronUpkeepCalled(calledTimes);
  }
}
