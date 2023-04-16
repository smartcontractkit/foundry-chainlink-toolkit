// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "../src/mocks/MockAccessController.sol";
import "../src/OffchainAggregator/AccessControllerInterface.sol";
import "../src/OffchainAggregator/LinkTokenInterface.sol";
import "../src/OffchainAggregator/OffchainAggregator.sol";

contract OffchainAggregatorScript is Script {
  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address tokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 deployerAddress = vm.envUint("DEPLOYER_ADDRESS");
    vm.startBroadcast(deployerPrivateKey);

    MockAccessController mockAccessController = new MockAccessController();
    AccessControllerInterface accessControllerInterface = AccessControllerInterface(address(mockAccessController));
    LinkTokenInterface linkTokenInterface = LinkTokenInterface(tokenAddress);
    OffchainAggregator offchainAggregator = new OffchainAggregator(
      3000,
      10,
      500,
      500,
      500,
      linkTokenInterface,
      1,
      50000000000000000,
      accessControllerInterface,
      accessControllerInterface,
      8,
      "Test OCR"
    );

    vm.stopBroadcast();

    return address(offchainAggregator);
  }

  function setPayees(address offchainAggregatorAddress, address[] memory nodesArray) external {
    address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
    address[] memory payees = new address[](4);
    payees[0] = deployerAddress;
    payees[1] = deployerAddress;
    payees[2] = deployerAddress;
    payees[3] = deployerAddress;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregator offchainAggregator = OffchainAggregator(offchainAggregatorAddress);
    offchainAggregator.setPayees(nodesArray, payees);

    vm.stopBroadcast();
  }

  function setConfig(
    address offchainAggregatorAddress,
    address[] calldata signers,
    address[] calldata transmitters,
    uint8 threshold,
    uint64 encodedConfigVersion,
    bytes calldata encoded
  ) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregator offchainAggregator = OffchainAggregator(offchainAggregatorAddress);
    offchainAggregator.setConfig(signers, transmitters, threshold, encodedConfigVersion, encoded);

    vm.stopBroadcast();
  }

  function requestNewRound(address offchainAggregatorAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregator offchainAggregator = OffchainAggregator(offchainAggregatorAddress);
    offchainAggregator.requestNewRound();

    vm.stopBroadcast();
  }

  function latestAnswer(address offchainAggregatorAddress) external returns (int256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregator offchainAggregator = OffchainAggregator(offchainAggregatorAddress);
    int256 answer = offchainAggregator.latestAnswer();

    vm.stopBroadcast();

    return answer;
  }
}
