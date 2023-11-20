// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

library Utils {
  function bytesToAddress(bytes memory bys) internal pure returns(address addr) {
    assembly {
      addr := mload(add(bys,20))
    }
  }

  // Prefix must be two bytes long
  function removePrefix(string memory prefix, string memory value) internal pure returns(string memory) {
    if (bytes(value).length >= 2 && bytes(value)[0] == bytes(prefix)[0] && bytes(value)[1] == bytes(prefix)[1]) {
      return substring(value, 2);
    }
    return value;
  }

  function substring(string memory str, uint startIndex) internal pure returns(string memory) {
    bytes memory strBytes = bytes(str);
    require(startIndex <= strBytes.length, "Invalid start index");
    bytes memory result = new bytes(strBytes.length - startIndex);
    for (uint i = startIndex; i < strBytes.length; i++) {
      result[i - startIndex] = strBytes[i];
    }
    return string(result);
  }

  function trim(string memory str, uint count) internal pure returns(string memory) {
    if (count < 1) {
      return str;
    }
    bytes memory strBytes = bytes(str);
    require((2 * count) <= strBytes.length, "Invalid count");
    bytes memory result = new bytes(strBytes.length - (2 * count));
    for (uint i = count; i < (strBytes.length - count); i++) {
      result[i - count] = strBytes[i];
    }
    return string(result);
  }

  function append(string memory a, string memory b) internal pure returns(string memory) {
    return string(abi.encodePacked(a, b));
  }

  function concat(string[] memory stringArray, string memory delimiter) internal pure returns(string memory) {
    string memory result = "";
    if (stringArray.length == 0) {
      return result;
    }
    for (uint i; i < (stringArray.length - 1); i++) {
      result = append(result, append(stringArray[i], delimiter));
    }
    return append(result, stringArray[stringArray.length - 1]);
  }

  function compareStrings(string memory a, string memory b) internal pure returns(bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
    // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }
}
