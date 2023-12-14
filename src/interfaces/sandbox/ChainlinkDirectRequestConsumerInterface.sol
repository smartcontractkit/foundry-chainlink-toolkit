// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface ChainlinkDirectRequestConsumerInterface {
  function requestEthereumPrice(address _oracle, string memory _jobId) external;
  function fulfillEthereumPrice(bytes32 _requestId, uint256 _price) external;
  function getChainlinkToken() external view returns (address);
  function withdrawLink() external;
  function cancelRequest(bytes32 _requestId, uint256 _payment, bytes4 _callbackFunctionId, uint256 _expiration) external;
  function currentPrice() external view returns (uint256);
}
