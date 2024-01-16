// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./KeeperCompatibleInterface.sol";

interface UpkeepMockInterface is KeeperCompatibleInterface {
  function setShouldRevertCheck(bool value) external;
  function setPerformData(bytes calldata data) external;
  function setCanCheck(bool value) external;
  function setCanPerform(bool value) external;
  function setCheckRevertReason(string calldata value) external;
  function setCheckGasToBurn(uint256 value) external;
  function setPerformGasToBurn(uint256 value) external;
}
