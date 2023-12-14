// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";

import "./BaseTest.t.sol";
import "script/feeds/DataFeed.s.sol";
import "script/feeds/ENSFeedsResolver.s.sol";
import "src/interfaces/feeds/AggregatorV2V3Interface.sol";
import "src/interfaces/test/MockV3AggregatorInterface.sol";

contract DataFeedsScriptTest is BaseTest {
  uint8 public DECIMALS = 18;
  int256 public INITIAL_ANSWER = 1_000;
  int256 public LATEST_ANSWER = 2_000;
  uint80 public LATEST_ROUND = 1;
  string public constant DESCRIPTION = "v0.6/tests/MockV3Aggregator.sol";
  uint256 public VERSION = 0;

  DataFeedsScript public dataFeedsScript;
  address public linkTokenAddress;
  address public dataFeedAddress;

  function setUp() public override {
    BaseTest.setUp();

    vm.startBroadcast(OWNER_ADDRESS);
    linkTokenAddress = deployCode("LinkToken.sol:LinkToken");
    dataFeedAddress = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS, INITIAL_ANSWER));
    dataFeedsScript = new DataFeedsScript(dataFeedAddress);
    vm.stopBroadcast();
  }

  function test_GetLatestRound_Success() public {
    MockV3AggregatorInterface dataFeed = MockV3AggregatorInterface(dataFeedAddress);
    uint256 timestamp = block.timestamp;
    vm.broadcast(OWNER_ADDRESS);
    dataFeed.updateRoundData(LATEST_ROUND, LATEST_ANSWER, timestamp, timestamp);

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = dataFeedsScript.getLatestRoundData();
    assertEq(roundId, LATEST_ROUND);
    assertEq(answer, LATEST_ANSWER);
    assertEq(startedAt, timestamp);
    assertEq(updatedAt, timestamp);
    assertEq(answeredInRound, LATEST_ROUND);
  }

  function test_GetRound_Success() public {
    MockV3AggregatorInterface dataFeed = MockV3AggregatorInterface(dataFeedAddress);
    uint256 timestamp = block.timestamp;
    vm.broadcast(OWNER_ADDRESS);
    dataFeed.updateRoundData(LATEST_ROUND, LATEST_ANSWER, timestamp, timestamp);

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = dataFeedsScript.getRoundData(LATEST_ROUND);
    assertEq(roundId, LATEST_ROUND);
    assertEq(answer, LATEST_ANSWER);
    assertEq(startedAt, timestamp);
    assertEq(updatedAt, timestamp);
    assertEq(answeredInRound, LATEST_ROUND);
  }

  function test_GetDescription_Success() public {
    string memory description = dataFeedsScript.getDescription();
    assertEq(description, DESCRIPTION);
  }

  function test_GetVersion_Success() public {
    uint256 version = dataFeedsScript.getVersion();
    assertEq(version, VERSION);
  }
}
