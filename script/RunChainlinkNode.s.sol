// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract RunChainlinkNode is Script {
  function run() external {
    string[] memory inputs = new string[](3);
    string memory root = vm.projectRoot();
    inputs[0] = "bash";
    inputs[1] = string.concat(root, "/script/bash/runChainlinkNode.sh");
    inputs[2] = root;

    bytes memory res = vm.ffi(inputs);
    console.log("%s", string(res));
  }
}
