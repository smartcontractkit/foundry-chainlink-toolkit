// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";

import "../KeeperRegistry.s.sol";
import "../ChainlinkKeeperConsumer.s.sol";
import "../utils/Helper.s.sol";
import "./FFI.s.sol";

contract KeeperJobScript is Script {
  function run() external {
    FFIScript ffiScript = new FFIScript();

    address linkTokenAddress = vm.envAddress("LINK_CONTRACT_ADDRESS");

    KeeperRegistryScript registryScript = new KeeperRegistryScript();
    address registry = registryScript.deploy(linkTokenAddress);

    ChainlinkKeeperConsumerScript chainlinkKeeperConsumerScript = new ChainlinkKeeperConsumerScript();
    address keeperConsumer = chainlinkKeeperConsumerScript.deploy();
    console.logString(Utils.append(vm.toString(registry), Utils.append(",", vm.toString(keeperConsumer))));

    registryScript.registerUpkeep(registry, keeperConsumer);

    address[] memory nodeAddresses = new address[](5);
    for (uint i = 0; i < 5; i++) {
      address nodeAddress = ffiScript.getNodeAddress(vm.toString(i+1));
      nodeAddresses[i] = nodeAddress;
    }

    registryScript.setKeepers(registry, keeperConsumer, nodeAddresses);
  }

  function finalize(address registry, address keeperConsumer) external {
    FFIScript ffiScript = new FFIScript();
    KeeperRegistryScript registryScript = new KeeperRegistryScript();

    address linkTokenAddress = vm.envAddress("LINK_CONTRACT_ADDRESS");

    console.logString(Utils.append("Registry address: ", vm.toString(registry)));
    console.logString(Utils.append("Keeper Consumer address: ", vm.toString(keeperConsumer)));
    console.logString("");

    for (uint i = 0; i < 5; i++) {
      string memory nodeId = vm.toString(i+1);
      string memory jobId = ffiScript.getJobId(nodeId, registry);

      if (bytes(jobId).length != 0) {
        ffiScript.deleteJob(nodeId, jobId);
      }

      ffiScript.createKeeperJob(nodeId, registry);

      console.logString(Utils.append("Node ID: ", nodeId));

      jobId = ffiScript.getJobId(nodeId, registry);
      console.logString(Utils.append("Job ID: ", jobId));

      string memory externalJobId = ffiScript.getExternalJobId(nodeId, registry);
      console.logString(Utils.append("External Job ID: ", externalJobId));
      console.logString("");
    }

    registryScript.fundLatestUpkeep(registry, linkTokenAddress, 1000000000000000000);
  }
}
