-include .env

.PHONY: deploy

deploy :; @forge script script/DeployHashlock.s.sol --private-key ${PRIVATE_KEY} --rpc-url ${CITREA_RPC} --broadcast
#  --verify --verifier etherscan --etherscan-api-key ${ETHERSCAN_API_KEY}
