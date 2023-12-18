// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../Oracle.s.sol";
import "../ChainlinkDirectRequestConsumer.s.sol";
import "../utils/Helper.s.sol";
import "./FFI.s.sol";

contract DirectRequestJobScript is Script {
  function run(string memory nodeId) public {
    FFIScript ffiScript = new FFIScript();

    address linkTokenAddress = vm.envAddress("LINK_CONTRACT_ADDRESS");
    address nodeAddress = ffiScript.getNodeAddress(nodeId);

    OracleScript oracleScript = new OracleScript();
    address oracle = oracleScript.deploy(linkTokenAddress, nodeAddress);
    console.logString(Utils.append("Oracle address: ", vm.toString(oracle)));

    ChainlinkDirectRequestConsumerScript chainlinkConsumerScript = new ChainlinkDirectRequestConsumerScript();
    address consumer = chainlinkConsumerScript.deploy(linkTokenAddress);
    console.logString(Utils.append("Direct Request Consumer address: ", vm.toString(consumer)));

    HelperScript helperScript = new HelperScript();
    helperScript.transferLink(consumer, linkTokenAddress, 100000000000000000000);

    string memory jobId = ffiScript.getJobId(nodeId, oracle);
    if (bytes(jobId).length != 0) {
      ffiScript.deleteJob(nodeId, jobId);
    }

    ffiScript.createDirectRequestJob(nodeId, oracle);

    jobId = ffiScript.getJobId(nodeId, oracle);
    console.logString(Utils.append("Job ID: ", jobId));

    string memory externalJobId = ffiScript.getExternalJobId(nodeId, oracle);
    console.logString(Utils.append("External Job ID: ", externalJobId));

    chainlinkConsumerScript.requestEthereumPrice(consumer, oracle, externalJobId);
  }
}
