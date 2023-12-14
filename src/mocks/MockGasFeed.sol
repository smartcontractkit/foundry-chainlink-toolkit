// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "src/interfaces/feeds/AggregatorV3Interface.sol";

contract MockGasFeed is AggregatorV3Interface {
  uint80 private roundId;
  int256 private answer;
  uint256 private startedAt;
  uint256 private updatedAt;
  uint80 private answeredInRound;

  constructor () public {
    roundId = 0;
    answer = 0;
    startedAt = block.timestamp;
    updatedAt = block.timestamp;
    answeredInRound = 0;
  }

  function decimals() external override pure returns (uint8) {
    return 18;
  }

  function description() external override pure returns (string memory) {
    return "mock fast Gas data feed";
  }

  function version() external override pure returns (uint256) {
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
