// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../helpers/BaseScript.s.sol";
import "../helpers/TypeAndVersion.s.sol";
import "src/interfaces/ccip/CCIPRouterInterface.sol";

contract CCIPRouterScript is BaseScript, TypeAndVersionScript {
  address public ccipRouterAddress;

  constructor (address _ccipRouterAddress) {
    ccipRouterAddress = _ccipRouterAddress;
  }

  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.getFee(destinationChainSelector, message);
  }

  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.getSupportedTokens(chainSelector);
  }

  function isChainSupported(uint64 chainSelector) public view returns (bool) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.isChainSupported(chainSelector);
  }

  function getOnRamp(uint64 destChainSelector) external view returns (address) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.getOnRamp(destChainSelector);
  }

  function isOffRamp(uint64 sourceChainSelector, address offRamp) public view returns (bool) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.isOffRamp(sourceChainSelector, offRamp);
  }

  function getWrappedNative() external view returns (address) {
    CCIPRouterInterface ccipRouter = CCIPRouterInterface(ccipRouterAddress);
    return ccipRouter.getWrappedNative();
  }
}
