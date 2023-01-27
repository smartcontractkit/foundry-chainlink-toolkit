// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ChainlinkConsumer.sol";

contract DeployChainlinkConsumer is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    ChainlinkConsumer chainlinkConsumer = new ChainlinkConsumer(tokenAddress);

    vm.stopBroadcast();
  }

  function requestEthereumPrice(address consumerAddress, address oracleAddress, string memory jobId) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    ChainlinkConsumer chainlinkConsumer = ChainlinkConsumer(consumerAddress);
    chainlinkConsumer.requestEthereumPrice(oracleAddress, jobId);

    vm.stopBroadcast();
  }

  function getEthereumPrice(address consumerAddress) external view returns(uint256) {
    ChainlinkConsumer chainlinkConsumer = ChainlinkConsumer(consumerAddress);
    return chainlinkConsumer.currentPrice();
  }
}
