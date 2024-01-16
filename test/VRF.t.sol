// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";

import "./BaseTest.t.sol";
import "script/vrf/VRF.s.sol";

contract FunctionsRouterScriptTest is BaseTest {
  event SubscriptionCreated(uint64 indexed subId, address owner);
  event SubscriptionFunded(uint64 indexed subId, uint256 oldBalance, uint256 newBalance);
  event SubscriptionConsumerAdded(uint64 indexed subId, address consumer);
  event SubscriptionConsumerRemoved(uint64 indexed subId, address consumer);
  event SubscriptionCanceled(uint64 indexed subId, address to, uint256 amount);
  event SubscriptionOwnerTransferRequested(uint64 indexed subId, address from, address to);
  event SubscriptionOwnerTransferred(uint64 indexed subId, address from, address to);

  uint8 public DECIMALS = 18;
  int256 public INITIAL_ANSWER = 1_000;

  VRFScript public vrfScript;
  address public vrfCoordinatorAddress;
  address public linkTokenAddress;

  function setUp() public override {
    BaseTest.setUp();

    vm.startBroadcast(OWNER_ADDRESS);
    linkTokenAddress = deployCode("LinkToken.sol:LinkToken");
    address blockhashStoreAddress = deployCode("BlockhashStore.sol:BlockhashStore");
    address dataFeedAddress = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS, INITIAL_ANSWER));
    vrfCoordinatorAddress = deployCode("VRFCoordinatorV2.sol:VRFCoordinatorV2", abi.encode(linkTokenAddress, dataFeedAddress, blockhashStoreAddress));
    vrfScript = new VRFScript(vrfCoordinatorAddress);
    vm.stopBroadcast();
  }

  function test_CreateSubscription_Success() public {
    vm.expectEmit(true, false, false, false);
    emit SubscriptionCreated(1, OWNER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    assertEq(subscriptionId, 1);
  }

  function test_CancelSubscription_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionCanceled(subscriptionId, OWNER_ADDRESS, 0);
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.cancelSubscription(subscriptionId, OWNER_ADDRESS);
  }

  function test_AddConsumer_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionConsumerAdded(subscriptionId, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.addConsumer(subscriptionId, STRANGER_ADDRESS);
  }

  function test_RemoveConsumer_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.addConsumer(subscriptionId, STRANGER_ADDRESS);
    vm.expectEmit();
    emit SubscriptionConsumerRemoved(subscriptionId, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.removeConsumer(subscriptionId, STRANGER_ADDRESS);
  }

  function test_TransferOwnership_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionOwnerTransferRequested(subscriptionId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.requestSubscriptionOwnerTransfer(subscriptionId, STRANGER_ADDRESS);
    vm.expectEmit();
    emit SubscriptionOwnerTransferred(subscriptionId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(STRANGER_ADDRESS);
    vrfScript.acceptSubscriptionOwnerTransfer(subscriptionId);
  }

  function test_FundSubscription_Success() public {
    uint96 funds = 1 * JUELS_PER_LINK;
    vm.broadcast(OWNER_ADDRESS);
    uint64 subscriptionId = vrfScript.createSubscription();
    vm.expectEmit();
    emit SubscriptionFunded(subscriptionId, 0, funds);
    vm.broadcast(OWNER_ADDRESS);
    vrfScript.fundSubscription(funds, subscriptionId);
    (uint96 balance,,,) = vrfScript.getSubscriptionDetails(subscriptionId);
    assertEq(balance, funds);
  }
}
