// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

struct State {
  uint32 nonce;
  uint96 ownerLinkBalance;
  uint256 expectedLinkBalance;
  uint256 numUpkeeps;
}

enum MigrationPermission {
  NONE,
  OUTGOING,
  INCOMING,
  BIDIRECTIONAL
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

interface KeeperRegistryInterface {
  function registerUpkeep(address target, uint32 gasLimit, address admin, bytes calldata checkData) external returns (uint256 id);
  function checkUpkeep(uint256 id, address from) external returns (
    bytes memory performData,
    uint256 maxLinkPayment,
    uint256 gasLimit,
    uint256 adjustedGasWei,
    uint256 linkEth
  );
  function performUpkeep(uint256 id, bytes calldata performData) external returns (bool success);
  function cancelUpkeep(uint256 id) external;
  function pauseUpkeep(uint256 id) external;
  function unpauseUpkeep(uint256 id) external;
  function updateCheckData(uint256 id, bytes calldata newCheckData) external;
  function addFunds(uint256 id, uint96 amount) external;
  function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external;
  function withdrawFunds(uint256 id, address to) external;
  function withdrawOwnerFunds() external;
  function setUpkeepGasLimit(uint256 id, uint32 gasLimit) external;
  function recoverFunds() external;
  function withdrawPayment(address from, address to) external;
  function transferPayeeship(address keeper, address proposed) external;
  function acceptPayeeship(address keeper) external;
  function transferUpkeepAdmin(uint256 id, address proposed) external;
  function acceptUpkeepAdmin(uint256 id) external;
  function pause() external;
  function unpause() external;
  function setConfig(Config memory config) external;
  function setKeepers(address[] memory keepers, address[] memory payees) external;
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
  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);
  function getKeeperInfo(address query) external view returns (address payee, bool active, uint96 balance);
  function getState() external view returns (State memory state, Config memory config, address[] memory keepers);
  function getMinBalanceForUpkeep(uint256 id) external view returns (uint96 minBalance);
  function getMaxPaymentForGas(uint256 gasLimit) external view returns (uint96 maxPayment);
  function getPeerRegistryMigrationPermission(address peer) external view returns (MigrationPermission);
  function setPeerRegistryMigrationPermission(address peer, MigrationPermission permission) external;
  function migrateUpkeeps(uint256[] calldata ids, address destination) external;
  function receiveUpkeeps(bytes calldata encodedUpkeeps) external;
}
