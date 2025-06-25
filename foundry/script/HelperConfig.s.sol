// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MockERC20} from "../test/mocks/MockERC20.sol";
import {MockAaveV3LendingPool} from "../test/mocks/MockAaveV3LendingPool.sol";
import {MockAaveV3PoolAddressesProvider} from "../test/mocks/MockAaveV3PoolAddressesProvider.sol";

/// https://aave.com/docs/resources/addresses
/// https://docs.chain.link/ccip/directory/testnet/token/USDC

contract HelperConfig is Script {
    struct NetworkConfig {
        address aaveProvider;
        address aavePool;
        address aaveAsset;
        uint256 deployerKey;
    }

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11_155_111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            aaveProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
            aavePool: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951,
            aaveAsset: 0x854edF78e05Cd554CE538DA198Ce31807F2Cb7CF,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        vm.startBroadcast();

        MockAaveV3LendingPool aavePool = new MockAaveV3LendingPool();
        MockAaveV3PoolAddressesProvider aaveProvider = new MockAaveV3PoolAddressesProvider(address(aavePool));
        MockERC20 uscd = new MockERC20("USDC", "USDC");

        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            aaveProvider: address(aaveProvider),
            aavePool: address(aavePool),
            aaveAsset: address(uscd),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });
    }
}
