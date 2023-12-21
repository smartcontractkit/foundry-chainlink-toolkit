// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@chainlink/contracts/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/v0.8/Chainlink.sol";
import "@chainlink/contracts/v0.8/shared/interfaces/LinkTokenInterface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract ChainlinkDirectRequestConsumer is ChainlinkClient, ConfirmedOwner {
  using Chainlink for Chainlink.Request;

  uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY; // 1 * 10**18
  uint256 public currentPrice;

  event RequestEthereumPriceFulfilled(bytes32 indexed requestId, uint256 indexed price);

  /**
   * @dev Check https://docs.chain.link/docs/link-token-contracts/ for LINK address for the right network
     */
  constructor(address linkTokenAddress) ConfirmedOwner(msg.sender) {
    setChainlinkToken(linkTokenAddress);
  }

  function requestEthereumPrice(address _oracle, string memory _jobId) public onlyOwner {
    Chainlink.Request memory req = buildChainlinkRequest(
      stringToBytes32(_jobId),
      address(this),
      this.fulfillEthereumPrice.selector
    );
    req.add('get', 'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd');
    req.add('path', 'ethereum,usd');
    req.addInt('times', 100);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function fulfillEthereumPrice(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
    emit RequestEthereumPriceFulfilled(_requestId, _price);
    currentPrice = _price;
  }

  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  ) public onlyOwner {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
    // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }
}
