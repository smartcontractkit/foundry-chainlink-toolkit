// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "../src/mocks/MockAggregatorValidator.sol";
import "../src/FluxAggregator/FluxAggregator.sol";

contract FluxAggregatorScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    MockAggregatorValidator mockAggregatorValidator = new MockAggregatorValidator();
    FluxAggregator fluxAggregator = new FluxAggregator(tokenAddress, 2000000, 30, address(mockAggregatorValidator), 0, 1000000000000, 0, "Test Flux Aggregator");

    vm.stopBroadcast();

    return address(fluxAggregator);
  }

  function updateAvailableFunds(address fluxAggregatorAddress) external returns(uint128) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    FluxAggregator fluxAggregator = FluxAggregator(fluxAggregatorAddress);
    fluxAggregator.updateAvailableFunds();

    vm.stopBroadcast();

    return fluxAggregator.availableFunds();
  }

  function setOracles(address fluxAggregatorAddress, address[] calldata nodesArray) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address[] memory removed;

    FluxAggregator fluxAggregator = FluxAggregator(fluxAggregatorAddress);
    fluxAggregator.changeOracles(removed, nodesArray, nodesArray, 3, 3, 0);

    vm.stopBroadcast();
  }

  function getOracles(address fluxAggregatorAddress) external returns(address[] memory) {
    FluxAggregator fluxAggregator = FluxAggregator(fluxAggregatorAddress);
    address[] memory oracles = fluxAggregator.getOracles();
    return oracles;
  }

  function getLatestAnswer(address fluxAggregatorAddress) external returns (int256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    FluxAggregator fluxAggregator = FluxAggregator(fluxAggregatorAddress);
    int256 answer = fluxAggregator.latestAnswer();

    vm.stopBroadcast();

    return answer;
  }
}
