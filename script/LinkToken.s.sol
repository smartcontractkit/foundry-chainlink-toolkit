// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/LinkToken.sol";

contract LinkTokenScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    LinkToken linkToken = new LinkToken();

    vm.stopBroadcast();
  }

  function transferAndCall(address tokenAddress, address to, uint256 amount, uint256 upkeepId) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);

    LinkToken linkToken = LinkToken(tokenAddress);
    linkToken.transferAndCall(to, amount, abi.encode(upkeepId));

    vm.stopBroadcast();
  }
}
