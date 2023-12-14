// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

interface ENSResolverInterface {
  function addr(bytes32 node) external view returns (address);
}
