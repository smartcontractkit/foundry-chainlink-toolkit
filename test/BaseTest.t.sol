// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
  bool private s_baseTestInitialized;

  uint256 internal OWNER_PRIVATE_KEY = 0x1;
  address internal OWNER_ADDRESS = vm.addr(OWNER_PRIVATE_KEY);

  uint256 internal STRANGER_PRIVATE_KEY = 0x2;
  address internal STRANGER_ADDRESS = vm.addr(STRANGER_PRIVATE_KEY);

  uint256 TX_GASPRICE_START = 3000000000; // 3 gwei

  uint72 constant JUELS_PER_LINK = 1e18;

  function setUp() public virtual {
    // BaseTest.setUp is often called multiple times from tests' setUp due to inheritance.
    if (s_baseTestInitialized) return;
    s_baseTestInitialized = true;
  }
}

// Compare this snippet from /lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/tests/v1_0_0/FunctionsTest.t.sol:
