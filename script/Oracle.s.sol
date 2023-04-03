// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "forge-std/Script.sol";
import "chainlink/v0.6/Oracle.sol";

contract OracleScript is Script {
  function run() external {
    console.log("Please run deploy(address,address) method.");
  }

  function deploy(address tokenAddress, address nodeAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    Oracle oracle = new Oracle(tokenAddress);
    oracle.setFulfillmentPermission(nodeAddress, true);

    vm.stopBroadcast();
  }
}
