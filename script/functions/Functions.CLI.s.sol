// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./Functions.s.sol";
import "../helpers/BaseScript.s.sol";

contract FunctionsCLIScript is BaseScript {
  function createSubscription(
    address functionsRouterAddress
  ) nestedScriptContext external returns(uint64 subId) {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.createSubscription();
  }

  function createSubscriptionWithConsumer(
    address functionsRouterAddress,
    address consumer
  ) nestedScriptContext external returns(uint64 subId) {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.createSubscriptionWithConsumer(consumer);
  }

  function cancelSubscription(
    address functionsRouterAddress,
    uint64 subId,
    address receivingAddress
  ) nestedScriptContext external {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.cancelSubscription(subId, receivingAddress);
  }

  function getSubscriptionDetails(
    address functionsRouterAddress,
    uint64 subId
  ) external returns(IFunctionsSubscriptions.Subscription memory) {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.getSubscriptionDetails(subId);
  }

  function addConsumer(
    address functionsRouterAddress,
    uint64 subId,
    address consumer
  ) nestedScriptContext external {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.addConsumer(subId, consumer);
  }

  function removeConsumer(
    address functionsRouterAddress,
    uint64 subId,
    address consumer
  ) nestedScriptContext external {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.removeConsumer(subId, consumer);
  }

  function fundSubscription(
    address functionsRouterAddress,
    address linkTokenAddress,
    uint256 juelsAmount,
    uint64 subId
  ) nestedScriptContext external {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.fundSubscription(linkTokenAddress, juelsAmount, subId);
  }

  function estimateRequestCost(
    address functionsRouterAddress,
    string memory donId,
    uint64 subId,
    uint32 callbackGasLimit,
    uint256 gasPriceWei
  ) nestedScriptContext external returns(uint96 estimatedCost) {
    FunctionsScript functionsScript = new FunctionsScript(functionsRouterAddress);
    return functionsScript.estimateRequestCost(donId, subId, callbackGasLimit, gasPriceWei);
  }
}
