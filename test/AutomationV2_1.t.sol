// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./BaseTest.t.sol";
import "script/automation/Automation.s.sol";
import "src/libraries/AutomationUtils.sol";
import { AutomationRegistrar2_1Interface, InitialTriggerConfig } from "src/interfaces/automation/AutomationRegistrar2_1Interface.sol";
import "src/interfaces/automation/KeeperRegistry2_1Interface.sol" as KeeperRegistry2_1;
import "src/interfaces/automation/CronUpkeepFactoryInterface.sol";
import "src/interfaces/test/CronUpkeepInterface.sol";

contract AutomationScriptTest is BaseTest {
  event RegistrationRequested(
    bytes32 indexed hash,
    string name,
    bytes encryptedEmail,
    address indexed upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    uint8 triggerType,
    bytes triggerConfig,
    bytes offchainConfig,
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
  uint96 public constant MIN_UPKEEP_SPEND = 1000000000000000000;
  uint96 public constant LINK_JUELS_ALLOWANCE = 100000000000000000000;
  uint96 public constant LINK_JUELS_TO_FUND = 2000000000000000000;
  string public constant EMAIL = "test";
  string public constant NAME = "test";
  bytes public constant EMPTY_BYTES = new bytes(0);
  address public constant cronLibraryAddress = address(0xCccCCCCcccCCcCccccCC00000000000000000000);

  AutomationScript public automationScript;

  address public linkTokenAddress;
  address public linkNativeFeed;
  address public fastGasFeed;
  address public mockV3AggregatorAddress;
  address public keeperRegistryAddress;
  address public keeperRegistrarAddress;
  address public upkeepTranscoderAddress;
  address public upkeepMockAddress;
  address public cronUpkeepAddress;
  address public automationForwarderLogicAddress;
  address public cronUpkeepFactoryAddress;

  function setUp() public override {
    BaseTest.setUp();

    vm.startBroadcast(OWNER_ADDRESS);

    linkTokenAddress = deployCode("LinkToken.sol:LinkToken");
    linkNativeFeed = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS_LINK, INITIAL_ANSWER_LINK));
    fastGasFeed = deployCode("MockV3Aggregator.sol:MockV3Aggregator", abi.encode(DECIMALS_GAS, INITIAL_ANSWER_GAS));
    upkeepTranscoderAddress = deployCode("UpkeepTranscoder.sol:UpkeepTranscoder");
    deployCodeTo("CronLibrary.sol:Cron", cronLibraryAddress);
    cronUpkeepFactoryAddress = deployCode("CronUpkeepFactory.sol:CronUpkeepFactory");
    upkeepMockAddress = deployCode("UpkeepMock.sol:UpkeepMock");
    cronUpkeepAddress = deployCode("CronUpkeep.sol:CronUpkeep");
    automationForwarderLogicAddress = deployCode("AutomationForwarderLogic.sol:AutomationForwarderLogic");

    address keeperRegistryLogicBAddress = deployCode("KeeperRegistryLogicB2_1.sol:KeeperRegistryLogicB2_1", abi.encode(
      AutomationUtils.PaymentModel.DEFAULT,
      linkTokenAddress,
      linkNativeFeed,
      fastGasFeed,
      automationForwarderLogicAddress
    ));

    address keeperRegistryLogicAAddress = deployCode("KeeperRegistryLogicA2_1.sol:KeeperRegistryLogicA2_1", abi.encode(
      keeperRegistryLogicBAddress
    ));

    keeperRegistryAddress = deployCode("KeeperRegistry2_1.sol:KeeperRegistry2_1", abi.encode(
      keeperRegistryLogicAAddress
    ));

    InitialTriggerConfig memory triggerConfigCondition = InitialTriggerConfig({
      triggerType: AutomationUtils.Trigger.CONDITION,
      autoApproveType: AutomationUtils.AutoApproveType.DISABLED,
      autoApproveMaxAllowed: 0
    });

    InitialTriggerConfig memory triggerConfigLog = InitialTriggerConfig({
      triggerType: AutomationUtils.Trigger.LOG,
      autoApproveType: AutomationUtils.AutoApproveType.DISABLED,
      autoApproveMaxAllowed: 0
    });

    InitialTriggerConfig[] memory triggerConfigs = new InitialTriggerConfig[](2);
    triggerConfigs[0] = triggerConfigCondition;
    triggerConfigs[1] = triggerConfigLog;

    keeperRegistrarAddress = deployCode("AutomationRegistrar2_1.sol:AutomationRegistrar2_1", abi.encode(
      linkTokenAddress,
      keeperRegistryAddress,
      MIN_UPKEEP_SPEND,
      triggerConfigs
    ));

    address[] memory registrars = new address[](1);
    registrars[0] = keeperRegistrarAddress;

    bytes memory onchainConfigHash = abi.encode(
      KeeperRegistry2_1.OnchainConfig({
        paymentPremiumPPB: 250000000,
        flatFeeMicroLink: 0, // min 0.000001 LINK, max 4294 LINK
        checkGasLimit: 500000,
        stalenessSeconds: 3600,
        gasCeilingMultiplier: 1,
        minUpkeepSpend: MIN_UPKEEP_SPEND,
        maxCheckDataSize: 10000,
        maxPerformDataSize: 10000,
        maxRevertDataSize: 1000,
        maxPerformGas: 5000000,
        fallbackGasPrice: uint(INITIAL_ANSWER_GAS),
        fallbackLinkPrice: uint(INITIAL_ANSWER_LINK),
        transcoder: upkeepTranscoderAddress,
        registrars: registrars,
        upkeepPrivilegeManager: STRANGER_ADDRESS
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

    KeeperRegistry2_1.KeeperRegistry2_1Interface(keeperRegistryAddress).setConfig(
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

  function test_RegisterUpkeep_LogTrigger_Success() public {
    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.LOG;
    bytes memory triggerConfig = AutomationUtils.getLogTriggerConfig(
      STRANGER2_ADDRESS,
      uint8(1),
      bytes32(0),
      bytes32(0),
      bytes32(0),
      bytes32(0)
    );

    vm.expectEmit(true, true, true, false);
    bytes32 hash = keccak256(abi.encode(upkeepMockAddress, GAS_LIMIT, OWNER_ADDRESS, triggerType, EMPTY_BYTES, triggerConfig, EMPTY_BYTES));
    bytes memory encryptedEmail = bytes(EMAIL);
    emit RegistrationRequested(
      hash,
      NAME,
      encryptedEmail,
      upkeepMockAddress,
      GAS_LIMIT,
      OWNER_ADDRESS,
      uint8(triggerType),
      triggerConfig,
      EMPTY_BYTES,
      EMPTY_BYTES,
      LINK_JUELS_TO_FUND
    );

    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep_logTrigger(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      NAME,
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES,
      triggerConfig
    );
  }

  function test_RegisterUpkeep_Condition_Success() public {
    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.CONDITION;

    bytes memory triggerConfig = EMPTY_BYTES;
    bytes memory offchainConfig = EMPTY_BYTES;
    bytes memory checkData = EMPTY_BYTES;

    vm.expectEmit(true, true, true, true);
    bytes32 hash = keccak256(abi.encode(upkeepMockAddress, GAS_LIMIT, OWNER_ADDRESS, uint8(triggerType), checkData, triggerConfig, offchainConfig));
    bytes memory encryptedEmail = bytes(EMAIL);
    emit RegistrationRequested(
      hash,
      NAME,
      encryptedEmail,
      upkeepMockAddress,
      GAS_LIMIT,
      OWNER_ADDRESS,
      uint8(triggerType),
      triggerConfig,
      EMPTY_BYTES,
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
      checkData
    );
  }

  function test_RegisterUpkeep_TimeBased_Success() public {
    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.CONDITION;

    bytes memory triggerConfig = EMPTY_BYTES;
    bytes memory offchainConfig = EMPTY_BYTES;
    bytes memory checkData = EMPTY_BYTES;

    bytes memory encryptedEmail = bytes(EMAIL);

    // Expecting RegistrationRequested event to be emitted, do not know the exact address of cron upkeep contract
    vm.expectEmit(false, false, false, false);
    emit RegistrationRequested(
      bytes32(0),
      NAME,
      encryptedEmail,
      address(0),
      GAS_LIMIT,
      OWNER_ADDRESS,
      uint8(triggerType),
      triggerConfig,
      EMPTY_BYTES,
      EMPTY_BYTES,
      LINK_JUELS_TO_FUND
    );

    bytes4 callUpkeepSelector = CronUpkeepInterface.callUpkeep.selector;
    string memory cronString = "*/15 * * * *";

    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep_timeBased(
      linkTokenAddress,
      LINK_JUELS_TO_FUND,
      NAME,
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      checkData,
      cronUpkeepFactoryAddress,
      callUpkeepSelector,
      cronString
    );
  }

  function test_GetUpkeepTranscoderVersion_Success() public {
    AutomationUtils.UpkeepFormat upkeepFormat = automationScript.getUpkeepTranscoderVersion();
    console.log(uint(upkeepFormat));
    assertEq(upkeepFormat == AutomationUtils.UpkeepFormat.V1, true);
  }
}
