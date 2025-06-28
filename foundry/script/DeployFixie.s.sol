// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {RateSwap} from "../src/RateSwap.sol";
import {AaveRateOracle} from "../src/oracles/AaveRateOracle.sol";
import {SOFRRateOracle} from "../src/oracles/SOFRRateOracle.sol";

contract DeployFixie is Script {
    AaveRateOracle public aaveRateOracle;
    SOFRRateOracle public sofrRateOracle;
    RateSwap rateSwap;

    function run() public {
        HelperConfig helperConfig = new HelperConfig();

        (address aaveProvider,, address aaveAsset, address functionsRouter, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        aaveRateOracle = new AaveRateOracle(aaveProvider, aaveAsset);

        SOFRRateOracle.FunctionsConfig memory config;
        config.source = vm.readFile("functionsSource/GetSOFR.js");
        config.subId = 5221;
        config.gasLimit = 70_000;
        ///@dev Hardcoded for Sepolia
        config.donId = "fun-ethereum-sepolia-1";

        sofrRateOracle = new SOFRRateOracle(address(functionsRouter), config);

        rateSwap = new RateSwap(aaveAsset, address(aaveRateOracle));
        vm.stopBroadcast();
    }
}
