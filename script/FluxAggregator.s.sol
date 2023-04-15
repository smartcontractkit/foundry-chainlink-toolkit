// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "../src/mocks/MockAggregatorValidator.sol";
import "../src/FluxAggregator/FluxAggregator.sol";

contract FluxAggregatorScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 deployerAddress = vm.envUint("DEPLOYER_ADDRESS");
    vm.startBroadcast(deployerPrivateKey);

    MockAggregatorValidator mockAggregatorValidator = new MockAggregatorValidator();
    FluxAggregator fluxAggregator = new FluxAggregator(tokenAddress, 1, 30, address(mockAggregatorValidator), 0, 1000000000000, 0, "Test Flux Aggregator");

    vm.stopBroadcast();
  }
}
