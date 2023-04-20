// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity  >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../src/interfaces/LinkTokenInterface.sol";
import "../src/interfaces/KeeperRegistryInterface.sol";
import "../src/mocks/MockEthFeed.sol";
import "../src/mocks/MockGasFeed.sol";

struct Config {
  uint32 paymentPremiumPPB;
  uint32 flatFeeMicroLink; // min 0.000001 LINK, max 4294 LINK
  uint24 blockCountPerTurn;
  uint32 checkGasLimit;
  uint24 stalenessSeconds;
  uint16 gasCeilingMultiplier;
  uint96 minUpkeepSpend;
  uint32 maxPerformGas;
  uint256 fallbackGasPrice;
  uint256 fallbackLinkPrice;
  address transcoder;
  address registrar;
}

contract RegistryScript is Script {
  address randomAddress = address(0x8A791620dd6260079BF849Dc5567aDC3F2FdC318);
  enum PaymentModel {
    DEFAULT,
    ARBITRUM,
    OPTIMISM
  }

  function run() external {
    console.log("Please run deploy() method.");
  }

  function deploy(address linkTokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    uint256 registryGasOverhead = 1;

    vm.startBroadcast(deployerPrivateKey);

    MockEthFeed mockEthFeed = new MockEthFeed();
    MockGasFeed mockGasFeed = new MockGasFeed();

    Config memory registryConfig = Config(
      250000000, // uint32 paymentPremiumPPB
      0, // uint32 flatFeeMicroLink
      1, // uint24 blockCountPerTurn
      500000, // uint32 checkGasLimit
      3600, // uint24 stalenessSeconds
      1, // uint16 gasCeilingMultiplier
      0, // uint96 minUpkeepSpend
      500000, // uint32 maxPerformGas
      100, // uint256 fallbackGasPrice
      200000000, // uint256 fallbackLinkPrice
      randomAddress,
      randomAddress
    );

    address registryLogic = deployCode("KeeperRegistryLogic1_3.sol:KeeperRegistryLogic1_3", abi.encode(
      PaymentModel.DEFAULT,
      registryGasOverhead,
      linkTokenAddress,
      address(mockEthFeed),
      address(mockGasFeed)
    ));
    address registry = deployCode("KeeperRegistry1_3.sol:KeeperRegistry1_3", abi.encode(
      registryLogic,
      registryConfig
    ));

    vm.stopBroadcast();

    return registry;
  }

  function setKeepers(address registryAddress, address upkeepAddress, address[] calldata nodesArray) external {
    address[] memory payees = new address[](5);
    payees[0] = upkeepAddress;
    payees[1] = upkeepAddress;
    payees[2] = upkeepAddress;
    payees[3] = upkeepAddress;
    payees[4] = upkeepAddress;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistryInterface registry = KeeperRegistryInterface(registryAddressPayable);

    registry.setKeepers(nodesArray, payees);

    vm.stopBroadcast();
  }

  function registerUpkeep(address registryAddress, address upkeepAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistryInterface registry = KeeperRegistryInterface(registryAddressPayable);

    vm.startBroadcast(deployerPrivateKey);

    bytes memory checkData = new bytes(0);
    uint256 upkeepId = registry.registerUpkeep(upkeepAddress, 499999, deployerAddress, checkData);

    vm.stopBroadcast();
  }

  function getLastActiveUpkeepID(address registryAddress) external returns (uint256) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistryInterface registry = KeeperRegistryInterface(registryAddressPayable);
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
