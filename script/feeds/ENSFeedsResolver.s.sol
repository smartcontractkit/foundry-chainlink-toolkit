// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { ENSResolverInterface } from "src/interfaces/feeds/ENSResolverInterface.sol";
import "../helpers/BaseScript.s.sol";

contract ENSFeedsResolverScript is BaseScript {
  address public ensResolverAddress;

  constructor (address _ensResolverAddress) {
    ensResolverAddress = _ensResolverAddress;
  }

  function resolveAggregatorAddress(
    string memory baseTick,
    string memory quoteTick
  ) external view returns(address aggregatorAddress) {
    ENSResolverInterface ensResolver = ENSResolverInterface(ensResolverAddress);

    return ensResolver.addr(bytes32(abi.encodePacked(baseTick, "-", quoteTick, ".data.eth")));
  }

  function resolveAggregatorAddressWithSubdomains(
    string memory baseTick,
    string memory quoteTick
  ) external view returns(
    address proxyAggregatorAddress,
    address underlyingAggregatorAddress,
    address proposedAggregatorAddress
  ) {
    ENSResolverInterface ensResolver = ENSResolverInterface(ensResolverAddress);

    proxyAggregatorAddress = ensResolver.addr(bytes32(abi.encodePacked("proxy.", baseTick, "-", quoteTick, ".data.eth")));
    underlyingAggregatorAddress = ensResolver.addr(bytes32(abi.encodePacked("aggregator.", baseTick, "-", quoteTick, ".data.eth")));
    proposedAggregatorAddress = ensResolver.addr(bytes32(abi.encodePacked("proposed.", baseTick, "-", quoteTick, ".data.eth")));

    return (
      proxyAggregatorAddress,
      underlyingAggregatorAddress,
      proposedAggregatorAddress
    );
  }
}
