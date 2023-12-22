// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../helpers/BaseScript.s.sol";
import "src/interfaces/functions/IFunctionsRouter.sol";
import "src/interfaces/functions/IFunctionsBilling.sol";
import "src/interfaces/functions/IFunctionsSubscriptions.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";
import "src/interfaces/shared/AccessControllerInterface.sol";
import "src/libraries/Utils.sol";

contract FunctionsScript is BaseScript {
  address public functionsRouterAddress;

  /// @notice MODIFIERS
  modifier isAllowListed() {
    IFunctionsRouter functionsRouter = IFunctionsRouter(functionsRouterAddress);
    bytes32 allowListId = functionsRouter.getAllowListId();
    if (allowListId == bytes32(0)) {
      _;
      return;
    }
    address allowListAddress = functionsRouter.getContractById(allowListId); // Ensure the allow list exists
    if (allowListAddress != address(0)) {
      AccessControllerInterface allowList = AccessControllerInterface(allowListAddress);
      bytes memory checkData = new bytes(0);
      require(allowList.hasAccess(msg.sender, checkData), "Sender not authorized by Functions Router allow list");
    }
    _;
  }

  constructor (address _functionsRouterAddress) {
    functionsRouterAddress = _functionsRouterAddress;
  }

  /// @notice Functions Router functions

  function createSubscription() nestedScriptContext isAllowListed external returns(uint64 subscriptionId) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    subscriptionId = functionsRouter.createSubscription();
    console.log("Created subscription with ID:", subscriptionId);
    return subscriptionId;
  }

  function createSubscriptionWithConsumer(
    address consumerAddress
  ) nestedScriptContext isAllowListed external returns(uint64 subscriptionId) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    subscriptionId = functionsRouter.createSubscriptionWithConsumer(consumerAddress);
    console.log("Created subscription with consumer with ID:", subscriptionId);
    return subscriptionId;
  }

  function fundSubscription(
    address linkTokenAddress,
    uint256 amountInJuels,
    uint64 subscriptionId
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);

    require(amountInJuels > 0, "Juels funding amount must be greater than 0");

    // Ensure the subscription exists
    IFunctionsSubscriptions.Subscription memory subscription = functionsRouter.getSubscription(subscriptionId);
    require (subscription.owner != address(0), "Subscription not found");

    address signer = msg.sender; // The address executing the script
    require(linkToken.balanceOf(signer) >= amountInJuels, "Insufficient LINK balance");

    // Perform the transfer and call
    linkToken.transferAndCall(functionsRouterAddress, amountInJuels, abi.encode(subscriptionId));
    console.log("Funded subscription with ID:", subscriptionId);
  }

  function cancelSubscription(
    uint64 subscriptionId,
    address receivingAddress
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.cancelSubscription(subscriptionId, receivingAddress);
    console.log("Cancelled subscription with ID:", subscriptionId);
  }

  function getSubscriptionDetails(
    uint64 subscriptionId
  ) external view returns(IFunctionsSubscriptions.Subscription memory subscriptionDetails) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    return functionsRouter.getSubscription(subscriptionId);
  }

  function addConsumer(
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.addConsumer(subscriptionId, consumer);
    console.log("Added consumer to subscription ID:", subscriptionId);
  }

  function removeConsumer(
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.removeConsumer(subscriptionId, consumer);
    console.log("Removed consumer from subscription ID:", subscriptionId);
  }

  function proposeSubscriptionOwnerTransfer(
    uint64 subscriptionId,
    address newOwner
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.proposeSubscriptionOwnerTransfer(subscriptionId, newOwner);
    console.log("Proposed subscription owner transfer for ID:", subscriptionId);
  }

  function acceptSubscriptionOwnerTransfer(
    uint64 subscriptionId
  ) nestedScriptContext isAllowListed external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.acceptSubscriptionOwnerTransfer(subscriptionId);
    console.log("Accepted subscription owner transfer for ID:", subscriptionId);
  }

  function timeoutRequests(
    FunctionsResponse.Commitment[] memory commitments
  ) nestedScriptContext isAllowListed external {
    require(commitments.length > 0, "Must provide at least one request commitment");
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.timeoutRequests(commitments);
    console.log("Timed out requests");
  }

  function estimateRequestCost(
    string memory donId,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    uint256 gasPriceWei
  ) nestedScriptContext isAllowListed external returns(uint96 estimatedCost) {
    require(gasPriceWei > 0, "Gas price must be greater than 0");
    require(callbackGasLimit > 0, "Callback gas limit must be greater than 0");

    IFunctionsRouter functionsRouter = IFunctionsRouter(functionsRouterAddress);
    bytes32 donIdBytes32 = Utils.stringToBytes32(donId);

    address functionsCoordinatorAddress = functionsRouter.getContractById(donIdBytes32);
    require(functionsCoordinatorAddress != address(0), "Functions Coordinator not found");

    IFunctionsBilling functionsCoordinator = IFunctionsBilling(functionsCoordinatorAddress);

    bytes memory requestData = new bytes(0);
    estimatedCost = functionsCoordinator.estimateCost(
      subscriptionId,
      requestData,
      callbackGasLimit,
      gasPriceWei
    );
    console.log("Estimated request cost:", estimatedCost);
    return estimatedCost;
  }
}
