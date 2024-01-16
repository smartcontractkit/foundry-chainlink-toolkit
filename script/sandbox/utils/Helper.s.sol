// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";

contract HelperScript is Script {
  function run() external view {
    console.log("Please run transferEth(uint256) or transferLink(uint256,address) method.");
  }

  function transferEth(address payable recipientAddress, uint256 amount) external returns(uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    (bool sent,) = recipientAddress.call{value: amount}("");
    require(sent, "Failed to send Ether");

    vm.stopBroadcast();

    return recipientAddress.balance;
  }

  function transferEth(address payable[] calldata recipientAddresses, uint256 amount) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    for (uint i = 0; i < recipientAddresses.length; i++) {
      address payable recipientAddress = recipientAddresses[i];
      (bool sent,) = recipientAddress.call{value: amount}("");
      require(sent, "Failed to send Ether");
    }

    vm.stopBroadcast();
  }

  function transferLink(address recipientAddress, address linkTokenAddress, uint256 amount) external returns(uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    linkToken.transfer(recipientAddress, amount);

    vm.stopBroadcast();

    return linkToken.balanceOf(recipientAddress);
  }

  function transferLink(address payable[] calldata recipientAddresses, address linkTokenAddress, uint256 amount) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    for (uint i = 0; i < recipientAddresses.length; i++) {
      address payable recipientAddress = recipientAddresses[i];
      linkToken.transfer(recipientAddress, amount);
    }

    vm.stopBroadcast();
  }

  function getEthBalance(address account) external view returns(uint256){
    return address(account).balance;
  }

  function getLinkBalance(address tokenAddress, address account) external view returns(uint256){
    LinkTokenInterface linkToken = LinkTokenInterface(tokenAddress);
    uint256 balance = linkToken.balanceOf(account);
    return balance;
  }

  function formatAddress(address a) external pure returns(address) {
    return a;
  }
}
