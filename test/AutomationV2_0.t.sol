// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./BaseTest.t.sol";
import { RegistryState, AutomationScript } from "script/automation/Automation.s.sol";
import "src/interfaces/automation/KeeperRegistrar1_2Interface.sol";
import "src/libraries/AutomationUtils.sol";
import { KeeperRegistry2_0Interface, OnchainConfig } from "src/interfaces/automation/KeeperRegistry2_0Interface.sol";

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
    bytes memory offchainConfig = EMPTY_BYTES;
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
    automationScript.registerUpkeep(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      NAME,
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );
  }

  function test_GetUpkeepTranscoderVersion_Success() public {
    AutomationUtils.UpkeepFormat upkeepFormat = automationScript.getUpkeepTranscoderVersion();
    assertEq(upkeepFormat == AutomationUtils.UpkeepFormat.V1, true);
  }
}
