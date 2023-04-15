// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MockAggregatorValidator {
  function validate(
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  ) external returns (bool) {
    return true;
  }
}
