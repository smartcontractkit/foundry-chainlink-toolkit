// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

contract MockAccessController {
  function hasAccess(address user, bytes calldata data) external view returns (bool) {
    return true;
  }
}
