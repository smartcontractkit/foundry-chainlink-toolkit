// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/shared/AccessControllerInterface.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";
import "src/interfaces/sandbox/OffchainAggregatorInterface.sol";
import "src/mocks/MockAccessController.sol";

contract OffchainAggregatorScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy(address linkTokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    MockAccessController mockAccessController = new MockAccessController();
    AccessControllerInterface accessControllerInterface = AccessControllerInterface(address(mockAccessController));
    LinkTokenInterface linkTokenInterface = LinkTokenInterface(linkTokenAddress);

    address offchainAggregator = deployCode("OffchainAggregator.sol:OffchainAggregator", abi.encode(
      3000, // uint32 maximumGasPrice
      10, // uint32 reasonableGasPrice
      500, // uint32 microLinkPerEth
      500, // uint32 linkGweiPerObservation
      500, // uint32 linkGweiPerTransmission
      linkTokenInterface,
      1, // int192 minAnswer
      50000000000000000, // int192 maxAnswer
      accessControllerInterface,
      accessControllerInterface,
      8, // uint8 decimals
      "Test Offchain Aggregator"
    ));

    vm.stopBroadcast();

    return offchainAggregator;
  }

  function setPayees(address offchainAggregatorAddress, address[] memory nodesArray) public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.addr(deployerPrivateKey);

    address[] memory payees = new address[](4);
    payees[0] = deployerAddress;
    payees[1] = deployerAddress;
    payees[2] = deployerAddress;
    payees[3] = deployerAddress;

    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregatorInterface offchainAggregator = OffchainAggregatorInterface(offchainAggregatorAddress);
    offchainAggregator.setPayees(nodesArray, payees);

    vm.stopBroadcast();
  }

  function setPayees(address offchainAggregatorAddress, string[] memory nodesArrayStr) public {
    address[] memory nodesArray = new address[](nodesArrayStr.length);
    for (uint i; i < nodesArrayStr.length; i++) {
      nodesArray[i] = vm.parseAddress(nodesArrayStr[i]);
    }
    setPayees(offchainAggregatorAddress, nodesArray);
  }

  function setConfig(
    address offchainAggregatorAddress,
    address[] memory signers,
    address[] memory transmitters,
    uint8 threshold,
    uint64 encodedConfigVersion,
    bytes memory encoded
  ) public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregatorInterface offchainAggregator = OffchainAggregatorInterface(offchainAggregatorAddress);
    offchainAggregator.setConfig(signers, transmitters, threshold, encodedConfigVersion, encoded);

    vm.stopBroadcast();
  }

  function requestNewRound(address offchainAggregatorAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregatorInterface offchainAggregator = OffchainAggregatorInterface(offchainAggregatorAddress);
    offchainAggregator.requestNewRound();

    vm.stopBroadcast();
  }

  function latestAnswer(address offchainAggregatorAddress) external returns (int256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    OffchainAggregatorInterface offchainAggregator = OffchainAggregatorInterface(offchainAggregatorAddress);
    int256 answer = offchainAggregator.latestAnswer();

    vm.stopBroadcast();

    return answer;
  }
}
