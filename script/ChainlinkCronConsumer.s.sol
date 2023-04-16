// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ChainlinkCronConsumer.sol";

contract ChainlinkCronConsumerScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy() external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    ChainlinkCronConsumer chainlinkCronConsumer = new ChainlinkCronConsumer();

    vm.stopBroadcast();

    return address(chainlinkCronConsumer);
  }

  function getEthereumPrice(address consumerAddress)
  external
  view
  returns(uint256) {
    ChainlinkCronConsumer chainlinkCronConsumer = ChainlinkCronConsumer(consumerAddress);
    return chainlinkCronConsumer.currentPrice();
  }
}
