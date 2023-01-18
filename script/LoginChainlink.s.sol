// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract LoginChainlink is Script {
  function run() external {
    string memory chainlinkContainerName = vm.envString("CHAINLINK_CONTAINER_NAME");
    string[] memory inputs = new string[](3);
    string memory root = vm.projectRoot();
    inputs[0] = "bash";
    inputs[1] = string.concat(root, "/script/bash/loginChainlink.sh");
    inputs[2] = chainlinkContainerName;

    bytes memory res = vm.ffi(inputs);
    console.log("%s", string(res));
  }
}
