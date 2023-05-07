// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface ChainlinkConsumerInterface {
  function requestEthereumPrice(address _oracle, string memory _jobId) external;
  function currentPrice() external view returns (uint256);
}
