// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ChainlinkKeeperConsumer.sol";

contract ChainlinkKeeperConsumerScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy() external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    ChainlinkKeeperConsumer chainlinkKeeperConsumer = new ChainlinkKeeperConsumer();

    vm.stopBroadcast();

    return address(chainlinkKeeperConsumer);
  }

  function getCounter(address chainlinkKeeperConsumerAddress)
  external
  view
  returns(uint256) {
    ChainlinkKeeperConsumer chainlinkKeeperConsumer = ChainlinkKeeperConsumer(chainlinkKeeperConsumerAddress);
    return chainlinkKeeperConsumer.counter();
  }
}
