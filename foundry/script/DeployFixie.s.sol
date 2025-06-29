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
        aaveRateOracle.update();

        SOFRRateOracle.FunctionsConfig memory config;
        config.source = vm.readFile("functionsSource/GetSOFR.js");
        config.subId = 5221;
        config.gasLimit = 30_000;
        config.donId = "fun-ethereum-sepolia-1";

        sofrRateOracle = new SOFRRateOracle(address(functionsRouter), config);
        sofrRateOracle.update();

        rateSwap = new RateSwap(aaveAsset, address(aaveRateOracle));

        rateSwap.openSwap({
            _payFixed: true,
            _collateralAmount: 1e16,
            _leverageX: 1,
            _fixedRateWad: 5_000,
            _tenorDays: 28 days
        });

        rateSwap.openSwap({
            _payFixed: false,
            _collateralAmount: 1e16,
            _leverageX: 2,
            _fixedRateWad: 4_000,
            _tenorDays: 28 days
        });

        vm.stopBroadcast();
    }
}
