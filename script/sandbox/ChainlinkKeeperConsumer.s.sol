// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/sandbox/ChainlinkKeeperConsumerInterface.sol";

contract ChainlinkKeeperConsumerScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy() external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address chainlinkKeeperConsumer = deployCode("ChainlinkKeeperConsumer.sol:ChainlinkKeeperConsumer");

    vm.stopBroadcast();

    return address(chainlinkKeeperConsumer);
  }

  function getCounter(address chainlinkKeeperConsumerAddress) external view returns(uint256) {
    ChainlinkKeeperConsumerInterface chainlinkKeeperConsumer = ChainlinkKeeperConsumerInterface(chainlinkKeeperConsumerAddress);
    return chainlinkKeeperConsumer.counter();
  }
}
