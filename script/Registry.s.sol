// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { Config } from "chainlink/v0.8/interfaces/AutomationRegistryInterface1_3.sol";
import "chainlink/v0.8/KeeperRegistry1_3.sol";
import "chainlink/v0.8/KeeperRegistryLogic1_3.sol";
import "chainlink/v0.8/KeeperRegistryBase1_3.sol";
import "chainlink/v0.8/interfaces/LinkTokenInterface.sol";
import "../src/mocks/MockEthFeed.sol";
import "../src/mocks/MockGasFeed.sol";

contract RegistryScript is Script {
  uint256 registryGasOverhead = 1;
  address randomAddress = address(0x8A791620dd6260079BF849Dc5567aDC3F2FdC318);

  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address linkTokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    MockEthFeed mockEthFeed = new MockEthFeed();
    MockGasFeed mockGasFeed = new MockGasFeed();

    Config memory registryConfig = Config(
      250000000,
      0,
      1,
      500000,
      3600,
      1,
      0,
      500000,
      100,
      200000000,
      randomAddress,
      randomAddress
    );

    KeeperRegistryLogic1_3 registryLogic = new KeeperRegistryLogic1_3(
      KeeperRegistryBase1_3.PaymentModel.DEFAULT,
      registryGasOverhead,
      linkTokenAddress,
      address(mockEthFeed),
      address(mockGasFeed)
    );
    KeeperRegistry1_3 registry = new KeeperRegistry1_3(registryLogic, registryConfig);

    vm.stopBroadcast();

    return address(registry);
  }

  function setKeepers(address registryAddress, address upkeepAddress, address[] memory nodesArray) external {
    address[] memory payees = new address[](5);
    payees[0] = upkeepAddress;
    payees[1] = upkeepAddress;
    payees[2] = upkeepAddress;
    payees[3] = upkeepAddress;
    payees[4] = upkeepAddress;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3 registry = KeeperRegistry1_3(registryAddressPayable);

    registry.setKeepers(nodesArray, payees);

    vm.stopBroadcast();
  }

  function registerUpkeep(address registryAddress, address upkeepAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3 registry = KeeperRegistry1_3(registryAddressPayable);

    vm.startBroadcast(deployerPrivateKey);
    bytes memory checkData = new bytes(0);
    uint256 upkeepId = registry.registerUpkeep(upkeepAddress, 499999, deployerAddress, checkData);
    vm.stopBroadcast();
  }

  function getState(address registryAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address[] memory keepers = new address[](5);
    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3 registry = KeeperRegistry1_3(registryAddressPayable);
    (,,keepers) = registry.getState();
    console.logAddress(keepers[0]);
    console.logAddress(keepers[1]);
    console.logAddress(keepers[2]);
    console.logAddress(keepers[3]);
    console.logAddress(keepers[4]);
    vm.stopBroadcast();
  }

  function getLastActiveUpkeepID(address registryAddress) external returns (uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3 registry = KeeperRegistry1_3(registryAddressPayable);
    uint256[] memory ids = registry.getActiveUpkeepIDs(0, 1);

    (address target,uint32 executeGas,,uint96 balance,address lastKeeper,,uint maxValidBlocknumber,,bool paused) = registry.getUpkeep(ids[0]);
    console.logAddress(target);
    console.logAddress(lastKeeper);
    console.logUint(maxValidBlocknumber);
    console.logUint(executeGas);
    console.logUint(balance);
    console.logBool(paused);

    vm.stopBroadcast();

    return ids[0];
  }
}
