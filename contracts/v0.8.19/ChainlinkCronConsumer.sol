// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract ChainlinkCronConsumer {
  uint256 public currentPrice;

  event EthereumPriceFulfilled(uint256 indexed price);

  function fulfillEthereumPrice(uint256 _price) public {
    emit EthereumPriceFulfilled(_price);
    currentPrice = _price;
  }
}
