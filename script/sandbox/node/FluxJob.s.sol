// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "../FluxAggregator.s.sol";
import "../utils/Helper.s.sol";
import "./FFI.s.sol";

contract FluxJobScript is Script {
  function run() public {
    FFIScript ffiScript = new FFIScript();

    address linkTokenAddress = vm.envAddress("LINK_CONTRACT_ADDRESS");

    FluxAggregatorScript fluxAggregatorScript = new FluxAggregatorScript();
    address fluxAggregator = fluxAggregatorScript.deploy(linkTokenAddress);
    console.logString(vm.toString(fluxAggregator));

    HelperScript helperScript = new HelperScript();
    helperScript.transferLink(fluxAggregator, linkTokenAddress, 100000000000000000000);

    fluxAggregatorScript.updateAvailableFunds(fluxAggregator);

    address[] memory nodeAddresses = new address[](3);

    for (uint i = 0; i < 3; i++) {
      address nodeAddress = ffiScript.getNodeAddress(vm.toString(i+1));
      nodeAddresses[i] = nodeAddress;
    }

    fluxAggregatorScript.setOracles(fluxAggregator, nodeAddresses);
  }

  function finalize(address fluxAggregator) external {
    FFIScript ffiScript = new FFIScript();

    console.logString(Utils.append("Flux Aggregator address: ", vm.toString(fluxAggregator)));
    console.logString("");

    for (uint i = 0; i < 3; i++) {
      string memory nodeId = vm.toString(i+1);
      string memory jobId = ffiScript.getJobId(nodeId, fluxAggregator);

      if (bytes(jobId).length != 0) {
        ffiScript.deleteJob(nodeId, jobId);
      }

      ffiScript.createFluxJob(nodeId, fluxAggregator);

      console.logString(Utils.append("Node ID: ", nodeId));

      jobId = ffiScript.getJobId(nodeId, fluxAggregator);
      console.logString(Utils.append("Job ID: ", jobId));

      string memory externalJobId = ffiScript.getExternalJobId(nodeId, fluxAggregator);
      console.logString(Utils.append("External Job ID: ", externalJobId));
      console.logString("");
    }
  }
}
