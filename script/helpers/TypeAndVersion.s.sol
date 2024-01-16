// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";

import "src/interfaces/shared/TypeAndVersionInterface.sol";

contract TypeAndVersionScript is Script {
  /// @notice Returns the type and version of the contract at the given address
  function getTypeAndVersion(
    address contractAddress
  ) external view returns (string memory typeAndVersion) {
    TypeAndVersionInterface typeAndVersionInterface = TypeAndVersionInterface(contractAddress);
    return typeAndVersionInterface.typeAndVersion();
  }
}
