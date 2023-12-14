// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "src/interfaces/functions/IFunctionsRouter.sol";

contract FunctionsRouterScript is Script {
  function run() external view {
    console.log("Please run deploy() method.");
  }

  function deploy(address linkTokenAddress) external returns(address) {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    uint32[] memory maxCallbackGasLimits = new uint32[](3);
    maxCallbackGasLimits[0] = 300_000;
    maxCallbackGasLimits[1] = 500_000;
    maxCallbackGasLimits[2] = 1_000_000;

    IFunctionsRouter.Config memory simulatedRouterConfig = IFunctionsRouter.Config({
      maxConsumersPerSubscription: 100,
      adminFee: 0,
      handleOracleFulfillmentSelector: 0x0ca76175, //bytes4(keccak256("handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err)")),
      gasForCallExactCheck: 5000,
      maxCallbackGasLimits: maxCallbackGasLimits,
      subscriptionDepositMinimumRequests: 0,
      subscriptionDepositJuels: 0
    });

    address functionsRouter = deployCode("FunctionsRouter.sol:FunctionsRouter", abi.encode(linkTokenAddress, simulatedRouterConfig));

    vm.stopBroadcast();

    return functionsRouter;
  }
}
