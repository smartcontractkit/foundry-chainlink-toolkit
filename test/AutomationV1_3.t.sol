// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./BaseTest.t.sol";
import { RegistryGeneration, RegistryState, AutomationScript } from "script/automation/Automation.s.sol";
import "src/interfaces/automation/KeeperRegistrar1_2Interface.sol";
import { KeeperRegistry1_3Interface, Config, State } from "src/interfaces/automation/KeeperRegistry1_3Interface.sol";
import "src/libraries/AutomationUtils.sol";
import "src/libraries/Utils.sol";

contract AutomationScriptV1_3Test is BaseTest {
  event RegistrationRequested(
    bytes32 indexed hash,
    string name,
    bytes encryptedEmail,
    address indexed upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes checkData,
    uint96 amount,
    uint8 indexed source
  );
  event RegistrationRejected(bytes32 indexed hash);

  uint8 public constant DECIMALS_LINK = 9;
  uint8 public constant DECIMALS_GAS = 0;
  int256 public constant INITIAL_ANSWER_LINK = 300000000;
  int256 public constant INITIAL_ANSWER_GAS = 100;
  uint8 public constant REGISTRY_GAS_OVERHEAD = 0;
  uint32 public constant GAS_LIMIT = 500_000;
  uint16 public constant AUTO_APPROVE_MAX_ALLOWED = 10_000;
  uint96 public constant MIN_LINK_JUELS = 500000000000;
  uint96 public constant LINK_JUELS_TO_FUND = 100000000000000000;
  string public constant EMAIL = "test";
  string public constant NAME = "test";
  bytes public constant EMPTY_BYTES = new bytes(0);

  AutomationScript public automationScript;

  address public linkTokenAddress;
  address public linkNativeFeed;
  address public fastGasFeed;
  address public keeperRegistryAddress;
  address public keeperRegistrarAddress;
  address public upkeepTranscoderAddress;
  address public upkeepMockAddress;

  function setUp() public override {
    BaseTest.setUp();

    vm.startBroadcast(OWNER_ADDRESS);
    linkTokenAddress = deployCode("LinkToken.sol:LinkToken");
    linkNativeFeed = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS_LINK, INITIAL_ANSWER_LINK));
    fastGasFeed = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS_GAS, INITIAL_ANSWER_GAS));
    upkeepTranscoderAddress = deployCode("UpkeepTranscoder.sol:UpkeepTranscoder");
    upkeepMockAddress = deployCode("UpkeepMock.sol:UpkeepMock");

    address keeperRegistryBaseAddress = deployCode("KeeperRegistryLogic1_3.sol:KeeperRegistryLogic1_3", abi.encode(
      AutomationUtils.PaymentModel.DEFAULT,
      REGISTRY_GAS_OVERHEAD,
      linkTokenAddress,
      linkNativeFeed,
      fastGasFeed
    ));

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
      upkeepTranscoderAddress,
      keeperRegistrarAddress
    );

    keeperRegistryAddress = deployCode("KeeperRegistry1_3.sol:KeeperRegistry1_3", abi.encode(
      keeperRegistryBaseAddress,
      registryConfig
    ));

    keeperRegistrarAddress = deployCode("KeeperRegistrar1_2.sol:KeeperRegistrar", abi.encode(
      linkTokenAddress,
      AutomationUtils.AutoApproveType.ENABLED_ALL,
      AUTO_APPROVE_MAX_ALLOWED,
      keeperRegistryAddress,
      MIN_LINK_JUELS
    ));

    registryConfig.registrar = keeperRegistrarAddress;

    KeeperRegistry1_3Interface(keeperRegistryAddress).setConfig(registryConfig);

    automationScript = new AutomationScript(keeperRegistryAddress);

    vm.stopBroadcast();
  }

  function test_RegisterUpkeep_Success() public {
    vm.expectEmit(true, true, true, true);
    bytes32 hash = keccak256(abi.encode(upkeepMockAddress, GAS_LIMIT, OWNER_ADDRESS, EMPTY_BYTES));
    bytes memory encryptedEmail = bytes(EMAIL);
    emit RegistrationRequested(
      hash,
      NAME,
      encryptedEmail,
      upkeepMockAddress,
      GAS_LIMIT,
      OWNER_ADDRESS,
      EMPTY_BYTES,
      LINK_JUELS_TO_FUND,
      uint8(0)
    );

    vm.broadcast(OWNER_ADDRESS);
    bytes32 requestHash = automationScript.registerUpkeep(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      NAME,
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );
    assertEq(hash, requestHash);
  }

  function test_GetState_Success() public {
    RegistryState memory registryState = automationScript.getState();
    assertEq(Utils.compareStrings(registryState.registryGeneration, RegistryGeneration.v1_0), true);
  }

  function test_GetUpkeepTranscoderVersion_Success() public {
    AutomationUtils.UpkeepFormat upkeepFormat = automationScript.getUpkeepTranscoderVersion();
    assertEq(upkeepFormat == AutomationUtils.UpkeepFormat.V2, true);
  }

  function test_GetAndCancelRequest_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    KeeperRegistrar1_2Interface(keeperRegistrarAddress).setRegistrationConfig(
      AutomationUtils.AutoApproveType.DISABLED,
      AUTO_APPROVE_MAX_ALLOWED,
      keeperRegistryAddress,
      MIN_LINK_JUELS
    );

    vm.broadcast(OWNER_ADDRESS);
    bytes32 requestHash = automationScript.registerUpkeep(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      "cancelledUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    (address admin, uint96 balance) = automationScript.getPendingRequest(requestHash);
    assertEq(admin, OWNER_ADDRESS);
    assertEq(balance, LINK_JUELS_TO_FUND);

    vm.expectEmit(true, true, false, false);
    emit RegistrationRejected(requestHash);

    vm.broadcast(OWNER_ADDRESS);
    automationScript.cancelRequest(requestHash);

    vm.broadcast(OWNER_ADDRESS);
    KeeperRegistrar1_2Interface(keeperRegistrarAddress).setRegistrationConfig(
      AutomationUtils.AutoApproveType.ENABLED_ALL,
      AUTO_APPROVE_MAX_ALLOWED,
      keeperRegistryAddress,
      MIN_LINK_JUELS
    );
  }

  function test_GetRegistrationConfig_Success() public {
    AutomationUtils.AutoApproveType autoApproveType;
    uint32 autoApproveMaxAllowed;
    uint32 approvedCount;
    address keeperRegistry;
    uint256 minLINKJuels;

    (
      autoApproveType,
      autoApproveMaxAllowed,
      approvedCount,
      keeperRegistry,
      minLINKJuels
    ) = automationScript.getRegistrationConfig();

    assertEq(uint8(autoApproveType), uint8(AutomationUtils.AutoApproveType.ENABLED_ALL));
    assertEq(autoApproveMaxAllowed, AUTO_APPROVE_MAX_ALLOWED);
    assertEq(approvedCount, 0);
    assertEq(keeperRegistry, keeperRegistryAddress);
    assertEq(minLINKJuels, MIN_LINK_JUELS);
  }

  function test_GetActiveUpkeepIDs_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    bytes32 requestHash = automationScript.registerUpkeep(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      "activeUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];
    (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address admin,
      ,
      uint96 amountSpent,
      bool paused
    ) = automationScript.getUpkeep(upkeepId);
    assertEq(target, upkeepMockAddress);
    assertEq(executeGas, GAS_LIMIT);
    assertEq(checkData, EMPTY_BYTES);
    assertEq(balance, LINK_JUELS_TO_FUND);
    assertEq(admin, OWNER_ADDRESS);
    assertEq(amountSpent, 0);
    assertEq(paused, false);
  }
}