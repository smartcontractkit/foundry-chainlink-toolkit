# include .env file and export its env vars
# (-include to ignore error if it does not exist)
include .env

# exclude this .SILENT target to display all command lines
.SILENT:

# Helpers Scripts
check_defined = \
    $(strip $(foreach 1,$1, \
    $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
    $(error Undefined env variable $1$(if $2, ($2))))

define check_set_parameter
	if [ -n "$($1)" ]; then \
		$2=$($1); \
    else \
		$2=$$(read -p "Please enter a value for $1: " param && echo "$$param"); \
    fi;
endef

define get_chainlink_container_name
	$2=$(CHAINLINK_CONTAINER_NAME)$(strip $1);
endef

define get_node_address
	$2=$$(docker exec $1 chainlink -j keys eth list | grep "address" | cut -d'"' -f4 | sed 's/\"//g');
endef

install:
	forge install foundry-rs/forge-std --no-commit; \
	forge install smartcontractkit/chainlink --no-commit; \
	forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Chainlink Nodes Management Scripts
run-nodes:
	$(call check_defined, ROOT) \
	$(call check_defined, ETH_CHAIN_ID) \
	$(call check_defined, ETH_URL) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_defined, POSTGRES_USER) \
	$(call check_defined, POSTGRES_PASSWORD) \
	$(call check_defined, LINK_CONTRACT_ADDRESS) \
	docker compose up -d

restart-nodes:
	$(call check_defined, ROOT) \
	$(call check_defined, ETH_CHAIN_ID) \
	$(call check_defined, ETH_URL) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_defined, POSTGRES_USER) \
	$(call check_defined, POSTGRES_PASSWORD) \
	$(call check_defined, LINK_CONTRACT_ADDRESS) \
	docker compose -f docker-compose-cluster.yaml restart

login:
	$(call check_defined, ROOT) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	printf "%s\n" "Logging in Chainlink Node..."; \
	docker exec $$chainlinkContainerName chainlink admin login -f ${ROOT}/chainlink_api_credentials

get-node-info:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	docker exec $$chainlinkContainerName chainlink -j keys eth list

# Smart Contracts Deployment Scripts
deploy-link-token:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Link Token contract. Please wait..."; \
	forge script ./script/LinkToken.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast --silent

deploy-oracle:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	printf "%s\n" "Deploying Oracle contract. Please wait..."; \
	forge script ./script/Oracle.s.sol --sig "deploy(address, address)" $$linkContractAddress $$nodeAddress --rpc-url ${RPC_URL} --broadcast --silent

deploy-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink Direct Request Consumer. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast --silent

deploy-cron-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Chainlink Cron Consumer. Please wait..."; \
	forge script ./script/ChainlinkCronConsumer.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast --silent

deploy-keeper-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Chainlink Keeper Consumer. Please wait..."; \
	forge script ./script/ChainlinkKeeperConsumer.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast --silent

deploy-keeper-registry:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink Registry. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast --silent

# Helper Scripts
transfer-eth:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,RECIPIENT,recipient) \
	printf "%s\n" "Transferring ETH to the $$recipient. Please wait..."; \
	forge script ./script/Helper.s.sol --sig "transferEth(address, uint256)" $$recipient 1000000000000000000 --rpc-url ${RPC_URL} --broadcast --silent

transfer-eth-to-node:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	make transfer-eth RECIPIENT=$$nodeAddress;

transfer-link:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	$(call check_set_parameter,RECIPIENT,recipient) \
	printf "%s\n" "Transferring Link Tokens to $$recipient. Please wait..."; \
	forge script ./script/Helper.s.sol --sig "transferLink(address, address, uint256)" $$recipient $$linkContractAddress 100000000000000000000 --rpc-url ${RPC_URL} --broadcast --silent

transfer-link-to-node:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	make transfer-link RECIPIENT=$$nodeAddress;

# Chainlink Jobs Scripts
create-direct-request-job:
	$(call check_set_parameter,ORACLE_ADDRESS,oracleAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/direct_request_job_tmp.toml \
	&& sed 's/ORACLE_ADDRESS/$$oracleAddress/g' ${ROOT}/direct_request_job.toml > ${ROOT}/direct_request_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/direct_request_job_tmp.toml && rm ${ROOT}/direct_request_job_tmp.toml"

create-cron-job:
	$(call check_set_parameter,CRON_CONSUMER_ADDRESS,cronConsumerAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/cron_job_tmp.toml \
	&& sed 's/CONSUMER_ADDRESS/$$cronConsumerAddress/g' ${ROOT}/cron_job.toml > ${ROOT}/cron_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/cron_job_tmp.toml && rm ${ROOT}/cron_job_tmp.toml"

create-webhook-job:
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/webhook_job_tmp.toml \
	&& sed 's/CONSUMER_ADDRESS/$$consumerAddress/g' ${ROOT}/webhook_job.toml > ${ROOT}/webhook_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/webhook_job_tmp.toml && rm ${ROOT}/webhook_job_tmp.toml"

create-keeper-job:
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/keeper_job_tmp.toml \
	&& sed -e 's/REGISTRY_ADDRESS/$$registryAddress/g' -e 's/NODE_ADDRESS/$$nodeAddress/g' ${ROOT}/keeper_job.toml > ${ROOT}/keeper_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/keeper_job_tmp.toml && rm ${ROOT}/keeper_job_tmp.toml"

create-keeper-jobs:
	make create-keeper-job NODE_ID=1 && \
	make create-keeper-job NODE_ID=2 && \
	make create-keeper-job NODE_ID=3 && \
	make create-keeper-job NODE_ID=4;

# Chainlink Consumer Scripts
request-eth-price-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	$(call check_set_parameter,ORACLE_ADDRESS,oracleAddress) \
	$(call check_set_parameter,JOB_ID,jobId) \
	printf "%s\n" "Requesting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "requestEthereumPrice(address, address, string)" $$consumerAddress $$oracleAddress $$jobId --rpc-url ${RPC_URL} --broadcast --silent

get-eth-price-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	echo "Getting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "getEthereumPrice(address)" $$consumerAddress --rpc-url ${RPC_URL} --broadcast --silent

# Chainlink Cron Consumer Scripts
get-eth-price-cron-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CRON_CONSUMER_ADDRESS,cronConsumerAddress) \
	echo "Getting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkCronConsumer.s.sol --sig "getEthereumPrice(address)" $$cronConsumerAddress --rpc-url ${RPC_URL} --broadcast --silent

# Chainlink Registry Scripts
register-upkeep:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	echo "Registering Upkeep in the Chainlink Registry. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "registerUpkeep(address,address,address,uint256)" $$registryAddress $$keeperConsumerAddress $$linkContractAddress 1000000000000000000000 --rpc-url ${RPC_URL} --broadcast --silent

set-keepers:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	make login NODE_ID=1 && \
	$(call get_node_address, $(CHAINLINK_CONTAINER_NAME)1,nodeAddress1) \
	make login NODE_ID=2 && \
	$(call get_node_address, $(CHAINLINK_CONTAINER_NAME)2,nodeAddress2) \
	make login NODE_ID=3 && \
	$(call get_node_address, $(CHAINLINK_CONTAINER_NAME)3,nodeAddress3) \
	make login NODE_ID=4 && \
	$(call get_node_address, $(CHAINLINK_CONTAINER_NAME)4,nodeAddress4) \
	printf "%s\n" "Setting Keepers in Registry. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "setKeepers(address,address,address[])" $$registryAddress $$keeperConsumerAddress [$$nodeAddress1,$$nodeAddress2,$$nodeAddress3,$$nodeAddress4] --rpc-url ${RPC_URL} --broadcast --silent

get-last-active-upkeep-id:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	echo "Getting active Upkeep ids. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "getLastActiveUpkeepID(address)" $$registryAddress --rpc-url ${RPC_URL} --broadcast --silent

# Chainlink Keeper Consumer Scripts
get-keeper-counter:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	echo "Getting current counter. Please wait..."; \
	forge script ./script/ChainlinkKeeperConsumer.s.sol --sig "getCounter(address)" $$keeperConsumerAddress --rpc-url ${RPC_URL} --broadcast --silent

# Link Token Script
transfer-and-call-link:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,UPKEEP_ID,upkeepId) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	echo "Transferring Link Tokens to the recipient. Please wait..."; \
	forge script ./script/LinkToken.s.sol --sig "transferAndCall(address, address, uint256, uint256)" $$linkContractAddress $$registryAddress 1000000000000000000 $$upkeepId --rpc-url ${RPC_URL} --broadcast -vvvv \
