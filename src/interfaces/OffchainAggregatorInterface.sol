// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface OffchainAggregatorInterface {
  function setConfig(
    address[] calldata _signers,
    address[] calldata _transmitters,
    uint8 _threshold,
    uint64 _encodedConfigVersion,
    bytes calldata _encoded
  ) external;

  function setPayees(
    address[] calldata _transmitters,
    address[] calldata _payees
  ) external;

  function latestAnswer() external view returns (int256);

  function latestConfigDetails() external view returns (
    uint32 configCount,
    uint32 blockNumber,
    bytes16 configDigest
  );

  function requestNewRound() external returns (uint80);
}
