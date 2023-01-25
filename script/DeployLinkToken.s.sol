// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "forge-std/Script.sol";
import "../src/LinkToken.sol";

contract DeployLinkToken is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    LinkToken linkToken = new LinkToken();

    vm.stopBroadcast();
  }
}
