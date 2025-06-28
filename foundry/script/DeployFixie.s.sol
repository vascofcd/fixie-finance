// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {RateSwap} from "../src/RateSwap.sol";
import {AaveRateOracle} from "../src/oracles/AaveRateOracle.sol";

contract DeployFixie is Script {
    AaveRateOracle public aaveRateOracle;
    RateSwap rateSwap;

    function run() public {
        HelperConfig helperConfig = new HelperConfig();

        (address aaveProvider,, address aaveAsset, uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        aaveRateOracle = new AaveRateOracle(aaveProvider, aaveAsset);
        rateSwap = new RateSwap(aaveAsset, address(aaveRateOracle));
        vm.stopBroadcast();
    }
}
