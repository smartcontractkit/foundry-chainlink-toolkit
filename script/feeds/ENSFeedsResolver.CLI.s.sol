// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./ENSFeedsResolver.s.sol";
import "../helpers/BaseScript.s.sol";

contract ENSFeedsResolverCLIScript is BaseScript {
  function resolveAggregatorAddress(
    address ensResolverAddress,
    string memory baseTick,
    string memory quoteTick
  ) external returns(address aggregatorAddress) {
    ENSFeedsResolverScript ensFeedsResolverScript = ENSFeedsResolverScript(ensResolverAddress);
    return ensFeedsResolverScript.resolveAggregatorAddress(baseTick, quoteTick);
  }

  function resolveAggregatorAddressWithSubdomains(
    address ensResolverAddress,
    string memory baseTick,
    string memory quoteTick
  ) external returns(
    address proxyAggregatorAddress,
    address underlyingAggregatorAddress,
    address proposedAggregatorAddress
  ) {
    ENSFeedsResolverScript ensFeedsResolverScript = ENSFeedsResolverScript(ensResolverAddress);
    return ensFeedsResolverScript.resolveAggregatorAddressWithSubdomains(baseTick, quoteTick);
  }
}
