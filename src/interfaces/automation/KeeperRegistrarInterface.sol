// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/libraries/AutomationUtils.sol";
import "../shared/TypeAndVersionInterface.sol";

interface KeeperRegistrarInterface is TypeAndVersionInterface {
  function cancel(bytes32 hash) external;
  function getAutoApproveAllowedSender(address senderAddress) external view returns(bool);
  function getPendingRequest(bytes32 hash) external view returns(address, uint96);
  function LINK() external view returns(address);
}
