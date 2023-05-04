// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../src/interfaces/LinkTokenInterface.sol";

contract HelperScript is Script {
  function run() external view {
    console.log("Please run transferEth(uint256) or transferLink(uint256,address) method.");
  }

  function transferEth(address payable receiverAddress, uint256 amount) external returns(uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    (bool sent,) = receiverAddress.call{value: amount}("");
    require(sent, "Failed to send Ether");

    vm.stopBroadcast();

    return receiverAddress.balance;
  }

  function transferLink(address recipientAddress, address tokenAddress, uint256 amount) external returns(uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    LinkTokenInterface linkToken = LinkTokenInterface(tokenAddress);
    linkToken.transfer(recipientAddress, amount);

    vm.stopBroadcast();

    return linkToken.balanceOf(recipientAddress);
  }

  function formatAddress(address a) external pure returns(address) {
    return a;
  }
}
