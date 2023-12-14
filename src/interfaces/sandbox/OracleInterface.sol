// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface OracleInterface {
  function oracleRequest(
    address _sender,
    uint256 _payment,
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionId,
    uint256 _nonce,
    uint256 _dataVersion,
    bytes calldata _data
  ) external;
  function fulfillOracleRequest(
    bytes32 _requestId,
    uint256 _payment,
    address _callbackAddress,
    bytes4 _callbackFunctionId,
    uint256 _expiration,
    bytes32 _data
  ) external;
  function getAuthorizationStatus(address _node) external view returns (bool);
  function setFulfillmentPermission(address _node, bool _allowed) external;
  function withdraw(address _recipient, uint256 _amount) external;
  function withdrawable() external view returns (uint256);
  function cancelOracleRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  ) external;
  function getChainlinkToken() external view returns (address);
}
