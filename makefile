# include .env file and export its env vars
# (-include to ignore error if it does not exist)
include .env

# Default values
# You can override it with .env or by passing it as a parameter to a target
CONTAINERS_COUNT ?= 8

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

# Reading only the first eth key list
define get_node_address
	$2=$$(docker exec $1 chainlink -j keys eth list | grep -m1 -o '"address": "[^"]*"' | head -1 | cut -d'"' -f4);
endef

# Reading only the first ocr key list
define get_ocr_keys
	temp=$$(docker exec $1 chainlink -j keys ocr list); \
	$2=$$(echo $$temp | grep -m1 -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4); \
	$3=$$(echo $$temp | grep -m1 -o '"onChainSigningAddress": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -d'_' -f2); \
	$4=$$(echo $$temp | grep -m1 -o '"offChainPublicKey": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -d'_' -f2); \
	$5=$$(echo $$temp | grep -m1 -o '"configPublicKey": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -d'_' -f2);
endef

# Reading only the first p2p key list
define get_p2p_keys
	temp=$$(docker exec $1 chainlink -j keys p2p list); \
	$2=$$(echo $$temp | grep -m 1 -o '"peerId": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -d'_' -f2); \
	$3=$$(echo $$temp | grep -m 1 -o '"publicKey": "[^"]*"' | head -1 | cut -d'"' -f4);
endef

# Reading only the first matched job id
define get_job_id
	$3=$$(docker exec $1 chainlink -j jobs list | grep -o -B 1 '"name": "[^"]*"' | grep -m 1 -B 1 -F "$2" | grep -o '"id": "[^"]*"' | cut -d'"' -f4);
endef

define get_external_job_id
	$3=$$(docker exec $1 chainlink -j jobs list | grep -o -A 6 '"name": "[^"]*"' | grep -m 1 -A 6 -F "$2" | grep -o '"externalJobID": "[^"]*"' | cut -d'"' -f4 | tr -d '-');
endef

define get_last_webhook_job_id
	$2=$$(docker exec $1 chainlink -j jobs list | grep -o -B 2 '"type": "[^"]*"' | grep -m 1 -B 2 -F "webhook" | grep -o '"id": "[^"]*"' | cut -d'"' -f4);
endef

define get_cookie
	$2=$$(cat ./chainlink/$1/cookie | grep "clsession");
endef

define format_eip55_address
	$2=$$(forge script ./script/Helper.s.sol --sig "formatAddress(address)" $1 | tail -c 43);
endef

# Set OCRHelperPath variable
ifeq ($(shell uname), Darwin)
# Set variable for MacOS
	ifeq ($(shell uname -m), amd64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-darwin-amd64
	else ifeq ($(shell uname -m), x86_64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-darwin-amd64
	else ifeq ($(shell uname -m), arm64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-darwin-arm64
	endif
else ifeq ($(shell uname), Linux)
# Set variable for Linux
	ifeq ($(shell uname -m), amd64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-linux-amd64
	else ifeq ($(shell uname -m), x86_64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-linux-amd64
	else ifeq ($(shell uname -m), arm)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-linux-arm
	else ifeq ($(shell uname -m), arm64)
	OCRHelperPath = external/OCRHelper/bin/ocr-helper-linux-arm64
	endif
else
# Set variable for other operating systems, binary has to be built in advance
	OCRHelperPath = external/OCRHelper/bin/ocr-helper
endif

OCRHelperPathWildcard = "$(wildcard ${PWD}/${OCRHelperPath})"

get-ocr-config:
	$(call check_defined, NODE_ADDRESSES) \
	$(call check_defined, OFFCHAIN_PUBLIC_KEYS) \
	$(call check_defined, CONFIG_PUBLIC_KEYS) \
	$(call check_defined, ONCHAIN_SIGNING_ADDRESSES) \
	$(call check_defined, PEER_IDS) \
	$(eval OCR_CONFIG=$(shell $(OCRHelperPath) \
		$(NODE_ADDRESSES) \
		$(OFFCHAIN_PUBLIC_KEYS) \
		$(CONFIG_PUBLIC_KEYS) \
		$(ONCHAIN_SIGNING_ADDRESSES) \
		$(PEER_IDS))) \
	echo "$(OCR_CONFIG)"

install:
	forge install foundry-rs/forge-std --no-git --no-commit; \
	forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-git --no-commit; \
	forge install smartcontractkit/chainlink-testing-framework@v1.11.5 --no-git --no-commit; \
	forge install OpenZeppelin/openzeppelin-contracts@v4.8.2 --no-git --no-commit

anvil:
	anvil --block-time 10 --chain-id 1337 -m 'test test test test test test test test test test test junk'

# Build Chainlink contracts:
# Forge can not build individual contracts in a directory, so,
# During script execution, necessary contracts are copied to the `tmp` directory,
# Relative dependencies paths are being replaced with the new ones,
# Contracts are compiled with the required compiler version
build-chainlink-contracts:
	printf "%s\n" "Building Chainlink contracts..."; \
	mkdir -p tmp; \
	touch ./tmp/Oracle.sol && \
	touch ./tmp/FluxAggregator.sol && \
	sed -e 's/import ".\//import "@chainlink\/v0.6\//g' ./lib/chainlink-brownie-contracts/contracts/src/v0.6/Oracle.sol > ./tmp/Oracle.sol; \
	sed -e 's/import ".\//import "@chainlink-testing\/v0.6\/src\//g' ./lib/chainlink-testing-framework/contracts/ethereum/v0.6/src/FluxAggregator.sol > ./tmp/FluxAggregator.sol; \
	forge build --contracts ./tmp/ --skip script test --names --use solc:0.6.6; \
	rm ./tmp/Oracle.sol; \
	rm ./tmp/FluxAggregator.sol; \
	touch ./tmp/LinkToken.sol && \
	cat ./chainlink/contracts/LinkToken.sol > ./tmp/LinkToken.sol; \
	forge build --contracts ./tmp/ --skip script test --names --use solc:0.6.12; \
	rm ./tmp/LinkToken.sol; \
	touch ./tmp/OffchainAggregator.sol && \
	sed -e 's/import ".\//import "@chainlink-testing\/v0.7\/src\//g' ./lib/chainlink-testing-framework/contracts/ethereum/v0.7/src/OffchainAggregator.sol > ./tmp/OffchainAggregator.sol; \
	forge build --contracts ./tmp/ --skip script test --names --use solc:0.7.6; \
	rm ./tmp/OffchainAggregator.sol; \
	touch ./tmp/KeeperRegistry1_3.sol && \
	touch ./tmp/KeeperRegistryLogic1_3.sol && \
	sed -e 's/import ".\//import "@chainlink\/v0.8\//g' -e 's/from ".\//from "@chainlink\/v0.8\//g' ./lib/chainlink-brownie-contracts/contracts/src/v0.8/KeeperRegistry1_3.sol > ./tmp/KeeperRegistry1_3.sol; \
	sed -e 's/import ".\//import "@chainlink\/v0.8\//g' -e 's/from ".\//from "@chainlink\/v0.8\//g' ./lib/chainlink-brownie-contracts/contracts/src/v0.8/KeeperRegistryLogic1_3.sol > ./tmp/KeeperRegistryLogic1_3.sol; \
	forge build --contracts ./tmp/ --skip script test --names --use solc:0.8.6; \
	rm ./tmp/KeeperRegistry1_3.sol; \
	rm ./tmp/KeeperRegistryLogic1_3.sol; \
	touch ./tmp/ChainlinkConsumer.sol && \
	touch ./tmp/ChainlinkCronConsumer.sol && \
	touch ./tmp/ChainlinkKeeperConsumer.sol && \
	cat ./chainlink/contracts/ChainlinkConsumer.sol > ./tmp/ChainlinkConsumer.sol; \
	cat ./chainlink/contracts/ChainlinkCronConsumer.sol > ./tmp/ChainlinkCronConsumer.sol; \
	cat ./chainlink/contracts/ChainlinkKeeperConsumer.sol > ./tmp/ChainlinkKeeperConsumer.sol; \
	forge build --contracts ./tmp/ --skip script test --names --use solc:0.8.12; \
	rm ./tmp/ChainlinkConsumer.sol; \
	rm ./tmp/ChainlinkCronConsumer.sol; \
	rm ./tmp/ChainlinkKeeperConsumer.sol; \
	rm -rf tmp; \
	printf "%s\n" "Done";

# Build external libraries
build-ocr-helper:
	cd ./external/OCRHelper && go build -o bin/ocr-helper;

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
	if [ -n "$(CLEAN_RESTART)" ]; then \
		docker compose down; \
		docker volume rm foundry-chainlink-plugin_prometheus_data; \
		rm -rf ./chainlink/foundry-chainlink-node*; \
		docker compose up -d; \
	else \
		docker compose restart; \
	fi

check-docker-network:
	$(call check_defined, COMPOSE_PROJECT_NAME) \
	bash ./chainlink/check-docker-network.sh "${COMPOSE_PROJECT_NAME}_default" $(CONTAINERS_COUNT);

login:
	$(call check_defined, ROOT) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	printf "%s\n" "Logging in Chainlink Node $$nodeId..."; \
	docker exec $$chainlinkContainerName chainlink admin login -f ${ROOT}/settings/chainlink_api_credentials

get-eth-keys:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	docker exec $$chainlinkContainerName chainlink -j keys eth list

get-ocr-keys:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	docker exec $$chainlinkContainerName chainlink -j keys ocr list

get-p2p-keys:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	docker exec $$chainlinkContainerName chainlink -j keys p2p list

get-node-address:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	printf "%s" $$nodeAddress

get-node-config:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	$(call get_ocr_keys,$$chainlinkContainerName,_,onChainSigningAddress,offChainPublicKey,configPublicKey) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId,_) \
	printf "%s" "$$nodeAddress,$$onChainSigningAddress,$$offChainPublicKey,$$configPublicKey,$$peerId"

get-job-id:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call check_set_parameter,CONTRACT_ADDRESS,contractAddress) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call format_eip55_address,$$contractAddress,contractAddressFormatted) \
	$(call get_job_id,$$chainlinkContainerName,$$contractAddressFormatted,jobId) \
	printf "%s" "${PREFIX}$$jobId"

get-external-job-id:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call check_set_parameter,CONTRACT_ADDRESS,contractAddress) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call format_eip55_address,$$contractAddress,contractAddressFormatted) \
	$(call get_external_job_id,$$chainlinkContainerName,$$contractAddressFormatted,externalJobId) \
	printf "%s" $$externalJobId

get-last-webhook-job-id:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_last_webhook_job_id,$$chainlinkContainerName,jobId) \
	printf "%s" "${PREFIX}$$jobId"

# Smart Contracts Deployment Scripts
deploy-link-token:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Link Token contract. Please wait..."; \
	forge script ./script/LinkToken.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast

deploy-oracle:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	printf "%s\n" "Deploying Oracle contract. Please wait..."; \
	forge script ./script/Oracle.s.sol --sig "deploy(address, address)" $$linkContractAddress $$nodeAddress --rpc-url ${RPC_URL} --broadcast

deploy-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink Direct Request Consumer. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast

deploy-cron-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Chainlink Cron Consumer. Please wait..."; \
	forge script ./script/ChainlinkCronConsumer.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast

deploy-keeper-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	printf "%s\n" "Deploying Chainlink Keeper Consumer. Please wait..."; \
	forge script ./script/ChainlinkKeeperConsumer.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast

deploy-keeper-registry:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink Registry. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast

deploy-offchain-aggregator:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink OffChain Aggregator. Please wait..."; \
	forge script ./script/OffchainAggregator.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast

deploy-flux-aggregator:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Deploying Chainlink Flux Aggregator. Please wait..."; \
	forge script ./script/FluxAggregator.s.sol --sig "deploy(address)" $$linkContractAddress --rpc-url ${RPC_URL} --broadcast

# Chainlink Jobs Scripts
create-direct-request-job:
	$(call check_set_parameter,ORACLE_ADDRESS,oracleAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call format_eip55_address,$$oracleAddress,oracleAddressFormatted) \
	printf "%s\n" "Creating Direct Request Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/direct_request_job_tmp.toml \
	&& sed 's/ORACLE_ADDRESS/$$oracleAddressFormatted/g' ${ROOT}/jobs/direct_request_job.toml > ${ROOT}/jobs/direct_request_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/direct_request_job_tmp.toml && rm ${ROOT}/jobs/direct_request_job_tmp.toml"

create-cron-job:
	$(call check_set_parameter,CRON_CONSUMER_ADDRESS,consumerAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call format_eip55_address,$$consumerAddress,consumerAddressFormatted) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	printf "%s\n" "Creating Cron Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/cron_job_tmp.toml \
	&& sed 's/CONSUMER_ADDRESS/$$consumerAddressFormatted/g' ${ROOT}/jobs/cron_job.toml > ${ROOT}/jobs/cron_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/cron_job_tmp.toml && rm ${ROOT}/jobs/cron_job_tmp.toml"

create-webhook-job:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	printf "%s\n" "Creating Webhook Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/webhook_job.toml"

run-webhook-job:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_last_webhook_job_id,$$chainlinkContainerName,webhookJobId) \
	$(call get_cookie,$$chainlinkContainerName,cookie) \
	printf "%s\n" "Running Webhook Job with ID $$webhookJobId on Chainlink node $$nodeId. Please wait..."; \
	res=$$(curl -s --cookie "$$cookie" -X POST -H "Content-Type: application/json" http://localhost:67$$nodeId$$nodeId/v2/jobs/$$webhookJobId/runs); \
	runId=$$(echo $$res | grep -m 1 -o '"id":"[^"]*"' | cut -d':' -f2); \
	outputs=$$(echo $$res | grep -m 1 -o '"outputs":[^,]*' | cut -d':' -f2); \
	errors=$$(echo $$res | grep -m 1 -o '"errors":[^,]*' | cut -d':' -f2); \
	printf "%s\n" "Run ID: $$runId"; \
	printf "%s\n" "Outputs: $$outputs"; \
	printf "%s\n" "Errors: $$errors";

run-webhook-job-external:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call check_set_parameter,WEBHOOK_JOB_ID,webhookJobId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_cookie,$$chainlinkContainerName,cookie) \
	printf "%s\n" "Running Webhook Job with ID $$webhookJobId on Chainlink node $$nodeId. Please wait..."; \
	res=$$(curl -s --cookie "$$cookie" -X POST -H "Content-Type: application/json" http://localhost:67$$nodeId$$nodeId/v2/jobs/$$webhookJobId/runs); \
	runId=$$(echo $$res | grep -m 1 -o '"id":"[^"]*"' | cut -d':' -f2); \
	outputs=$$(echo $$res | grep -m 1 -o '"outputs":[^,]*' | cut -d':' -f2); \
	errors=$$(echo $$res | grep -m 1 -o '"errors":[^,]*' | cut -d':' -f2); \
	printf "%s\n" "Run ID: $$runId"; \
	printf "%s\n" "Outputs: $$outputs"; \
	printf "%s\n" "Errors: $$errors";

create-keeper-job:
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	$(call format_eip55_address,$$registryAddress,registryAddressFormatted) \
	printf "%s\n" "Creating Keeper Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/keeper_job_tmp.toml \
	&& sed -e 's/REGISTRY_ADDRESS/$$registryAddressFormatted/g' -e 's/NODE_ADDRESS/$$nodeAddress/g' ${ROOT}/jobs/keeper_job.toml > ${ROOT}/jobs/keeper_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/keeper_job_tmp.toml && rm ${ROOT}/jobs/keeper_job_tmp.toml"

create-keeper-jobs:
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	make create-keeper-job NODE_ID=1 REGISTRY_ADDRESS=$$registryAddress && \
	make create-keeper-job NODE_ID=2 REGISTRY_ADDRESS=$$registryAddress && \
	make create-keeper-job NODE_ID=3 REGISTRY_ADDRESS=$$registryAddress && \
	make create-keeper-job NODE_ID=4 REGISTRY_ADDRESS=$$registryAddress && \
	make create-keeper-job NODE_ID=5 REGISTRY_ADDRESS=$$registryAddress;

create-ocr-bootstrap-job:
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId,_) \
	$(call format_eip55_address,$$offchainAggregatorAddress,offchainAggregatorAddressFormatted) \
	printf "%s\n" "Creating OCR Job (bootstrap) on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/ocr_job_bootstrap_tmp.toml \
	&& sed -e 's/OFFCHAIN_AGGREGATOR_ADDRESS/$$offchainAggregatorAddressFormatted/g' -e 's/PEER_ID/$$peerId/g' ${ROOT}/jobs/ocr_job_bootstrap.toml > ${ROOT}/jobs/ocr_job_bootstrap_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/ocr_job_bootstrap_tmp.toml && rm ${ROOT}/jobs/ocr_job_bootstrap_tmp.toml"

create-ocr-job:
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	$(call check_set_parameter,BOOTSTRAP_P2P_KEY,bootstrapP2PKey) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	$(call get_ocr_keys,$$chainlinkContainerName,ocrKeyId,_,_,_) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId,_) \
	$(call format_eip55_address,$$offchainAggregatorAddress,offchainAggregatorAddressFormatted) \
	printf "%s\n" "Creating OCR Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/ocr_job_tmp.toml \
	&& sed -e 's/OFFCHAIN_AGGREGATOR_ADDRESS/$$offchainAggregatorAddressFormatted/g' -e 's/BOOTSTRAP_P2P_KEY/$$bootstrapP2PKey/g' -e 's/PEER_ID/$$peerId/g' -e 's/OCR_KEY_ID/$$ocrKeyId/g' -e 's/NODE_ADDRESS/$$nodeAddress/g' ${ROOT}/jobs/ocr_job.toml > ${ROOT}/jobs/ocr_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/ocr_job_tmp.toml && rm ${ROOT}/jobs/ocr_job_tmp.toml"

# Considering Chainlink Node with NODE_ID 1 is always a bootstrap node and the rest are Oracle nodes
create-ocr-jobs:
	bootstrapNodeId=1; \
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	$(call get_chainlink_container_name,$$bootstrapNodeId,bootstrapChainlinkContainerName) \
	make login NODE_ID=$$bootstrapNodeId >/dev/null 2>&1; \
	$(call get_p2p_keys,$$bootstrapChainlinkContainerName,bootstrapPeerId,_) \
	make create-ocr-bootstrap-job NODE_ID=1 OFFCHAIN_AGGREGATOR_ADDRESS=$$offchainAggregatorAddress && \
	make create-ocr-job NODE_ID=2 OFFCHAIN_AGGREGATOR_ADDRESS=$$offchainAggregatorAddress BOOTSTRAP_P2P_KEY=$$bootstrapPeerId && \
	make create-ocr-job NODE_ID=3 OFFCHAIN_AGGREGATOR_ADDRESS=$$offchainAggregatorAddress BOOTSTRAP_P2P_KEY=$$bootstrapPeerId && \
	make create-ocr-job NODE_ID=4 OFFCHAIN_AGGREGATOR_ADDRESS=$$offchainAggregatorAddress BOOTSTRAP_P2P_KEY=$$bootstrapPeerId && \
	make create-ocr-job NODE_ID=5 OFFCHAIN_AGGREGATOR_ADDRESS=$$offchainAggregatorAddress BOOTSTRAP_P2P_KEY=$$bootstrapPeerId;

create-flux-job:
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call format_eip55_address,$$fluxAggregatorAddress,fluxAggregatorAddressFormatted) \
	printf "%s\n" "Creating Flux Job on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName bash -c "touch ${ROOT}/jobs/flux_job_tmp.toml \
	&& sed -e 's/FLUX_AGGREGATOR_ADDRESS/$$fluxAggregatorAddressFormatted/g' ${ROOT}/jobs/flux_job.toml > ${ROOT}/jobs/flux_job_tmp.toml" && \
	docker exec $$chainlinkContainerName bash -c "chainlink jobs create ${ROOT}/jobs/flux_job_tmp.toml && rm ${ROOT}/jobs/flux_job_tmp.toml"

# Create a Flux Job for the first 3 nodes of a Chainlink cluster
create-flux-jobs:
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	make create-flux-job NODE_ID=1 FLUX_AGGREGATOR_ADDRESS=$$fluxAggregatorAddress && \
	make create-flux-job NODE_ID=2 FLUX_AGGREGATOR_ADDRESS=$$fluxAggregatorAddress && \
	make create-flux-job NODE_ID=3 FLUX_AGGREGATOR_ADDRESS=$$fluxAggregatorAddress

delete-job:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call check_set_parameter,JOB_ID,jobId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	printf "%s\n" "Deleting Job with ID $$jobId on Chainlink node $$nodeId. Please wait..."; \
	docker exec $$chainlinkContainerName chainlink -j jobs delete $$jobId;

# Helper Solidity Scripts
transfer-eth:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,RECIPIENT,recipient) \
	printf "%s\n" "Transferring ETH to the $$recipient. Please wait..."; \
	forge script ./script/Helper.s.sol --sig "transferEth(address, uint256)" $$recipient 1000000000000000000 --rpc-url ${RPC_URL} --broadcast

transfer-eth-to-node:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	make transfer-eth RECIPIENT=$$nodeAddress;

transfer-eth-to-nodes:
	make transfer-eth-to-node NODE_ID=1;
	make transfer-eth-to-node NODE_ID=2;
	make transfer-eth-to-node NODE_ID=3;
	make transfer-eth-to-node NODE_ID=4;
	make transfer-eth-to-node NODE_ID=5;

transfer-link:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	$(call check_set_parameter,RECIPIENT,recipient) \
	printf "%s\n" "Transferring Link Tokens to $$recipient. Please wait..."; \
	forge script ./script/Helper.s.sol --sig "transferLink(address, address, uint256)" $$recipient $$linkContractAddress 100000000000000000000 --rpc-url ${RPC_URL} --broadcast

transfer-link-to-node:
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress) \
	make transfer-link RECIPIENT=$$nodeAddress;

transfer-link-to-nodes:
	make transfer-link-to-node NODE_ID=1;
	make transfer-link-to-node NODE_ID=2;
	make transfer-link-to-node NODE_ID=3;
	make transfer-link-to-node NODE_ID=4;
	make transfer-link-to-node NODE_ID=5;

# Link Token Solidity Scripts
get-link-balance:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	$(call check_set_parameter,ACCOUNT,account) \
	printf "%s\n" "Getting Link Token balance for the account. Please wait..."; \
	forge script ./script/LinkToken.s.sol --sig "getBalance(address,address)" $$linkContractAddress $$account --rpc-url ${RPC_URL} --broadcast

# Chainlink Consumer Solidity Scripts
request-eth-price-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	$(call check_set_parameter,ORACLE_ADDRESS,oracleAddress) \
	$(call format_eip55_address,$$oracleAddress,oracleAddressFormatted) \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	make login NODE_ID=$$nodeId >/dev/null 2>&1; \
	$(call get_external_job_id,$$chainlinkContainerName,$$oracleAddressFormatted,directRequestExternalJobId) \
	printf "%s\n" "Requesting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "requestEthereumPrice(address, address, string)" $$consumerAddress $$oracleAddress $$directRequestExternalJobId --rpc-url ${RPC_URL} --broadcast

request-eth-price-consumer-external:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	$(call check_set_parameter,ORACLE_ADDRESS,oracleAddress) \
	$(call check_set_parameter,DIRECT_REQUEST_EXTERNAL_JOB_ID,directRequestExternalJobId) \
	directRequestExternalJobId=$$(echo $$directRequestExternalJobId | tr -d '-'); \
	printf "%s\n" "Requesting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "requestEthereumPrice(address, address, string)" $$consumerAddress $$oracleAddress $$directRequestExternalJobId --rpc-url ${RPC_URL} --broadcast

get-eth-price-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CONSUMER_ADDRESS,consumerAddress) \
	printf "%s\n" "Getting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkConsumer.s.sol --sig "getEthereumPrice(address)" $$consumerAddress --rpc-url ${RPC_URL} --broadcast

# Chainlink Cron Consumer Solidity Scripts
get-eth-price-cron-consumer:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,CRON_CONSUMER_ADDRESS,cronConsumerAddress) \
	printf "%s\n" "Getting current ETH price. Please wait..."; \
	forge script ./script/ChainlinkCronConsumer.s.sol --sig "getEthereumPrice(address)" $$cronConsumerAddress --rpc-url ${RPC_URL} --broadcast

# Chainlink Keeper Consumer Solidity Scripts
get-keeper-counter:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	printf "%s\n" "Getting current counter. Please wait..."; \
	forge script ./script/ChainlinkKeeperConsumer.s.sol --sig "getCounter(address)" $$keeperConsumerAddress --rpc-url ${RPC_URL} --broadcast

# Registry Solidity Scripts
register-upkeep:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	printf "%s\n" "Registering Upkeep in the Chainlink Registry. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "registerUpkeep(address,address)" $$registryAddress $$keeperConsumerAddress --rpc-url ${RPC_URL} --broadcast

set-keepers:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,KEEPER_CONSUMER_ADDRESS,keeperConsumerAddress) \
	printf "%s\n" "Setting Keepers in Registry. Please wait..."; \
	nodeId=1; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress1) \
	nodeId=2; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress2) \
	nodeId=3; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress3) \
	nodeId=4; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress4) \
	nodeId=5; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress5) \
	forge script ./script/Registry.s.sol --sig "setKeepers(address,address,address[])" $$registryAddress $$keeperConsumerAddress [$$nodeAddress1,$$nodeAddress2,$$nodeAddress3,$$nodeAddress4,$$nodeAddress5] --rpc-url ${RPC_URL} --broadcast

fund-latest-upkeep:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,REGISTRY_ADDRESS,registryAddress) \
	$(call check_set_parameter,LINK_CONTRACT_ADDRESS,linkContractAddress) \
	printf "%s\n" "Funding the latest upkeep in Registry contract. Please wait..."; \
	forge script ./script/Registry.s.sol --sig "fundLatestUpkeep(address,address,uint256)" $$registryAddress $$linkContractAddress 1000000000000000000 --rpc-url ${RPC_URL} --broadcast

# Offchain Aggregator Solidity Scripts
# Setting payees excluding Node 1 as a bootstrap node
set-payees:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	printf "%s\n" "Setting Payees in the Offchain Aggregator contract. Please wait..."; \
	nodeId=2; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress2) \
	nodeId=3; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress3) \
	nodeId=4; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress4) \
	nodeId=5; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress5) \
	forge script ./script/OffchainAggregator.s.sol --sig "setPayees(address,address[])" $$offchainAggregatorAddress [$$nodeAddress2,$$nodeAddress3,$$nodeAddress4,$$nodeAddress5] --rpc-url ${RPC_URL} --broadcast

set-config:
ifeq ($(OCRHelperPathWildcard),"")
	printf ">  %s\n>  %s\n>  %s\n" \
		"Binary file \"$(OCRHelperPath)\" does not exist." \
		"Please run: 'make build-ocr-helper' to build OS dependent OCR Helper external library." \
		"Find more information in the README file.";
else
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	printf "%s\n" "Generating and setting OCR config in the Offchain Aggregator. Please wait..."; \
	nodeId=2; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress2) \
	$(call get_ocr_keys,$$chainlinkContainerName,_,onChainSigningAddress2,offChainPublicKey2,configPublicKey2) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId2,_) \
	nodeId=3; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress3) \
	$(call get_ocr_keys,$$chainlinkContainerName,_,onChainSigningAddress3,offChainPublicKey3,configPublicKey3) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId3,_) \
	nodeId=4; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress4) \
	$(call get_ocr_keys,$$chainlinkContainerName,_,onChainSigningAddress4,offChainPublicKey4,configPublicKey4) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId4,_) \
	nodeId=5; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress5) \
	$(call get_ocr_keys,$$chainlinkContainerName,_,onChainSigningAddress5,offChainPublicKey5,configPublicKey5) \
	$(call get_p2p_keys,$$chainlinkContainerName,peerId5,_) \
	ocrConfig=$$(make get-ocr-config \
		NODE_ADDRESSES=$$nodeAddress2,$$nodeAddress3,$$nodeAddress4,$$nodeAddress5 \
		OFFCHAIN_PUBLIC_KEYS=$$offChainPublicKey2,$$offChainPublicKey3,$$offChainPublicKey4,$$offChainPublicKey5 \
		CONFIG_PUBLIC_KEYS=$$configPublicKey2,$$configPublicKey3,$$configPublicKey4,$$configPublicKey5 \
		ONCHAIN_SIGNING_ADDRESSES=$$onChainSigningAddress2,$$onChainSigningAddress3,$$onChainSigningAddress4,$$onChainSigningAddress5 \
		PEER_IDS=$$peerId2,$$peerId3,$$peerId4,$$peerId5 \
	); \
	forge script ./script/OffchainAggregator.s.sol --sig "setConfig(address,address[],address[],uint8,uint64,bytes)" $$offchainAggregatorAddress $$ocrConfig --rpc-url ${RPC_URL} --broadcast
endif

request-new-round:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	printf "%s\n" "Requesting new round in the Offchain Aggregator contract. Please wait..."; \
	forge script ./script/OffchainAggregator.s.sol --sig "requestNewRound(address)" $$offchainAggregatorAddress --rpc-url ${RPC_URL} --broadcast

get-latest-answer-ocr:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,OFFCHAIN_AGGREGATOR_ADDRESS,offchainAggregatorAddress) \
	printf "%s\n" "Getting the latest answer in the Offchain Aggregator contract. Please wait..."; \
	forge script ./script/OffchainAggregator.s.sol --sig "latestAnswer(address)" $$offchainAggregatorAddress --rpc-url ${RPC_URL} --broadcast

# Flux Aggregator Solidity Scripts
update-available-funds:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	printf "%s\n" "Updating available funds in the Flux Aggregator contract. Please wait..."; \
	forge script ./script/FluxAggregator.s.sol --sig "updateAvailableFunds(address)" $$fluxAggregatorAddress --rpc-url ${RPC_URL} --broadcast

# For the Flux Aggregator, we use the first 3 nodes of a Chainlink cluster
set-oracles:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	nodeId=1; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress1) \
	nodeId=2; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress2) \
	nodeId=3; \
	make login NODE_ID=$$nodeId >/dev/null 2>&1 && \
	$(call get_chainlink_container_name,$$nodeId,chainlinkContainerName) \
	$(call get_node_address,$$chainlinkContainerName,nodeAddress3) \
	printf "%s\n" "Setting Oracles in Flux Aggregator. Please wait..."; \
	forge script ./script/FluxAggregator.s.sol --sig "setOracles(address,address[])" $$fluxAggregatorAddress [$$nodeAddress1,$$nodeAddress2,$$nodeAddress3] --rpc-url ${RPC_URL} --broadcast

get-oracles:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	printf "%s\n" "Getting oracles in the Flux Aggregator contract. Please wait..."; \
	forge script ./script/FluxAggregator.s.sol --sig "getOracles(address)" $$fluxAggregatorAddress --rpc-url ${RPC_URL} --broadcast

get-latest-answer-flux:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	$(call check_set_parameter,FLUX_AGGREGATOR_ADDRESS,fluxAggregatorAddress) \
	printf "%s\n" "Getting the latest answer in the Flux Aggregator contract. Please wait..."; \
	forge script ./script/FluxAggregator.s.sol --sig "getLatestAnswer(address)" $$fluxAggregatorAddress --rpc-url ${RPC_URL} --broadcast

# Automation [ON CHAIN]
setup-direct-request-job:
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, LINK_CONTRACT_ADDRESS) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	printf "%s\n" "Setting up Direct Request Job on Chainlink node $$nodeId. Please wait..."; \
	forge script ./script/DirectRequestJob.s.sol --sig "run(string)" $$nodeId --ffi --rpc-url ${RPC_URL} --broadcast

setup-cron-job:
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, LINK_CONTRACT_ADDRESS) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	printf "%s\n" "Setting up Cron Job on Chainlink node $$nodeId. Please wait..."; \
	forge script ./script/CronJob.s.sol --sig "run(string)" $$nodeId --ffi --rpc-url ${RPC_URL} --broadcast

setup-webhook-job:
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	$(call check_set_parameter,NODE_ID,nodeId) \
	printf "%s\n" "Setting up Webhook Job on Chainlink node $$nodeId. Please wait..."; \
	forge script ./script/WebhookJob.s.sol --sig "run(string)" $$nodeId --ffi --rpc-url ${RPC_URL} --broadcast

setup-keeper-job:
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	printf "%s\n" "Setting up Keeper Job. Please wait..."; \
	res=$$(forge script ./script/KeeperJob.s.sol --ffi --rpc-url ${RPC_URL} --broadcast -vv); \
    registryAddress=$$(echo $$res | grep -m1 -o '== Logs == [^ ]*' | cut -d' ' -f4 | cut -d',' -f1); \
	keeperConsumerAddress=$$(echo $$res | grep -m1 -o '== Logs == [^ ]*' | cut -d' ' -f4 | cut -d',' -f2); \
	forge script ./script/KeeperJob.s.sol --sig "finalize(address,address)" $$registryAddress $$keeperConsumerAddress --ffi --rpc-url ${RPC_URL} --broadcast --private-key ${PRIVATE_KEY}

setup-ocr-job:
ifeq ($(OCRHelperPathWildcard),"")
	printf ">  %s\n>  %s\n>  %s\n" \
		"Binary file \"$(OCRHelperPath)\" does not exist." \
		"Please run: 'make build-ocr-helper' to build OS dependent OCR Helper external library." \
		"Find more information in the README file."
else
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	printf "%s\n" "Setting up OCR Job. Please wait..."; \
	res=$$(forge script ./script/OCRJob.s.sol --ffi --rpc-url ${RPC_URL} --broadcast -vv); \
    offchainAggregatorAddress=$$(echo $$res | grep -m1 -o '== Logs == [^ ]*' | cut -d' ' -f4); \
	forge script ./script/OCRJob.s.sol --sig "finalize(address)" $$offchainAggregatorAddress --ffi --rpc-url ${RPC_URL} --broadcast --private-key ${PRIVATE_KEY}
endif

setup-flux-job:
	make check-docker-network || sh -c 'exit 1'
	$(call check_defined, RPC_URL) \
	$(call check_defined, PRIVATE_KEY) \
	printf "%s\n" "Setting up Flux Job. Please wait..."; \
	res=$$(forge script ./script/FluxJob.s.sol --ffi --rpc-url ${RPC_URL} --broadcast -vv); \
    fluxAggregatorAddress=$$(echo $$res | grep -m1 -o '== Logs == [^ ]*' | cut -d' ' -f4); \
	forge script ./script/FluxJob.s.sol --sig "finalize(address)" $$fluxAggregatorAddress --ffi --rpc-url ${RPC_URL} --broadcast --private-key ${PRIVATE_KEY}
