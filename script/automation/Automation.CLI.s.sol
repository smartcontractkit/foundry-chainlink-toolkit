// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./Automation.s.sol";
import "../helpers/BaseScript.s.sol";
import "src/libraries/AutomationUtils.sol";

contract AutomationCLIScript is BaseScript {
  function registerUpkeep(
    address keeperRegistryAddress,
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData
  ) nestedScriptContext public returns (bytes32 requestHash) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.registerUpkeep(
      amountInJuels,
      upkeepName,
      email,
      upkeepAddress,
      gasLimit,
      checkData
    );
  }

  function registerUpkeep_logTrigger(
    address keeperRegistryAddress,
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData,
    bytes memory triggerConfig
  ) nestedScriptContext public returns (bytes32 requestHash) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.registerUpkeep_logTrigger(
      amountInJuels,
      upkeepName,
      email,
      upkeepAddress,
      gasLimit,
      checkData,
      triggerConfig
    );
  }

  function registerUpkeep_timeBased(
    address keeperRegistryAddress,
    uint96 amountInJuels,
    string calldata upkeepName,
    string calldata email,
    address upkeepAddress,
    uint32 gasLimit,
    bytes calldata checkData,
    address cronUpkeepFactoryAddress,
    bytes4 upkeepFunctionSelector,
    string calldata cronString
  ) nestedScriptContext public returns (bytes32 requestHash) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.registerUpkeep_timeBased(
      amountInJuels,
      upkeepName,
      email,
      upkeepAddress,
      gasLimit,
      checkData,
      cronUpkeepFactoryAddress,
      upkeepFunctionSelector,
      cronString
    );
  }

  function getPendingRequest(
    address keeperRegistryAddress,
    bytes32 requestHash
  ) external returns(address admin, uint96 balance) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getPendingRequest(requestHash);
  }

  function cancelRequest(
    address keeperRegistryAddress,
    bytes32 requestHash
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.cancelRequest(requestHash);
  }

  function getRegistrationConfig(
    address keeperRegistryAddress
  ) external returns (
    AutomationUtils.AutoApproveType autoApproveType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getRegistrationConfig();
  }

  function getRegistrationConfig(
    address keeperRegistryAddress,
    AutomationUtils.Trigger triggerType
  ) external returns (
    AutomationUtils.AutoApproveType autoApproveType,
    uint32 autoApproveMaxAllowed,
    uint32 approvedCount,
    address keeperRegistry,
    uint256 minLINKJuels
  ) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getRegistrationConfig(triggerType);
  }

  function addFunds(
    address keeperRegistryAddress,
    uint256 upkeepId,
    uint96 amountInJuels
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.addFunds(upkeepId, amountInJuels);
  }

  function pauseUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.pauseUpkeep(upkeepId);
  }

  function unpauseUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.unpauseUpkeep(upkeepId);
  }

  function cancelUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.cancelUpkeep(upkeepId);
  }

  function setUpkeepGasLimit(
    address keeperRegistryAddress,
    uint256 upkeepId,
    uint32 gasLimit
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.setUpkeepGasLimit(upkeepId, gasLimit);
  }

  function getMinBalanceForUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) external returns (uint96 minBalance) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getMinBalanceForUpkeep(upkeepId);
  }

  function getState(
    address keeperRegistryAddress
  ) external returns (RegistryState memory registryState) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getState();
  }

  function getUpkeepTranscoderVersion(
    address keeperRegistryAddress
  ) external returns(AutomationUtils.UpkeepFormat) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getUpkeepTranscoderVersion();
  }

  function getActiveUpkeepIDs(
    address keeperRegistryAddress,
    uint256 startIndex,
    uint256 maxCount
  ) external returns (uint256[] memory) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getActiveUpkeepIDs(startIndex, maxCount);
  }

  function getUpkeep(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) external returns (
    address target,
    uint32 executeGas,
    bytes memory checkData,
    uint96 balance,
    address admin,
    uint64 maxValidBlocknumber,
    uint96 amountSpent,
    bool paused
  ) {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    return automationScript.getUpkeep(upkeepId);
  }

  function withdrawFunds(
    address keeperRegistryAddress,
    uint256 upkeepId,
    address receivingAddress
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.withdrawFunds(upkeepId, receivingAddress);
  }

  function transferUpkeepAdmin(
    address keeperRegistryAddress,
    uint256 upkeepId,
    address proposedAdmin
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.transferUpkeepAdmin(upkeepId, proposedAdmin);
  }

  function acceptUpkeepAdmin(
    address keeperRegistryAddress,
    uint256 upkeepId
  ) nestedScriptContext external {
    AutomationScript automationScript = new AutomationScript(keeperRegistryAddress);
    automationScript.acceptUpkeepAdmin(upkeepId);
  }
}
