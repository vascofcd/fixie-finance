-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

build:; forge build

deploy: 
	@forge script script/DeployFixie.s.sol -vvvvv