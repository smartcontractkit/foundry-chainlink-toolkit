# include .env file and export its env vars
# (-include to ignore error if it does not exist)
include .env

check_defined = \
    $(strip $(foreach 1,$1, \
    $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
    $(error Undefined env variable $1$(if $2, ($2))))

install:
	forge install foundry-rs/forge-std --no-commit

run-node:
	$(call check_defined, ROOT) \
	$(call check_defined, ETH_CHAIN_ID) \
	$(call check_defined, ETH_URL) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_defined, POSTGRES_USER) \
	$(call check_defined, POSTGRES_PASSWORD) \
	$(call check_defined, POSTGRES_DB) \
	docker compose down
	docker compose up -d

restart-node:
	$(call check_defined, ROOT) \
	$(call check_defined, ETH_CHAIN_ID) \
	$(call check_defined, ETH_URL) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	$(call check_defined, POSTGRES_USER) \
	$(call check_defined, POSTGRES_PASSWORD) \
	$(call check_defined, POSTGRES_DB) \
	docker compose restart

login:
	$(call check_defined, ROOT) \
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	docker exec ${CHAINLINK_CONTAINER_NAME} chainlink admin login -f ${ROOT}/chainlink_api_credentials

get-info: login
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	docker exec ${CHAINLINK_CONTAINER_NAME} chainlink keys eth list


create-job: login
	$(call check_defined, CHAINLINK_CONTAINER_NAME) \
	docker exec ${CHAINLINK_CONTAINER_NAME} chainlink jobs create ${ROOT}/createJob.toml

deploy-link-token:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	echo "Deploying Link Token contract. Please wait..."; \
	forge script ./script/DeployLinkToken.s.sol --sig "deploy()" --rpc-url ${RPC_URL} --broadcast --silent

deploy-oracle:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	echo "Please enter the Link Token address..."; \
    read tokenAddress; \
	echo "Please enter the Chainlink Node address..."; \
    read nodeAddress; \
	echo "Deploying Oracle contract. Please wait..."; \
	forge script ./script/DeployOracle.s.sol --sig "deploy(address, address)" $$tokenAddress $$nodeAddress --rpc-url ${RPC_URL} --broadcast --silent

transfer-link:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	echo "Please enter the Link Token address..."; \
	read tokenAddress; \
	echo "Please enter the Chainlink Node address..."; \
	read nodeAddress; \
	echo "Transferring Link Tokens to the Chainlink Node. Please wait..."; \
	forge script ./script/Transfer.s.sol --sig "transferLink(address, address, uint256)" $$nodeAddress $$tokenAddress 1000000000000000000 --rpc-url ${RPC_URL} --broadcast \

transfer-eth:
	$(call check_defined, PRIVATE_KEY) \
	$(call check_defined, RPC_URL) \
	echo "Please enter the Chainlink Node address..."; \
	read nodeAddress; \
	echo "Transferring ETH to the Chainlink Node. Please wait..."; \
	forge script ./script/Transfer.s.sol --sig "transferEth(address, uint256)" $$nodeAddress 1000000000000000000 --rpc-url ${RPC_URL} --broadcast
