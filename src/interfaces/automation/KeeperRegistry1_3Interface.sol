// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./KeeperRegistryInterface.sol";
import "src/libraries/AutomationUtils.sol";

struct State {
  uint32 nonce;
  uint96 ownerLinkBalance;
  uint256 expectedLinkBalance;
  uint256 numUpkeeps;
}

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

interface KeeperRegistry1_3Interface is KeeperRegistryInterface {
  // @notice we need only selector of this function
  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    bytes calldata offchainConfig,
    uint96 amount,
    address sender
  ) external;
  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata
    checkData
  ) external returns (uint256 id);
  function getState() external view returns (
    State memory state,
    Config memory config,
    address[] memory keepers
  );
  function getUpkeep(uint256 id) external view returns (
    address target,
    uint32 executeGas,
    bytes memory checkData,
    uint96 balance,
    address lastKeeper,
    address admin,
    uint64 maxValidBlocknumber,
    uint96 amountSpent,
    bool paused
  );

  function getMaxPaymentForGas(uint256 gasLimit) external view returns (uint96 maxPayment);
  function updateCheckData(uint256 id, bytes calldata newCheckData) external;

  // @notice admin functions
  function setConfig(Config memory config) external;
  function setKeepers(address[] memory keepers, address[] memory payees) external;
}
