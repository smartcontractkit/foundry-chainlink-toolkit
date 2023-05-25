// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../src/interfaces/ChainlinkConsumerInterface.sol";

contract ChainlinkConsumerScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address chainlinkConsumer = deployCode("ChainlinkConsumer.sol:ChainlinkConsumer", abi.encode(tokenAddress));

    vm.stopBroadcast();

    return chainlinkConsumer;
  }

  function requestEthereumPrice(address consumerAddress, address oracleAddress, string calldata jobId) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    ChainlinkConsumerInterface chainlinkConsumer = ChainlinkConsumerInterface(consumerAddress);
    chainlinkConsumer.requestEthereumPrice(oracleAddress, jobId);

    vm.stopBroadcast();
  }

  function getEthereumPrice(address consumerAddress) external view returns(uint256) {
    ChainlinkConsumerInterface chainlinkConsumer = ChainlinkConsumerInterface(consumerAddress);
    return chainlinkConsumer.currentPrice();
  }
}
