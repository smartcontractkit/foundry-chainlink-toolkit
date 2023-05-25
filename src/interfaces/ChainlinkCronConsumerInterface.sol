// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface ChainlinkCronConsumerInterface {
  function fulfillEthereumPrice(uint256 _price) external;
  function currentPrice() external view returns (uint256);
}
