// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/sandbox/OracleInterface.sol";

contract OracleScript is Script {
  function run() external view {
    console.log("Please run deploy(address,address) method.");
  }

  function deploy(address linkTokenAddress, address nodeAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address oracleAddress = deployCode("Oracle.sol:Oracle", abi.encode(linkTokenAddress));
    OracleInterface oracle = OracleInterface(oracleAddress);
    oracle.setFulfillmentPermission(nodeAddress, true);

    vm.stopBroadcast();

    return oracleAddress;
  }
}
