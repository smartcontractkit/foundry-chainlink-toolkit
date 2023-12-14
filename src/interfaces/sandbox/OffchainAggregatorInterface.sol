// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface OffchainAggregatorInterface {
  function typeAndVersion() external pure returns (string memory);
  function setConfig(
    address[] memory _signers,
    address[] memory _transmitters,
    uint8 _threshold,
    uint64 _encodedConfigVersion,
    bytes calldata _encoded
  ) external;
  function setPayees(address[] memory _transmitters, address[] memory _payees) external;
  function latestConfigDetails() external view returns (uint32 configCount, uint32 blockNumber, bytes16 configDigest);
  function transmitters() external view returns(address[] memory);
  function requestNewRound() external returns (uint80);
  function latestTransmissionDetails() external view returns (
    bytes16 configDigest,
    uint32 epoch,
    uint8 round,
    int192 latestAnswer,
    uint64 latestTimestamp
  );
  function transmit(bytes calldata _report, bytes32[] calldata _rs, bytes32[] calldata _ss, bytes32 _rawVs) external;
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 _roundId) external view returns (int256);
  function getTimestamp(uint256 _roundId) external view returns (uint256);
  function description() external view returns (string memory);
  function getRoundData(uint80 _roundId) external view returns (
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  );
  function latestRoundData() external view returns (
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  );
}
