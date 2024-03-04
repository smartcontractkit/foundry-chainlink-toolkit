// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./CCIPRouter.s.sol";
import "../helpers/BaseScript.s.sol";

contract CCIPRouterCLIScript is BaseScript {
  function getFee(
    address ccipRouterAddress,
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.getFee(destinationChainSelector, message);
  }

  function getSupportedTokens(
    address ccipRouterAddress,
    uint64 chainSelector
  ) external view returns (address[] memory) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.getSupportedTokens(chainSelector);
  }

  function isChainSupported(
    address ccipRouterAddress,
    uint64 chainSelector
  ) public view returns (bool) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.isChainSupported(chainSelector);
  }

  function getOnRamp(
    address ccipRouterAddress,
    uint64 destChainSelector
  ) external view returns (address) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.getOnRamp(destChainSelector);
  }

  function isOffRamp(
    address ccipRouterAddress,
    uint64 sourceChainSelector,
    address offRamp
  ) public view returns (bool) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.isOffRamp(sourceChainSelector, offRamp);
  }

  function getWrappedNative(address ccipRouterAddress) external view returns (address) {
    CCIPRouterScript ccipRouterScript = new CCIPRouterScript(ccipRouterAddress);
    return ccipRouterScript.getWrappedNative();
  }
}
