// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";

contract BaseScript is Script {
  /// @notice Manages the broadcast context for nested script calls.
  /// @dev This modifier is used to maintains the original msg.sender identity across nested script calls.
  modifier nestedScriptContext {
    VmSafe.CallerMode callerMode;
    (callerMode,,) = vm.readCallers();

    bool isNestedCall = msg.sender != DEFAULT_SENDER;

    if (isNestedCall) {
      endCurrentContext(callerMode);
      vm.startBroadcast(msg.sender);
      _;
      vm.stopBroadcast();
    } else {
      _;
    }
  }

  /// @dev Ends the current context based on the caller mode.
  function endCurrentContext(VmSafe.CallerMode callerMode) internal {
    if (uint(callerMode) >= uint(VmSafe.CallerMode.Prank)) {
      vm.stopPrank();
    } else if (uint(callerMode) >= uint(VmSafe.CallerMode.Broadcast)) {
      vm.stopBroadcast();
    }
  }

  function run() external pure {}
}
