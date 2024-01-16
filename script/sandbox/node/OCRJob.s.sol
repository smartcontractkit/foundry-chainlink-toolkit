// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "../OffchainAggregator.s.sol";
import "../utils/Helper.s.sol";
import "./FFI.s.sol";

contract OCRJobScript is Script {
  function run() public {
    FFIScript ffiScript = new FFIScript();

    address linkTokenAddress = vm.envAddress("LINK_CONTRACT_ADDRESS");

    OffchainAggregatorScript offchainAggregatorScript = new OffchainAggregatorScript();
    address offchainAggregator = offchainAggregatorScript.deploy(linkTokenAddress);
    console.logString(vm.toString(offchainAggregator));

    string[] memory nodeAddresses = new string[](4);
    string[] memory onChainSigningAddresses = new string[](4);
    string[] memory offChainPublicKeys = new string[](4);
    string[] memory configPublicKeys = new string[](4);
    string[] memory peerIds = new string[](4);

    // Getting configurations for Oracle nodes [2-5]
    for (uint i = 0; i < 4; i++) {
      string[] memory nodeConfig = ffiScript.getNodeConfig(vm.toString(i+2));
      nodeAddresses[i] = nodeConfig[0];
      onChainSigningAddresses[i] = nodeConfig[1];
      offChainPublicKeys[i] = nodeConfig[2];
      configPublicKeys[i] = nodeConfig[3];
      peerIds[i] = nodeConfig[4];
    }

    offchainAggregatorScript.setPayees(offchainAggregator, nodeAddresses);

    string[] memory ocrConfig = ffiScript.getOcrConfig(
      Utils.concat(nodeAddresses, ","),
      Utils.concat(onChainSigningAddresses, ","),
      Utils.concat(offChainPublicKeys, ","),
      Utils.concat(configPublicKeys, ","),
      Utils.concat(peerIds, ",")
    );
    vm.setEnv("SIGNERS", Utils.trim(ocrConfig[0], 1));
    vm.setEnv("TRANSMITTERS", Utils.trim(ocrConfig[1], 1));
    vm.setEnv("THRESHOLD", ocrConfig[2]);
    vm.setEnv("CONFIG_VERSION", ocrConfig[3]);
    vm.setEnv("ENCODED", ocrConfig[4]);

    offchainAggregatorScript.setConfig(
      offchainAggregator,
      vm.envAddress("SIGNERS", ","),
      vm.envAddress("TRANSMITTERS", ","),
      uint8(vm.envUint("THRESHOLD")),
      uint64(vm.envUint("CONFIG_VERSION")),
      vm.envBytes("ENCODED")
    );
  }

  function finalize(address offchainAggregator) external {
    FFIScript ffiScript = new FFIScript();

    console.logString(Utils.append("Offchain Aggregator address: ", vm.toString(offchainAggregator)));
    console.logString("");

    // Creating OCR (bootstrap) Job
    console.logString("Bootstrap Node");
    console.logString("--------------");
    console.logString("");

    string memory bootstrapNodeId = "1";
    string memory bootstrapJobId = ffiScript.getJobId(bootstrapNodeId, offchainAggregator);

    if (bytes(bootstrapJobId).length != 0) {
      ffiScript.deleteJob(bootstrapNodeId, bootstrapJobId);
    }

    ffiScript.createOcrBootstrapJob(bootstrapNodeId, offchainAggregator);

    console.logString(Utils.append("Node ID: ", "1"));

    bootstrapJobId = ffiScript.getJobId(bootstrapNodeId, offchainAggregator);
    console.logString(Utils.append("Job ID: ", bootstrapJobId));

    string memory bootstrapExternalJobId = ffiScript.getExternalJobId(bootstrapNodeId, offchainAggregator);
    console.logString(Utils.append("External Job ID: ", bootstrapExternalJobId));
    console.logString("");

    // Getting configurations of bootstrap node
    string[] memory nodeConfig = ffiScript.getNodeConfig(bootstrapNodeId);
    string memory bootstrapPeerId = nodeConfig[4];

    // Creating OCR Jobs
    console.logString("Oracle Nodes");
    console.logString("--------------");
    console.logString("");

    for (uint i = 0; i < 4; i++) {
      string memory nodeId = vm.toString(i+2);
      string memory jobId = ffiScript.getJobId(nodeId, offchainAggregator);

      if (bytes(jobId).length != 0) {
        ffiScript.deleteJob(nodeId, jobId);
      }

      ffiScript.createOcrJob(nodeId, offchainAggregator, bootstrapPeerId);

      console.logString(Utils.append("Node ID: ", nodeId));

      jobId = ffiScript.getJobId(nodeId, offchainAggregator);
      console.logString(Utils.append("Job ID: ", jobId));

      string memory externalJobId = ffiScript.getExternalJobId(nodeId, offchainAggregator);
      console.logString(Utils.append("External Job ID: ", externalJobId));
      console.logString("");
    }
  }
}
