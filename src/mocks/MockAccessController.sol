// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

contract MockAccessController {
  function hasAccess(address, bytes calldata) external pure returns (bool) {
    return true;
  }
}
