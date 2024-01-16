// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "./FFI.s.sol";

contract WebhookJobScript is Script {
  function run(string memory nodeId) public {
    FFIScript ffiScript = new FFIScript();

    ffiScript.createWebhookJob(nodeId);

    string memory jobId = ffiScript.getLastWebhookJobId(nodeId);
    console.logString(Utils.append("Job ID: ", jobId));

    ffiScript.runWebhookJob(nodeId, jobId);
  }
}
