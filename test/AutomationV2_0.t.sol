// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./BaseTest.t.sol";
import { RegistryGeneration, RegistryState, AutomationScript } from "script/automation/Automation.s.sol";
import { KeeperRegistry2_0Interface, OnchainConfig } from "src/interfaces/automation/KeeperRegistry2_0Interface.sol";
import "src/interfaces/automation/KeeperRegistrar2_0Interface.sol";
import "src/libraries/AutomationUtils.sol";
import "src/libraries/Utils.sol";

contract AutomationScriptV2_0Test is BaseTest {
  event RegistrationRequested(
    bytes32 indexed hash,
    string name,
    bytes encryptedEmail,
    address indexed upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes checkData,
    uint96 amount
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
  uint96 public constant LINK_JUELS_ALLOWANCE = 100000000000000000000;
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

    address keeperRegistryBaseAddress = deployCode("KeeperRegistryLogic2_0.sol:KeeperRegistryLogic2_0", abi.encode(
      AutomationUtils.PaymentModel.DEFAULT,
      linkTokenAddress,
      linkNativeFeed,
      fastGasFeed
    ));

    keeperRegistryAddress = deployCode("KeeperRegistry2_0.sol:KeeperRegistry2_0", abi.encode(
      keeperRegistryBaseAddress
    ));

    keeperRegistrarAddress = deployCode("KeeperRegistrar2_0.sol:KeeperRegistrar2_0", abi.encode(
      linkTokenAddress,
      AutomationUtils.AutoApproveType.ENABLED_ALL,
      AUTO_APPROVE_MAX_ALLOWED,
      keeperRegistryAddress,
      MIN_LINK_JUELS
    ));

    bytes memory onchainConfigHash = abi.encode(
      OnchainConfig({
        paymentPremiumPPB: 250000000,
        flatFeeMicroLink: 0, // min 0.000001 LINK, max 4294 LINK
        checkGasLimit: 500000,
        stalenessSeconds: 3600,
        gasCeilingMultiplier: 1,
        minUpkeepSpend: 0,
        maxPerformGas: 500000,
        maxCheckDataSize: 10000,
        maxPerformDataSize: 10000,
        fallbackGasPrice: uint(INITIAL_ANSWER_GAS),
        fallbackLinkPrice: uint(INITIAL_ANSWER_LINK),
        transcoder: upkeepTranscoderAddress,
        registrar: keeperRegistrarAddress
      })
    );
    address[] memory signers = new address[](4);
    signers[0] = OWNER_ADDRESS;
    signers[1] = STRANGER_ADDRESS;
    signers[2] = STRANGER2_ADDRESS;
    signers[3] = STRANGER3_ADDRESS;
    address[] memory transmitters = new address[](4);
    transmitters[0] = OWNER_ADDRESS;
    transmitters[1] = STRANGER_ADDRESS;
    transmitters[2] = STRANGER2_ADDRESS;
    transmitters[3] = STRANGER3_ADDRESS;

    KeeperRegistry2_0Interface(keeperRegistryAddress).setConfig(
      signers,
      transmitters,
      uint8(1),
      onchainConfigHash,
      uint64(1),
      EMPTY_BYTES
    );

    automationScript = new AutomationScript(keeperRegistryAddress);

    vm.stopBroadcast();
  }

  function test_RegisterUpkeep_Success() public {
    vm.expectEmit(true, true, true, false);
    bytes32 hash = keccak256(abi.encode(upkeepMockAddress, GAS_LIMIT, OWNER_ADDRESS, EMPTY_BYTES, EMPTY_BYTES));
    bytes memory encryptedEmail = bytes(EMAIL);
    emit RegistrationRequested(
      hash,
      NAME,
      encryptedEmail,
      upkeepMockAddress,
      GAS_LIMIT,
      OWNER_ADDRESS,
      EMPTY_BYTES,
      LINK_JUELS_TO_FUND
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
    assertEq(Utils.compareStrings(registryState.registryGeneration, RegistryGeneration.v2_0), true);
  }

  function test_GetUpkeepTranscoderVersion_Success() public {
    AutomationUtils.UpkeepFormat upkeepFormat = automationScript.getUpkeepTranscoderVersion();
    assertEq(upkeepFormat == AutomationUtils.UpkeepFormat.V1, true);
  }

  function test_GetAndCancelRequest_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    KeeperRegistrar2_0Interface(keeperRegistrarAddress).setRegistrationConfig(
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
    KeeperRegistrar2_0Interface(keeperRegistrarAddress).setRegistrationConfig(
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
