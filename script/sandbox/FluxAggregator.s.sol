// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/sandbox/FluxAggregatorInterface.sol";
import "src/mocks/MockAggregatorValidator.sol";

contract FluxAggregatorScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy(address linkTokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    MockAggregatorValidator mockAggregatorValidator = new MockAggregatorValidator();

    address fluxAggregator = deployCode("FluxAggregator.sol:FluxAggregator", abi.encode(
      linkTokenAddress,
      2000000, // uint128 paymentAmount
      30, // uint32 timeout,
      address(mockAggregatorValidator),
      0, // int256 minSubmissionValue
      1000000000000, // int256 maxSubmissionValue
      0, // uint8 decimals
      "Test Flux Aggregator"
    ));

    vm.stopBroadcast();

    return fluxAggregator;
  }

  function updateAvailableFunds(address fluxAggregatorAddress) external returns(uint128) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    FluxAggregatorInterface fluxAggregator = FluxAggregatorInterface(fluxAggregatorAddress);
    fluxAggregator.updateAvailableFunds();

    vm.stopBroadcast();

    return fluxAggregator.availableFunds();
  }

  function setOracles(address fluxAggregatorAddress, address[] memory nodesArray) public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    address[] memory removedOracles;
    uint32 minSubmissions = 3;
    uint32 maxSubmissions = 3;
    uint32 restartDelay = 0;

    vm.startBroadcast(deployerPrivateKey);

    FluxAggregatorInterface fluxAggregator = FluxAggregatorInterface(fluxAggregatorAddress);
    fluxAggregator.changeOracles(removedOracles, nodesArray, nodesArray, minSubmissions, maxSubmissions, restartDelay);

    vm.stopBroadcast();
  }

  function getOracles(address fluxAggregatorAddress) external view returns(address[] memory) {
    FluxAggregatorInterface fluxAggregator = FluxAggregatorInterface(fluxAggregatorAddress);
    address[] memory oracles = fluxAggregator.getOracles();
    return oracles;
  }

  function getLatestAnswer(address fluxAggregatorAddress) external returns (int256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    FluxAggregatorInterface fluxAggregator = FluxAggregatorInterface(fluxAggregatorAddress);
    int256 answer = fluxAggregator.latestAnswer();

    vm.stopBroadcast();

    return answer;
  }
}
