// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "forge-std/Script.sol";
import "../src/LinkToken.sol";

contract Transfer is Script {
  function run() external {
    console.log("Please run transferEth(uint256) or transferLink(uint256,address) method.");
  }

  function transferEth(address payable receiverAddress, uint256 amount) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    (bool sent, bytes memory data) = receiverAddress.call{value: amount}("");
    require(sent, "Failed to send Ether");

    vm.stopBroadcast();

    console.log(receiverAddress.balance);
  }

  function transferLink(address recipientAddress, address tokenAddress, uint256 amount) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    LinkToken linkToken = LinkToken(tokenAddress);
    linkToken.transfer(recipientAddress, amount);

    vm.stopBroadcast();


  }
}
