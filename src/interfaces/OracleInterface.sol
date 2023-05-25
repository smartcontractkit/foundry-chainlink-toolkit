// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface OracleInterface {
  function setFulfillmentPermission(address _node, bool _allowed) external;
}
