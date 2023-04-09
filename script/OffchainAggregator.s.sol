// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "../src/mocks/MockAccessController.sol";
import "../src/OffchainAggregator/AccessControllerInterface.sol";
import "../src/OffchainAggregator/LinkTokenInterface.sol";
import "../src/OffchainAggregator/OffchainAggregator.sol";

contract OffchainAggregatorScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    MockAccessController mockAccessController = new MockAccessController();
    AccessControllerInterface accessControllerInterface = AccessControllerInterface(address(mockAccessController));
    LinkTokenInterface linkTokenInterface = LinkTokenInterface(tokenAddress);
    OffchainAggregator offchainAggregator = new OffchainAggregator(
      3000,
      10,
      500,
      500,
      500,
      linkTokenInterface,
      1,
      50000000000000000,
      accessControllerInterface,
      accessControllerInterface,
      8,
      "Test OCR"
    );

    vm.stopBroadcast();
  }
}
