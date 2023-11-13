pragma solidity ^0.5.4;

import "../src/interfaces/FunctionsRouterInterface.sol";

contract FunctionsTest {
  address public functionsRouterAddress;
  FunctionsRouterInterface public functionsRouter;

  constructor(address _functionsRouterAddress) public {
    functionsRouterAddress = _functionsRouterAddress;
    functionsRouter = FunctionsRouterInterface(_functionsRouterAddress);
  }

  function testCreateSubscription() public {
    uint64 subscriptionId = functionsRouter.createSubscription();
    // Additional logic after creating the subscription can be added here
    console.log("Created subscription with ID:", subscriptionId);
  }
}
