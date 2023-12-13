// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface MockV3AggregatorInterface {
  function updateAnswer(int256 answer) external;
  function updateRoundData(
    uint80 roundId,
    int256 answer,
    uint256 timestamp,
    uint256 startedAt
  ) external;
}
