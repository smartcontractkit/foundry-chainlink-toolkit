// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/libraries/TypesAndVersions.sol";
import "src/libraries/Utils.sol";

library AutomationGenerations {
  string public constant v1_0 = "v1_0";
  string public constant v2_0 = "v2_0";
  string public constant v2_1 = "v2_1";

  // Pick registry generation based on KeeperRegistry typeAndVersion
  function pickAutomationGeneration(string memory keeperRegistryTypeAndVersion) public pure returns (string memory) {
    if (Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry1_0) ||
      Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry1_1) ||
      Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry1_2) ||
      Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry1_3)) {
      return v1_0;
    } else if (Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry2_0) ||
      Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry2_0_1) ||
      Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry2_0_2)) {
      return v2_0;
    } else if (Utils.compareStrings(keeperRegistryTypeAndVersion, TypesAndVersions.KeeperRegistry2_1)) {
      return v2_1;
    } else {
      revert("Unsupported KeeperRegistry typeAndVersion");
    }
  }

  // check if registry generation is v1_0
  function isV1_0(string memory keeperRegistryTypeAndVersion) public pure returns (bool) {
    return Utils.compareStrings(pickAutomationGeneration(keeperRegistryTypeAndVersion), v1_0);
  }

  // check if registry generation is v2_0
  function isV2_0(string memory keeperRegistryTypeAndVersion) public pure returns (bool) {
    return Utils.compareStrings(pickAutomationGeneration(keeperRegistryTypeAndVersion), v2_0);
  }

  // check if registry generation is v2_1
  function isV2_1(string memory keeperRegistryTypeAndVersion) public pure returns (bool) {
    return Utils.compareStrings(pickAutomationGeneration(keeperRegistryTypeAndVersion), v2_1);
  }
}
