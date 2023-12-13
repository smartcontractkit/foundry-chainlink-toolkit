// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

pragma solidity >=0.6.2 <0.9.0;

import "../shared/TypeAndVersionInterface.sol";
import "src/libraries/AutomationUtils.sol";

interface KeeperRegistryInterface is TypeAndVersionInterface {
  function pauseUpkeep(uint256 id) external;
  function unpauseUpkeep(uint256 id) external;
  function cancelUpkeep(uint256 id) external;
  function addFunds(uint256 id, uint96 amount) external;
  function withdrawFunds(uint256 id, address to) external;
  function withdrawPayment(address from, address to) external;
  function setUpkeepGasLimit(uint256 id, uint32 gasLimit) external;
  function upkeepTranscoderVersion() external view returns(AutomationUtils.UpkeepFormat);
  function transferPayeeship(address keeper, address proposed) external;
  function acceptPayeeship(address keeper) external;
  function transferUpkeepAdmin(uint256 id, address proposed) external;
  function acceptUpkeepAdmin(uint256 id) external;
  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);
  function getMinBalanceForUpkeep(uint256 id) external view returns (uint96 minBalance);
}
