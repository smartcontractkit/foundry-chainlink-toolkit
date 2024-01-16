// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./DataFeed.s.sol";
import "../helpers/BaseScript.s.sol";

contract DataFeedsCLIScript is BaseScript {
  function getLatestRoundData(
    address dataFeedAddress
  ) external returns(
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getLatestRoundData();
  }

  function getRoundData(
    address dataFeedAddress,
    uint80 _roundId
  ) external returns(
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getRoundData(_roundId);
  }

  function getDecimals(
    address dataFeedAddress
  ) external returns(uint8) {
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getDecimals();
  }

  function getDescription(
    address dataFeedAddress
  ) external returns(string memory) {
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getDescription();
  }

  function getVersion(
    address dataFeedAddress
  ) external returns(uint256) {
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getVersion();
  }
}
