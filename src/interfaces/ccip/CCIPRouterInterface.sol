// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "../shared/TypeAndVersionInterface.sol";
import "src/libraries/CCIPClient.sol";

interface CCIPRouterInterface is TypeAndVersionInterface {
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);
  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory);
  function isChainSupported(uint64 chainSelector) external view returns (bool);
  function getOnRamp(uint64 destChainSelector) external view returns (address);
  function isOffRamp(uint64 sourceChainSelector, address offRamp) external view returns (bool);
  function getWrappedNative() external view returns (address);
}
