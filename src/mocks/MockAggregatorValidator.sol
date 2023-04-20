// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

contract MockAggregatorValidator {
  function validate(
    uint256,
    int256,
    uint256,
    int256
  ) external pure returns (bool) {
    return true;
  }
}
