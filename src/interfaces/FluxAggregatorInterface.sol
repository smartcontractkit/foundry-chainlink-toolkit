// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface FluxAggregatorInterface {
  function changeOracles(
    address[] calldata _removed,
    address[] calldata _added,
    address[] calldata _addedAdmins,
    uint32 _minSubmissions,
    uint32 _maxSubmissions,
    uint32 _restartDelay
  ) external;
  function availableFunds() external view returns (uint128);
  function updateAvailableFunds() external;
  function getOracles() external view returns (address[] memory);
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 _roundId) external view returns (int256);
  function getTimestamp(uint256 _roundId) external view returns (uint256);
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
  function requestNewRound() external returns (uint80);
  function oracleRoundState(address _oracle, uint32 _queriedRoundId) external view returns (
    bool _eligibleToSubmit,
    uint32 _roundId,
    int256 _latestSubmission,
    uint64 _startedAt,
    uint64 _timeout,
    uint128 _availableFunds,
    uint8 _oracleCount,
    uint128 _paymentAmount
  );
  function setValidator(address _newValidator) external;
}
