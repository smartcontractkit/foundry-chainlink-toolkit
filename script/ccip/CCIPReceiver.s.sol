// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../helpers/BaseScript.s.sol";
import "src/interfaces/ccip/IAny2EVMMessageReceiver.sol";
import "src/libraries/CCIPClient.sol";

contract CCIPReceiverScript is BaseScript {
  address public ccipReceiverAddress;

  constructor (address _ccipReceiverAddress) {
    ccipReceiverAddress = _ccipReceiverAddress;
  }

  function ccipReceive(
    Client.Any2EVMMessage memory message
  ) external {
    IAny2EVMMessageReceiver ccipReceiver = IAny2EVMMessageReceiver(ccipReceiverAddress);
    ccipReceiver.ccipReceive(message);
  }
}
