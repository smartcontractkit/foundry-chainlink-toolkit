// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../src/interfaces/FunctionsRouterInterface.sol";

contract FunctionsRouterScript is Script {
  FunctionsRouterInterface public functionsRouter;

  constructor(address _functionsRouterAddress) {
    functionsRouter = FunctionsRouterInterface(_functionsRouterAddress);
  }

  function runCreateSubscription() public {
    uint64 subscriptionId = functionsRouter.createSubscription();
    // Additional logic after creating the subscription can be added here
    console.log("Created subscription with ID:", subscriptionId);
  }

  function runCreateSubscriptionWithConsumer(address consumer) public {
    uint64 subscriptionId = functionsRouter.createSubscriptionWithConsumer(consumer);
    // Additional logic can be added here
    console.log("Created subscription with consumer with ID:", subscriptionId);
  }

  function runProposeSubscriptionOwnerTransfer(uint64 subscriptionId, address newOwner) public {
    functionsRouter.proposeSubscriptionOwnerTransfer(subscriptionId, newOwner);
    console.log("Proposed subscription owner transfer for ID:", subscriptionId);
  }

  function runAcceptSubscriptionOwnerTransfer(uint64 subscriptionId) public {
    functionsRouter.acceptSubscriptionOwnerTransfer(subscriptionId);
    console.log("Accepted subscription owner transfer for ID:", subscriptionId);
  }

  function runRemoveConsumer(uint64 subscriptionId, address consumer) public {
    functionsRouter.removeConsumer(subscriptionId, consumer);
    console.log("Removed consumer from subscription ID:", subscriptionId);
  }

  function runAddConsumer(uint64 subscriptionId, address consumer) public {
    functionsRouter.addConsumer(subscriptionId, consumer);
    console.log("Added consumer to subscription ID:", subscriptionId);
  }
}
