// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";

import "./BaseTest.t.sol";
import "script/functions/Functions.s.sol";
import "src/interfaces/functions/IFunctionsRouter.sol";
import "src/interfaces/functions/IFunctionsSubscriptions.sol";

contract FunctionsRouterScriptTest is BaseTest {
  event SubscriptionCreated(uint64 indexed subscriptionId, address owner);
  event SubscriptionFunded(uint64 indexed subscriptionId, uint256 oldBalance, uint256 newBalance);
  event SubscriptionConsumerAdded(uint64 indexed subscriptionId, address consumer);
  event SubscriptionConsumerRemoved(uint64 indexed subscriptionId, address consumer);
  event SubscriptionCanceled(uint64 indexed subscriptionId, address fundsRecipient, uint256 fundsAmount);
  event SubscriptionOwnerTransferRequested(uint64 indexed subscriptionId, address from, address to);
  event SubscriptionOwnerTransferred(uint64 indexed subscriptionId, address from, address to);

  FunctionsScript public functionsScript;
  address public functionsRouterAddress;
  address public linkTokenAddress;
  IFunctionsRouter.Config public simulatedRouterConfig;

  function setUp() public override {
    BaseTest.setUp();

    uint32[] memory maxCallbackGasLimits = new uint32[](3);
    maxCallbackGasLimits[0] = 300_000;
    maxCallbackGasLimits[1] = 500_000;
    maxCallbackGasLimits[2] = 1_000_000;

    simulatedRouterConfig = IFunctionsRouter.Config({
      maxConsumersPerSubscription: 100,
      adminFee: 0,
      handleOracleFulfillmentSelector: 0x0ca76175, //bytes4(keccak256("handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err)")),
      gasForCallExactCheck: 5000,
      maxCallbackGasLimits: maxCallbackGasLimits,
      subscriptionDepositMinimumRequests: 0,
      subscriptionDepositJuels: 0
    });

    vm.startBroadcast(OWNER_ADDRESS);
    linkTokenAddress = deployCode("LinkToken.sol:LinkToken");
    functionsRouterAddress = deployCode("FunctionsRouter.sol:FunctionsRouter", abi.encode(linkTokenAddress, simulatedRouterConfig));
    functionsScript = new FunctionsScript(functionsRouterAddress);
    vm.stopBroadcast();
  }

  function test_CreateSubscription_Success() public {
    vm.expectEmit(true, false, false, false);
    emit SubscriptionCreated(1, OWNER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscription();
    assertEq(subscriptionId, 1);
  }

  function test_CreateSubscriptionWithConsumer_Success() public {
    vm.expectEmit(true, false, false, false);
    emit SubscriptionCreated(1, OWNER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscriptionWithConsumer(STRANGER_ADDRESS);
    assertEq(subscriptionId, 1);
  }

  function test_CancelSubscription_Success() public {
    uint96 expectedRefund = 1 * JUELS_PER_LINK;
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscriptionWithConsumer(STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.fundSubscription(linkTokenAddress, expectedRefund, subscriptionId);
    vm.expectEmit(true, false, false, false);
    emit SubscriptionCanceled(subscriptionId, OWNER_ADDRESS, expectedRefund);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.cancelSubscription(subscriptionId, OWNER_ADDRESS);
  }

  function test_AddConsumer_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionConsumerAdded(subscriptionId, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.addConsumer(subscriptionId, STRANGER_ADDRESS);
  }

  function test_RemoveConsumer_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscription();
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.addConsumer(subscriptionId, STRANGER_ADDRESS);
    vm.expectEmit();
    emit SubscriptionConsumerRemoved(subscriptionId, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.removeConsumer(subscriptionId, STRANGER_ADDRESS);
  }

  function test_TransferOwnership_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionOwnerTransferRequested(subscriptionId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.proposeSubscriptionOwnerTransfer(subscriptionId, STRANGER_ADDRESS);
    vm.expectEmit();
    emit SubscriptionOwnerTransferred(subscriptionId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(STRANGER_ADDRESS);
    functionsScript.acceptSubscriptionOwnerTransfer(subscriptionId);
  }

  function test_FundSubscription_Success() public {
    uint96 funds = 1 * JUELS_PER_LINK;
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = functionsScript.createSubscriptionWithConsumer(STRANGER_ADDRESS);
    vm.expectEmit();
    emit SubscriptionFunded(subscriptionId, 0, funds);
    vm.broadcast(OWNER_ADDRESS);
    functionsScript.fundSubscription(linkTokenAddress, funds, subscriptionId);
    IFunctionsSubscriptions.Subscription memory subscription = functionsScript.getSubscriptionDetails(subscriptionId);
    assertEq(subscription.balance, funds);
  }
}
