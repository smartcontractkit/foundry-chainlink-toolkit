// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { AggregatorV2V3Interface } from "src/interfaces/feeds/AggregatorV2V3Interface.sol";
import "../helpers/BaseScript.s.sol";

contract DataFeedsScript is BaseScript {
  address public dataFeedAddress;

  constructor (address _dataFeedAddress) {
    dataFeedAddress = _dataFeedAddress;
  }

  function getLatestRoundData() external view returns(
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.latestRoundData();
  }

  function getRoundData(
    uint80 _roundId
  ) external view returns(
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.getRoundData(_roundId);
  }

  function getDecimals() external view returns(uint8 decimals) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.decimals();
  }

  function getDescription() external view returns(string memory description) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.description();
  }

  function getVersion() external view returns(uint256 version) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.version();
  }
}
