# Foundry Chainlink Toolkit

<br>
<p align="center">
  <a href="https://chain.link" target="_blank">
    <img src="https://raw.githubusercontent.com/smartcontractkit/foundry-starter-kit/main/img/chainlink-foundry.png" width="225" alt="Chainlink Foundry logo">
  </a>
</p>
<br/>

The Foundry Chainlink toolkit allows users to seamlessly interact with Chainlink services in their Foundry-based projects.
It provides atomic methods to interact with smart contracts related to Chainlink services: Data Feeds, VRF, Automation and Functions.
This plugin offers a convenient way to integrate Chainlink functionality into your web3 development workflow.

> **Warning**
>
> **This package is currently in the BETA testing phase and is not recommended for production usage yet.**
>
> **Open issues to submit bugs.**

## Installation
> **Note**  
If you are starting a new Foundry project, we recommend following the [Foundry Installation](https://book.getfoundry.sh/getting-started/installation) and [Foundry Getting Started](https://book.getfoundry.sh/getting-started/first-steps) documentation first.

The Foundry Chainlink toolkit has been designed so that it can be installed as a Forge dependency.  

To integrate it into your project, you need to run the following command:
```
forge install smartcontractkit/foundry-chainlink-toolkit
```

## Usage

The Foundry Chainlink plugin offers multiple ways to interact with Chainlink services,
giving you the flexibility to choose the approach that suits your workflow best.

> **Note**  
> Due to complex nature of embedded Solidity Scripts, compilation pipeline set to go through the new IR optimizer.
> This is done to avoid [stack too deep](https://docs.soliditylang.org/en/v0.8.21/security-considerations.html#call-stack-depth) errors.  
> Please consider setting [`via_ir` flag](https://book.getfoundry.sh/reference/config/solidity-compiler#via_ir) to `true` in your `foundry.toml` file.

### 1. Solidity Scripts

Interact with the Foundry Chainlink plugin using embedded Solidity Scripts:
```Solidity
import {Script} from "forge-std/Script.sol";
import "foundry-chainlink-toolkit/script/feeds/DataFeed.s.sol";

contract MyContract is Script {
  constructor() public {
    // Initialize a contract
  }

  function getLatestPrice(address dataFeedAddress) public returns (int256 latestPrice){
    DataFeedsScript automationScript = new DataFeedsScript(dataFeedAddress);

    vm.broadcast();
    (,latestPrice,,,) = DataFeedsScript.getLatestRoundData();
    return latestPrice;
  }
}
```

> **Note**  
> Foundry Solidity Scripting and Foundry EVM have limitations on passing context to nested scripts.
> That's why it is necessary to [broadcast](https://book.getfoundry.sh/cheatcodes/broadcast?highlight=broadcast#broadcast) signer before **each** call to Foundry Chainlink plugin.

### 2. CLI

Interact with the Foundry Chainlink plugin via CLI. 
For this purpose, special scripts have been prepared that allow user to use service methods in one call, initializing a script and invoking a method, e.g.:
```Solidity
import {Script} from "forge-std/Script.sol";
import "foundry-chainlink-toolkit/script/feeds/DataFeed.s.sol";

contract DataFeedsCLIScript is BaseScript {
  function getLatestRoundData(address dataFeedAddress) external returns(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
    DataFeedsScript dataFeedScript = new DataFeedsScript(dataFeedAddress);
    return dataFeedScript.getLatestRoundData();
  }
}
```

It makes possible calling the script from the command line:
```shell
forge foundry-chainlink-toolkit/script/feeds/DataFeed.CLI.s.sol --sig "getLatestRoundData(address)" $$dataFeedAddress
```

Examples of shell scripts invoking Chainlink services can be found in the Make file [makefile-external](makefile-external).

> **Note**  
> In order to run scripts properly, RPC node url and signer private key should be set either in the foundry.toml or through the [forge CLI parameters](https://book.getfoundry.sh/reference/forge/forge-script)

## Registries
The Foundry Chainlink toolkit provides registries that contain information about smart contracts related
to various Chainlink services and other data. You can find them in the [registries](src%2Fregistries%2Fjson) directory.  
"In order to use it in your Solidity scripts, please utilize the [Foundry Cheatcode to parse JSON files](https://book.getfoundry.sh/cheatcodes/parse-json?highlight=json#decoding-json-objects-into-solidity-structs).

## Sandbox
> **Note**
> Install [GNU make](https://www.gnu.org/software/make/) following the [Make documentation](https://www.gnu.org/software/make/manual/make.html).
> Install and run Docker; for convenience, the Chainlink nodes run in a container. Instructions: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/).

The `sandbox` module of Hardhat Chainlink plugin provides the ability to test dApps against Chainlink services locally.
The functionality of the sandbox is wrapped in the [sandbox makefile](makefile-sandbox).

### Configure your project
1. Give Forge permission to read the output directory of the plugin by adding this setting to the foundry.toml:
  ```
  fs_permissions = [{ access = "read", path = "lib/foundry-chainlink-toolkit/out"}]
  ```
  > **Note**  
  The default path to the root of the Foundry Chainlink toolkit is `lib/foundry-chainlink-toolkit`.  
  Unfortunately at the moment `foundry.toml` cannot read all environment variables. Specify a different path if necessary.

2. Incorporate the [makefile-sandbox](makefile-sandbox) into your project. To do this, create or update a makefile in the root of your project with:
  ```
  -include ${FCT_PLUGIN_PATH}/makefile-sandbox
  ```

### Configure RPC node
For local testing, we recommend using [Anvil](https://book.getfoundry.sh/anvil/), which is a part of the Foundry toolchain.  
You can run it using the following command:
```
make fct-anvil
```

For more information on this command, see the [sandbox documentation](SANDBOX.md#run-anvil).

> **Note**  
> If a local blockchain network has been restarted, you should run a [clean restart of a Chainlink cluster](SANDBOX#restart-a-chainlink-cluster) to avoid possible synchronization errors.

### Set up environment variables
Based on the [env.template](env.template) - create or update an `.env` file in the root directory of your project.
In most cases, you will not need to modify the default values specified in this file.

Below are comments on some environment variables:
- `FCT_PLUGIN_PATH` - path to the Foundry Chainlink toolkit root directory
- `ETH_URL` - RPC node web socket used by the Chainlink node
- `RPC_URL` - RPC node http endpoint used by Forge
- `PRIVATE_KEY` - private key of an account used for deployment and interaction with smart contracts. Once Anvil is started, a set of private keys for local usage is provided. Use one of these for local development
- `ROOT` - root directory of the Chainlink node
- `CHAINLINK_CONTAINER_NAME` - Chainlink node container name for the possibility of automating communication with it
- `COMPOSE_PROJECT_NAME` - Docker network project name for the possibility of automating communication with it, more on it: https://docs.docker.com/compose/environment-variables/envvars/#compose_project_name

> **Note**  
> If any environment variable related to a running Chainlink node was changed, e.g. Link Token contract address, you should run the ```make fct-run-nodes``` command in order to apply it.

### Manage local Chainlink node

Once local Chainlink node parameters are specified, Chainlink node could be started/restarted/stopped and managed with the plugin following the [sandbox documentation](SANDBOX.md#chainlink-nodes-management-scripts).
In order to login use credentials specified in [chainlink_api_credentials](src%2Fsandbox%2Fclroot%2Fsettings%2Fchainlink_api_credentials).

Alternatively, you can manage a Chainlink node either with Chainlink CLI or Chainlink node GUI.

#### Chainlink CLI

Chainlink node CLI is available directly on a machine running Chainlink node, so first you have to connect with `bash` to a Docker container to be able to run commands.

Here are some of the things you can do with the CLI:
* Create/Delete Chainlink Jobs
* Manage Chainlink accounts' transactions
* Manage Chainlink External Initiators
* See/Create Chainlink node's keys: ETH, OCR, P2P
* and more...

Here is example command to get list of ETH keys that are used by a Chainlink node:
```bash
chainlink keys eth list 
```
The most useful commands to manage Chainlink node with CLI you can find here: https://docs.chain.link/chainlink-nodes/resources/miscellaneous.

#### Chainlink GUI

Ports on which Chainlink GUIs are available are described in the [snadbox documentation](SANDBOX.md#initialize-testing-environment),
these ports are exposed with a docker-compose file to a host machine.

Here are some of the things you can do with the GUI:
* Create/Delete Chainlink Jobs
* Create Chainlink Bridge
* See Chainlink Jobs runs
* See Chainlink node's keys: ETH, OCR, P2P, VRF
* See Chainlink node's current configuration
* and more...

## Documentation

For detailed usage instructions and more information, refer to:
* [DOCUMENTATION.md](DOCUMENTATION.md) for interaction with Chainlink services;
* [SANDBOX.md](SANDBOX.md) for local testing in Sandbox.

## Contribution
We welcome contributions from the community.

If you find any issues, have suggestions for improvements, or want to add new features to the plugin,
please don't hesitate to open an issue or submit a pull request.

Your contributions help us improve the Foundry Chainlink toolkit and provide better tools for the entire community.

> **Note**  
> Foundry-Chainlink toolkit intended to support different compiler versions in range `[>=0.6.2 <0.9.0]`.  
> It was tested e2e with these solc versions:
> - 0.6.2
> - 0.6.12
> - 0.7.6
> - 0.8.9
> - 0.8.19
>
> Therefore, you can specify any supported Solidity compiler version in your foundry.toml.  
> In case you find any problems you are welcome to open an issue.
