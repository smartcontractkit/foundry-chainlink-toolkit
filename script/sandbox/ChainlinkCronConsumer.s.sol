// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/sandbox/ChainlinkCronConsumerInterface.sol";

contract ChainlinkCronConsumerScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy() external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address chainlinkCronConsumer = deployCode("ChainlinkCronConsumer.sol:ChainlinkCronConsumer");

    vm.stopBroadcast();

    return address(chainlinkCronConsumer);
  }

  function getEthereumPrice(address consumerAddress) external view returns(uint256) {
    ChainlinkCronConsumerInterface chainlinkCronConsumer = ChainlinkCronConsumerInterface(consumerAddress);
    return chainlinkCronConsumer.currentPrice();
  }
}
