// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "src/interfaces/feeds/AggregatorV3Interface.sol";

contract MockEthFeed is AggregatorV3Interface {
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

  function decimals() external pure override returns (uint8) {
    return 18;
  }

  function description() external pure override returns (string memory) {
    return "mock LINK/ETH data feed";
  }

  function version() external pure override returns (uint256) {
    return 1;
  }

  function getRoundData(uint80)
  override
  external
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
  override
  external
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
