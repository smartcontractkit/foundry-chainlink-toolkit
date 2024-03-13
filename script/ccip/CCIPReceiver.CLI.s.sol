// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "./CCIPReceiver.s.sol";
import "../helpers/BaseScript.s.sol";

contract CCIPReceiverCLIScript is BaseScript {
  function ccipReceive(
    address ccipReceiverAddress,
    uint64 sourceChainSelector,
    address sender,
    bytes memory data
  ) external {
    Client.EVMTokenAmount[] memory destTokenAmounts = new Client.EVMTokenAmount[](0);
    CCIPReceiverScript ccipReceiverScript = new CCIPReceiverScript(ccipReceiverAddress);
    Client.Any2EVMMessage memory message = Client.Any2EVMMessage({
      messageId: bytes32(0),
      sourceChainSelector: sourceChainSelector,
      sender: abi.encode(sender),
      data: data,
      destTokenAmounts: destTokenAmounts
    });
    ccipReceiverScript.ccipReceive(message);
  }
}
