// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./DataFeed.s.sol";
import "../helpers/BaseScript.s.sol";

contract DataFeedsCLIScript is BaseScript {
  function getLatestRoundData(
    address dataFeedAddress
  ) external view returns(
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    DataFeedsScript dataFeedScript = DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getLatestRoundData();
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
    DataFeedsScript dataFeedScript = DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getRoundData(_roundId);
  }

  function getDecimals(
    address dataFeedAddress
  ) external view returns(uint8) {
    DataFeedsScript dataFeedScript = DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getDecimals();
  }

  function getDescription(
    address dataFeedAddress
  ) external view returns(string memory) {
    DataFeedsScript dataFeedScript = DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getDescription();
  }

  function getVersion(
    address dataFeedAddress
  ) external view returns(uint256) {
    DataFeedsScript dataFeedScript = DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getVersion();
  }
}
