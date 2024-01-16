// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";
import { KeeperRegistry1_3Interface, Config, State } from "src/interfaces/automation/KeeperRegistry1_3Interface.sol";
import "src/mocks/MockEthFeed.sol";
import "src/mocks/MockGasFeed.sol";

contract KeeperRegistryScript is Script {
  address public randomAddress = address(0x8A791620dd6260079BF849Dc5567aDC3F2FdC318);
  enum PaymentModel {
    DEFAULT,
    ARBITRUM,
    OPTIMISM
  }

  function run() external view {
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

  function setKeepers(address registryAddress, address upkeepAddress, address[] memory nodesArray) public {
    address[] memory payees = new address[](5);
    payees[0] = upkeepAddress;
    payees[1] = upkeepAddress;
    payees[2] = upkeepAddress;
    payees[3] = upkeepAddress;
    payees[4] = upkeepAddress;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3Interface registry = KeeperRegistry1_3Interface(registryAddressPayable);

    registry.setKeepers(nodesArray, payees);

    vm.stopBroadcast();
  }

  function registerUpkeep(address registryAddress, address upkeepAddress) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.addr(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3Interface registry = KeeperRegistry1_3Interface(registryAddressPayable);

    vm.startBroadcast(deployerPrivateKey);

    bytes memory checkData = new bytes(0);
    registry.registerUpkeep(upkeepAddress, 499999, deployerAddress, checkData);

    vm.stopBroadcast();
  }

  function fundLatestUpkeep(address registryAddress, address linkTokenAddress, uint256 amount) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    address payable registryAddressPayable = payable(registryAddress);
    KeeperRegistry1_3Interface registry = KeeperRegistry1_3Interface(registryAddressPayable);
    (State memory state,,) = registry.getState();
    uint[] memory ids = registry.getActiveUpkeepIDs(0, state.numUpkeeps);

    LinkTokenInterface linkToken = LinkTokenInterface(linkTokenAddress);
    linkToken.transferAndCall(registryAddress, amount, abi.encode(ids[state.numUpkeeps - 1]));

    vm.stopBroadcast();
  }
}
