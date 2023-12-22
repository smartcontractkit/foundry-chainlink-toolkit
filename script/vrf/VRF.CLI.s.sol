// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./VRF.s.sol";
import "../helpers/BaseScript.s.sol";

contract VRFCLIScript is BaseScript {
  function getRequestConfig(
    address vrfCoordinatorAddress
  ) external returns(
    uint16 minimumRequestConfirmations,
    uint32 maxGasLimit,
    bytes32[] memory s_provingKeyHashes
  ) {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.getRequestConfig();
  }

  function requestRandomWords(
    address vrfCoordinatorAddress,
    uint64 subscriptionId,
    bytes32 keyHash,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) nestedScriptContext external {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.requestRandomWords(
      subscriptionId,
      keyHash,
      minimumRequestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function createSubscription(
    address vrfCoordinatorAddress
  ) nestedScriptContext external returns(uint64 subId) {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.createSubscription();
  }

  function cancelSubscription(
    address vrfCoordinatorAddress,
    uint64 subscriptionId,
    address receivingAddress
  ) nestedScriptContext external {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.cancelSubscription(subscriptionId, receivingAddress);
  }

  function getSubscriptionDetails(
    address vrfCoordinatorAddress,
    uint64 subscriptionId
  ) external returns(uint96 balance, uint64 reqCount, address owner, address[] memory consumers) {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.getSubscriptionDetails(subscriptionId);
  }

  function addConsumer(
    address vrfCoordinatorAddress,
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext external {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.addConsumer(subscriptionId, consumer);
  }

  function removeConsumer(
    address vrfCoordinatorAddress,
    uint64 subscriptionId,
    address consumer
  ) nestedScriptContext external {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.removeConsumer(subscriptionId, consumer);
  }

  function fundSubscription(
    address vrfCoordinatorAddress,
    uint256 juelsAmount,
    uint64 subscriptionId
  ) nestedScriptContext external {
    VRFScript vrfScript = new VRFScript(vrfCoordinatorAddress);
    return vrfScript.fundSubscription(juelsAmount, subscriptionId);
  }
}
