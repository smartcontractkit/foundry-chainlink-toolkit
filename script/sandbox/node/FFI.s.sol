// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "src/libraries/Utils.sol";

contract FFIScript is Script {
  function run() external view {
    console.log("Please run any implemented method.");
  }

  function getNodeAddress(string memory nodeId) public returns(address) {
    string[] memory cmds = new string[](3);
    cmds[0] = "make";
    cmds[1] = "fct-get-node-address";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    bytes memory nodeAddress = vm.ffi(cmds);
    return Utils.bytesToAddress(nodeAddress);
  }

  function getNodeConfig(string memory nodeId) public returns(string[] memory) {
    string[] memory cmds = new string[](3);
    cmds[0] = "make";
    cmds[1] = "fct-get-node-config";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    bytes memory res = vm.ffi(cmds);
    // NOTE: workaround to split node configuration string
    vm.setEnv("NODE_CONFIG", string(res));
    string[] memory nodeConfig = vm.envString("NODE_CONFIG",",");
    return nodeConfig;
  }

  function getOcrConfig(
    string memory nodeAddressesStr,
    string memory onChainSigningAddressesStr,
    string memory offChainPublicKeysStr,
    string memory configPublicKeysStr,
    string memory peerIdsStr
  ) public returns(string[] memory) {
    string[] memory cmds = new string[](7);
    cmds[0] = "make";
    cmds[1] = "fct-prepare-ocr-config";
    cmds[2] = Utils.append("NODE_ADDRESSES=", nodeAddressesStr);
    cmds[3] = Utils.append("OFFCHAIN_PUBLIC_KEYS=", offChainPublicKeysStr);
    cmds[4] = Utils.append("CONFIG_PUBLIC_KEYS=", configPublicKeysStr);
    cmds[5] = Utils.append("ONCHAIN_SIGNING_ADDRESSES=", onChainSigningAddressesStr);
    cmds[6] = Utils.append("PEER_IDS=", peerIdsStr);
    bytes memory res = vm.ffi(cmds);
    // NOTE: workaround to split ocr configuration string
    vm.setEnv("OCR_CONFIG", string(res));
    string[] memory ocrConfig = vm.envString("OCR_CONFIG"," ");
    return ocrConfig;
  }

  function getJobId(string memory nodeId, address contractAddress) public returns(string memory) {
    string[] memory cmds = new string[](5);
    string memory prefix = "0_";
    cmds[0] = "make";
    cmds[1] = "fct-get-job-id";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("CONTRACT_ADDRESS=", vm.toString(contractAddress));
    cmds[4] = Utils.append("PREFIX=", prefix);
    bytes memory jobId = vm.ffi(cmds);
    return Utils.removePrefix(prefix, string(jobId));
  }

  function getExternalJobId(string memory nodeId, address contractAddress) public returns(string memory) {
    string[] memory cmds = new string[](4);
    string memory prefix = "0x";
    cmds[0] = "make";
    cmds[1] = "fct-get-external-job-id";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("CONTRACT_ADDRESS=", vm.toString(contractAddress));
    bytes memory externalJobId = vm.ffi(cmds);
    return Utils.removePrefix(prefix, vm.toString(externalJobId));
  }

  function getLastWebhookJobId(string memory nodeId) public returns(string memory) {
    string[] memory cmds = new string[](4);
    string memory prefix = "0_";
    cmds[0] = "make";
    cmds[1] = "fct-get-last-webhook-job-id";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("PREFIX=", prefix);
    bytes memory jobId = vm.ffi(cmds);
    return Utils.removePrefix(prefix, string(jobId));
  }

  function createDirectRequestJob(string memory nodeId, address oracle) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-create-direct-request-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("ORACLE_ADDRESS=", vm.toString(oracle));
    vm.ffi(cmds);
  }

  function createCronJob(string memory nodeId, address cronConsumer) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-create-cron-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("CRON_CONSUMER_ADDRESS=", vm.toString(cronConsumer));
    vm.ffi(cmds);
  }

  function createWebhookJob(string memory nodeId) public {
    string[] memory cmds = new string[](3);
    cmds[0] = "make";
    cmds[1] = "fct-create-webhook-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    vm.ffi(cmds);
  }

  function createKeeperJob(string memory nodeId, address registry) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-create-keeper-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("REGISTRY_ADDRESS=", vm.toString(registry));
    vm.ffi(cmds);
  }

  function createFluxJob(string memory nodeId, address fluxAggregator) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-create-flux-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("FLUX_AGGREGATOR_ADDRESS=", vm.toString(fluxAggregator));
    vm.ffi(cmds);
  }

  function createOcrBootstrapJob(string memory nodeId, address offchainAggregator) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-create-ocr-bootstrap-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("OFFCHAIN_AGGREGATOR_ADDRESS=", vm.toString(offchainAggregator));
    vm.ffi(cmds);
  }

  function createOcrJob(string memory nodeId, address offchainAggregator, string memory bootstrapPeerId) public {
    string[] memory cmds = new string[](5);
    cmds[0] = "make";
    cmds[1] = "fct-create-ocr-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("OFFCHAIN_AGGREGATOR_ADDRESS=", vm.toString(offchainAggregator));
    cmds[4] = Utils.append("BOOTSTRAP_P2P_KEY=", bootstrapPeerId);
    vm.ffi(cmds);
  }

  function runWebhookJob(string memory nodeId, string memory jobId) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-run-webhook-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("WEBHOOK_JOB_ID=", jobId);
    vm.ffi(cmds);
  }

  function deleteJob(string memory nodeId, string memory jobId) public {
    string[] memory cmds = new string[](4);
    cmds[0] = "make";
    cmds[1] = "fct-delete-job";
    cmds[2] = Utils.append("NODE_ID=", nodeId);
    cmds[3] = Utils.append("JOB_ID=", jobId);
    vm.ffi(cmds);
  }
}
