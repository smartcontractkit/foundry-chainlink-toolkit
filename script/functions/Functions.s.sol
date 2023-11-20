// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "src/interfaces/IFunctionsRouter.sol";
import "src/interfaces/IFunctionsBilling.sol";
import "src/interfaces/IFunctionsSubscriptions.sol";
import "src/interfaces/LinkTokenInterface.sol";
import "src/interfaces/AccessControllerInterface.sol";
import "src/libraries/Utils.sol";
import "../helpers/BaseScript.s.sol";
import "../helpers/Library.sol";

contract FunctionsScript is BaseScript {
  /// @notice MODIFIERS
  modifier isAllowListed(address functionsRouterAddress) {
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

  /// @notice WRAPPER FUNCTIONS
  function createSubscription(
    address functionsRouterAddress
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external returns(uint64) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    uint64 subscriptionId = functionsRouter.createSubscription();
    console.log("Created subscription with ID:", subscriptionId);
    return subscriptionId;
  }

  function createSubscriptionWithConsumer(
    address functionsRouterAddress,
    address consumer
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external returns(uint64) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    uint64 subscriptionId = functionsRouter.createSubscriptionWithConsumer(consumer);
    // Additional logic can be added here
    console.log("Created subscription with consumer with ID:", subscriptionId);
    return subscriptionId;
  }

  function cancelSubscription(
    address functionsRouterAddress,
    uint64 subscriptionId,
    address receivingAddress
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.cancelSubscription(subscriptionId, receivingAddress);
    console.log("Cancelled subscription with ID:", subscriptionId);
  }

  function getSubscription(
    address functionsRouterAddress,
    uint64 subscriptionId
  ) external view returns(IFunctionsSubscriptions.Subscription memory) {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    return functionsRouter.getSubscription(subscriptionId);
  }

  function proposeSubscriptionOwnerTransfer(
    address functionsRouterAddress,
    uint64 subscriptionId,
    address newOwner
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.proposeSubscriptionOwnerTransfer(subscriptionId, newOwner);
    console.log("Proposed subscription owner transfer for ID:", subscriptionId);
  }

  function acceptSubscriptionOwnerTransfer(
    address functionsRouterAddress,
    uint64 subscriptionId
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.acceptSubscriptionOwnerTransfer(subscriptionId);
    console.log("Accepted subscription owner transfer for ID:", subscriptionId);
  }

  function addConsumer(
    address functionsRouterAddress,
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.addConsumer(subscriptionId, consumer);
    console.log("Added consumer to subscription ID:", subscriptionId);
  }

  function removeConsumer(
    address functionsRouterAddress,
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.removeConsumer(subscriptionId, consumer);
    console.log("Removed consumer from subscription ID:", subscriptionId);
  }

  function timeoutRequests(
    address functionsRouterAddress,
    FunctionsResponse.Commitment[] memory commitments
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    require(commitments.length > 0, "Must provide at least one request commitment");
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    functionsRouter.timeoutRequests(commitments);
    console.log("Timed out requests");
  }

  /// @notice SYNTHETIC FUNCTIONS
  function fundSubscription(
    address functionsRouterAddress,
    address linkTokenAddress,
    uint256 juelsAmount,
    uint64 subscriptionId
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external {
    IFunctionsSubscriptions functionsRouter = IFunctionsSubscriptions(functionsRouterAddress);
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);

    require(juelsAmount > 0, "Juels funding amount must be greater than 0");

    // Ensure the subscription exists
    IFunctionsSubscriptions.Subscription memory subscription = functionsRouter.getSubscription(subscriptionId);
    require (subscription.owner != address(0), "Subscription not found");

    address signer = msg.sender; // The address executing the script
    require(linkToken.balanceOf(signer) >= juelsAmount, "Insufficient LINK balance");

    // Perform the transfer and call
    linkToken.transferAndCall(functionsRouterAddress, juelsAmount, abi.encode(subscriptionId));
    console.log("Funded subscription with ID:", subscriptionId);
  }

  function estimateRequestCost(
    address functionsRouterAddress,
    string memory donId,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    uint256 gasPriceWei
  ) nestedScriptContext isAllowListed(functionsRouterAddress) external returns(uint96) {
    require(gasPriceWei > 0, "Gas price must be greater than 0");
    require(callbackGasLimit > 0, "Callback gas limit must be greater than 0");

    IFunctionsRouter functionsRouter = IFunctionsRouter(functionsRouterAddress);
    bytes32 donIdBytes32 = Utils.stringToBytes32(donId);

    address functionsCoordinatorAddress = functionsRouter.getContractById(donIdBytes32);
    require(functionsCoordinatorAddress != address(0), "Functions Coordinator not found");

    IFunctionsBilling functionsCoordinator = IFunctionsBilling(functionsCoordinatorAddress);

    bytes memory requestData = new bytes(0);
    uint96 estimatedCost = functionsCoordinator.estimateCost(
      subscriptionId,
      requestData,
      callbackGasLimit,
      gasPriceWei
    );
    console.log("Estimated request cost:", estimatedCost);
    return estimatedCost;
  }
}
