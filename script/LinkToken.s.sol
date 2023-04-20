// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../src/interfaces/LinkTokenInterface.sol";

contract LinkTokenScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy() external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address linkToken = deployCode("LinkToken.sol:LinkToken");

    vm.stopBroadcast();

    return linkToken;
  }

  function transferAndCall(address tokenAddress, address to, uint256 amount, uint256 upkeepId) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.broadcast(deployerPrivateKey);

    LinkTokenInterface linkToken = LinkTokenInterface(tokenAddress);
    linkToken.transferAndCall(to, amount, abi.encode(upkeepId));

    vm.stopBroadcast();
  }

  function getBalance(address tokenAddress, address account) external returns(uint256){
    LinkTokenInterface linkToken = LinkTokenInterface(tokenAddress);
    uint256 balance = linkToken.balanceOf(account);
    return balance;
  }
}
