// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { ENSResolverInterface } from "../src/interfaces/ENSResolverInterface.sol";

contract ENSFeedResolverScript is Script {
  function run() external {}

  function resolveAggregatorAddress(
    address ensResolverAddress,
    string baseTick,
    string quoteTick
  ) external returns(address) {
    ENSResolverInterface ensResolver = ENSResolverInterface(ensResolverAddress);

    return ensResolver.addr(abi.encodePacked(baseTick, "-", quoteTick, ".data.eth"));
  }

  function resolveAggregatorAddressWithSubdomains(
    address ensResolverAddress,
    string baseTick,
    string quoteTick
  ) external returns(
    address proxyAggregatorAddress,
    address underlyingAggregatorAddress,
    address proposedAggregatorAddress
  ) {
    ENSResolverInterface ensResolver = ENSResolverInterface(ensResolverAddress);

    address proxyAggregatorAddress = ensResolver.addr(abi.encodePacked("proxy.", baseTick, "-", quoteTick, ".data.eth"));
    address underlyingAggregatorAddress = ensResolver.addr(abi.encodePacked("aggregator.", baseTick, "-", quoteTick, ".data.eth"));
    address proposedAggregatorAddress = ensResolver.addr(abi.encodePacked("proposed.", baseTick, "-", quoteTick, ".data.eth"));

    return (
      proxyAggregatorAddress,
      underlyingAggregatorAddress,
      proposedAggregatorAddress
    );
  }
}
