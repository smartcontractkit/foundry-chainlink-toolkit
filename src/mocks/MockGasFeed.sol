// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../interfaces/AggregatorV3Interface.sol";

contract MockGasFeed is AggregatorV3Interface {
  uint80 roundId;
  int256 answer;
  uint256 startedAt;
  uint256 updatedAt;
  uint80 answeredInRound;

  constructor () public {
    roundId = 0;
    answer = 0;
    startedAt = block.timestamp;
    updatedAt = block.timestamp;
    answeredInRound = 0;
  }

  function decimals() external override view returns (uint8) {
    return 18;
  }

  function description() external override view returns (string memory) {
    return "mock fast Gas data feed";
  }

  function version() external override view returns (uint256) {
    return 1;
  }

  function getRoundData(uint80)
  external
  override
  view
  returns (
    uint80,
    int256,
    uint256,
    uint256,
    uint80
  ) {
    return (
      roundId,
      answer,
      block.timestamp,
      block.timestamp,
      answeredInRound
    );
  }

  function latestRoundData()
  external
  override
  view
  returns (
    uint80,
    int256,
    uint256,
    uint256,
    uint80
  ) {
    return (
      roundId,
      answer,
      block.timestamp,
      block.timestamp,
      answeredInRound
    );
  }
}
