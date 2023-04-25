// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

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

interface KeeperRegistryInterface {
  function setKeepers(address[] calldata keepers, address[] calldata payees) external;
  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (uint256 id);
  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);
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
  function getState() external view returns (
    State memory state,
    Config memory config,
    address[] memory keepers
  );
}
