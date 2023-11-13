// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

interface FunctionsRouterInterface {
  function createSubscription() external returns (uint64 subscriptionId);
  function createSubscriptionWithConsumer(address consumer) external returns (uint64 subscriptionId);
  function proposeSubscriptionOwnerTransfer(uint64 subscriptionId, address newOwner) external;
  function acceptSubscriptionOwnerTransfer(uint64 subscriptionId) external;
  function removeConsumer(uint64 subscriptionId, address consumer) external;
  function addConsumer(uint64 subscriptionId, address consumer) external;
}
