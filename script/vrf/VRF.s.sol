// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../helpers/BaseScript.s.sol";
import "src/interfaces/vrf/VRFCoordinatorV2Interface.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";

contract VRFScript is BaseScript {
  address public vrfCoordinatorAddress;

  constructor (address _vrfCoordinatorAddress) {
    vrfCoordinatorAddress = _vrfCoordinatorAddress;
  }

  /// @notice VRF Coordinator functions

  function getRequestConfig() external view returns(uint16, uint32, bytes32[] memory) {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    return vrfCoordinator.getRequestConfig();
  }

  function requestRandomWords(
    uint64 subscriptionId,
    bytes32 keyHash,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.requestRandomWords(keyHash, subscriptionId, minimumRequestConfirmations, callbackGasLimit, numWords);
    console.log("Requested random words for subscription ID:", subscriptionId);
  }

  function createSubscription() nestedScriptContext external returns(uint64) {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    uint64 subscriptionId = vrfCoordinator.createSubscription();
    console.log("Created subscription with ID:", subscriptionId);
    return subscriptionId;
  }

  function cancelSubscription(
    uint64 subscriptionId,
    address receivingAddress
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.cancelSubscription(subscriptionId, receivingAddress);
    console.log("Cancelled subscription with ID:", subscriptionId);
  }

  function getSubscription(
    uint64 subscriptionId
  ) external view returns(uint96 balance, uint64 reqCount, address owner, address[] memory consumers) {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    return vrfCoordinator.getSubscription(subscriptionId);
  }

  function requestSubscriptionOwnerTransfer(
    uint64 subscriptionId,
    address newOwner
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.requestSubscriptionOwnerTransfer(subscriptionId, newOwner);
    console.log("Requested subscription owner transfer for ID:", subscriptionId);
  }

  function acceptSubscriptionOwnerTransfer(
    uint64 subscriptionId
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.acceptSubscriptionOwnerTransfer(subscriptionId);
    console.log("Accepted subscription owner transfer for ID:", subscriptionId);
  }

  function addConsumer(
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.addConsumer(subscriptionId, consumer);
    console.log("Added consumer to subscription ID:", subscriptionId);
  }

  function removeConsumer(
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    vrfCoordinator.removeConsumer(subscriptionId, consumer);
    console.log("Removed consumer from subscription ID:", subscriptionId);
  }

  function isPendingRequestExists(
    uint64 subscriptionId
  ) external view returns(bool) {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    return vrfCoordinator.pendingRequestExists(subscriptionId);
  }

  function fundSubscription(
    address linkTokenAddress,
    uint256 juelsAmount,
    uint64 subscriptionId
  ) nestedScriptContext external {
    VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);

    require(juelsAmount > 0, "Juels funding amount must be greater than 0");

    // Ensure the subscription exists
    (,,address owner,) = vrfCoordinator.getSubscription(subscriptionId);
    require (owner != address(0), "Subscription not found");

    address signer = msg.sender; // The address executing the script
    require(linkToken.balanceOf(signer) >= juelsAmount, "Insufficient LINK balance");

    // Perform the transfer and call
    linkToken.transferAndCall(vrfCoordinatorAddress, juelsAmount, abi.encode(subscriptionId));
    console.log("Funded subscription with ID:", subscriptionId);
  }
}
