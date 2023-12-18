// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../ChainlinkCronConsumer.s.sol";
import "./FFI.s.sol";

contract CronJobScript is Script {
  function run(string memory nodeId) public {
    FFIScript ffiScript = new FFIScript();

    ChainlinkCronConsumerScript chainlinkCronConsumerScript = new ChainlinkCronConsumerScript();
    address cronConsumer = chainlinkCronConsumerScript.deploy();
    console.logString(Utils.append("Cron Consumer address: ", vm.toString(cronConsumer)));

    string memory jobId = ffiScript.getJobId(nodeId, cronConsumer);
    if (bytes(jobId).length != 0) {
      ffiScript.deleteJob(nodeId, jobId);
    }

    ffiScript.createCronJob(nodeId, cronConsumer);

    jobId = ffiScript.getJobId(nodeId, cronConsumer);
    console.logString(Utils.append("Job ID: ", jobId));

    string memory externalJobId = ffiScript.getExternalJobId(nodeId, cronConsumer);
    console.logString(Utils.append("External Job ID: ", externalJobId));
  }
}
