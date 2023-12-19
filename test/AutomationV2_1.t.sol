// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./BaseTest.t.sol";
import { RegistryState, AutomationScript } from "script/automation/Automation.s.sol";
import { AutomationRegistrar2_1Interface, InitialTriggerConfig } from "src/interfaces/automation/AutomationRegistrar2_1Interface.sol";
import "src/interfaces/automation/KeeperRegistry2_1Interface.sol" as KeeperRegistry2_1;
import "src/interfaces/automation/CronUpkeepFactoryInterface.sol";
import "src/interfaces/shared/LinkTokenInterface.sol";
import "src/interfaces/test/CronUpkeepInterface.sol";
import "src/libraries/AutomationUtils.sol";
import "src/libraries/Utils.sol";

contract AutomationScriptV2_1Test is BaseTest {
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
  event RegistrationRejected(bytes32 indexed hash);
  event UpkeepPaused(uint256 indexed id);
  event UpkeepUnpaused(uint256 indexed id);
  event UpkeepCanceled(uint256 indexed id, uint64 indexed atBlockHeight);
  event FundsWithdrawn(uint256 indexed id, uint256 amount, address to);
  event UpkeepGasLimitSet(uint256 indexed id, uint96 gasLimit);
  event FundsAdded(uint256 indexed id, address indexed from, uint96 amount);
  event UpkeepAdminTransferRequested(uint256 indexed id, address indexed from, address indexed to);
  event UpkeepAdminTransferred(uint256 indexed id, address indexed from, address indexed to);

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
      autoApproveType: AutomationUtils.AutoApproveType.ENABLED_ALL,
      autoApproveMaxAllowed: AUTO_APPROVE_MAX_ALLOWED
    });

    InitialTriggerConfig memory triggerConfigLog = InitialTriggerConfig({
      triggerType: AutomationUtils.Trigger.LOG,
      autoApproveType: AutomationUtils.AutoApproveType.ENABLED_ALL,
      autoApproveMaxAllowed: AUTO_APPROVE_MAX_ALLOWED
    });

    InitialTriggerConfig[] memory triggerConfigs = new InitialTriggerConfig[](2);
    triggerConfigs[0] = triggerConfigCondition;
    triggerConfigs[1] = triggerConfigLog;

    keeperRegistrarAddress = deployCode("AutomationRegistrar2_1.sol:AutomationRegistrar2_1", abi.encode(
      linkTokenAddress,
      keeperRegistryAddress,
      MIN_LINK_JUELS,
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
    bytes32 requestHash = automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      NAME,
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      checkData
    );

    assertEq(hash, requestHash);
  }

  function test_RegisterUpkeep_TimeBased_Success() public {
    AutomationUtils.Trigger triggerType = AutomationUtils.Trigger.CONDITION;

    bytes memory triggerConfig = EMPTY_BYTES;
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

  function test_GetState_Success() public {
    RegistryState memory registryState = automationScript.getState();
    assertGe(registryState.combinedState.numUpkeeps, 0);
    assertEq(registryState.combinedConfig.transcoder, upkeepTranscoderAddress);
    assertEq(registryState.signers[0], OWNER_ADDRESS);
    assertEq(registryState.transmitters[0], OWNER_ADDRESS);
    assertEq(registryState.f, 1);
  }

  function test_GetUpkeepTranscoderVersion_Success() public {
    AutomationUtils.UpkeepFormat upkeepFormat = automationScript.getUpkeepTranscoderVersion();
    assertEq(upkeepFormat == AutomationUtils.UpkeepFormat.V1, true);
  }

  function test_GetAndCancelRequest_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    AutomationRegistrar2_1Interface(keeperRegistrarAddress).setTriggerConfig(
      uint8(AutomationUtils.Trigger.CONDITION),
      AutomationUtils.AutoApproveType.DISABLED,
      AUTO_APPROVE_MAX_ALLOWED
    );

    vm.broadcast(OWNER_ADDRESS);
    bytes32 requestHash = automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "cancelledUpkeepRequest",
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
    AutomationRegistrar2_1Interface(keeperRegistrarAddress).setTriggerConfig(
      uint8(AutomationUtils.Trigger.CONDITION),
      AutomationUtils.AutoApproveType.ENABLED_ALL,
      AUTO_APPROVE_MAX_ALLOWED
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
    ) = automationScript.getRegistrationConfig(AutomationUtils.Trigger.CONDITION);

    assertEq(uint8(autoApproveType), uint8(AutomationUtils.AutoApproveType.ENABLED_ALL));
    assertEq(autoApproveMaxAllowed, AUTO_APPROVE_MAX_ALLOWED);
    assertEq(approvedCount, 0);
    assertEq(keeperRegistry, keeperRegistryAddress);
    assertEq(minLINKJuels, MIN_LINK_JUELS);
  }

  function test_GetMinBalanceForUpkeep_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "dummyUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    uint96 minBalance = automationScript.getMinBalanceForUpkeep(upkeepId);
    assertGt(minBalance, 0);
  }

  function test_PauseUnpauseUpkeep_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "pausedUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    vm.expectEmit(true, false, false, false);
    emit UpkeepPaused(upkeepId);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.pauseUpkeep(upkeepId);

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
    assertEq(paused, true);

    vm.expectEmit(true, false, false, false);
    emit UpkeepUnpaused(upkeepId);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.unpauseUpkeep(upkeepId);

    (,,,,,,,paused) = automationScript.getUpkeep(upkeepId);
    assertEq(paused, false);
  }

  function test_CancelUpkeepAndWithdrawFunds_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "cancelledUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    RegistryState memory registryState;
    registryState = automationScript.getState();
    uint256 numUpkeeps = registryState.combinedState.numUpkeeps;

    vm.expectEmit(true, false, false, false);
    emit UpkeepCanceled(upkeepId, 0);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.cancelUpkeep(upkeepId);

    registryState = automationScript.getState();
    assertEq(registryState.combinedState.numUpkeeps, numUpkeeps - 1);

    vm.expectEmit(true, true, false, true);
    emit FundsWithdrawn(upkeepId, LINK_JUELS_TO_FUND - MIN_UPKEEP_SPEND, STRANGER2_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.withdrawFunds(upkeepId, STRANGER2_ADDRESS);

    assertGt(LinkTokenInterface(linkTokenAddress).balanceOf(STRANGER2_ADDRESS), 0);
  }

  function test_SetGasLimit_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "changedUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    vm.expectEmit(true, false, false, false);
    emit UpkeepGasLimitSet(upkeepId, GAS_LIMIT + 1);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.setUpkeepGasLimit(upkeepId, GAS_LIMIT + 1);
    (,uint96 executeGas,,,,,,) = automationScript.getUpkeep(upkeepId);
    assertEq(executeGas, GAS_LIMIT + 1);
  }

  function test_AddFunds_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "fundedUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    vm.broadcast(OWNER_ADDRESS);
    LinkTokenInterface(linkTokenAddress).approve(keeperRegistryAddress, LINK_JUELS_TO_FUND);

    vm.expectEmit(true, true, false, false);
    emit FundsAdded(upkeepId, OWNER_ADDRESS, LINK_JUELS_TO_FUND);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.addFunds(upkeepId, LINK_JUELS_TO_FUND);
    (,,,uint96 balance,,,,) = automationScript.getUpkeep(upkeepId);
    assertEq(balance, 2*LINK_JUELS_TO_FUND);
  }

  function test_TransferUpkeepAdmin_Success() public {
    vm.broadcast(OWNER_ADDRESS);
    automationScript.registerUpkeep(
      LINK_JUELS_TO_FUND,
      "transferredUpkeep",
      EMAIL,
      upkeepMockAddress,
      GAS_LIMIT,
      EMPTY_BYTES
    );

    uint256[] memory activeUpkeepIDs = automationScript.getActiveUpkeepIDs(0, 0);
    assertGt(activeUpkeepIDs.length, 0);

    uint256 upkeepId = activeUpkeepIDs[activeUpkeepIDs.length - 1];

    vm.expectEmit(true, true, true, false);
    emit UpkeepAdminTransferRequested(upkeepId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(OWNER_ADDRESS);
    automationScript.transferUpkeepAdmin(upkeepId, STRANGER_ADDRESS);

    vm.expectEmit(true, true, true, false);
    emit UpkeepAdminTransferred(upkeepId, OWNER_ADDRESS, STRANGER_ADDRESS);
    vm.broadcast(STRANGER_ADDRESS);
    automationScript.acceptUpkeepAdmin(upkeepId);

    (,,,,address admin,,,) = automationScript.getUpkeep(upkeepId);
    assertEq(admin, STRANGER_ADDRESS);
  }
}
