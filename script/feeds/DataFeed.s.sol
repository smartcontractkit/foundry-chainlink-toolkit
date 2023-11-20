// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { AggregatorV2V3Interface } from "src/interfaces/AggregatorV2V3Interface.sol";
import "../helpers/BaseScript.s.sol";

contract DataFeedsScript is BaseScript {
  function getLatestRoundData(
    address dataFeedAddress
  ) external view returns(
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
    address dataFeedAddress,
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

  function getDecimals(
    address dataFeedAddress
  ) external view returns(uint8) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.decimals();
  }

  function getDescription(
    address dataFeedAddress
  ) external view returns(string memory) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.description();
  }

  function getVersion(
    address dataFeedAddress
  ) external view returns(uint256) {
    AggregatorV2V3Interface dataFeed = AggregatorV2V3Interface(dataFeedAddress);
    return dataFeed.version();
  }
}
