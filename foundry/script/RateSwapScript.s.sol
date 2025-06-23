// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RateSwap} from "../src/RateSwap.sol";

contract RateSwapScript is Script {
    function run() public {
        vm.startBroadcast();

        RateSwap rateSwap = new RateSwap();

        // rateSwap.createSwap(
        //     1000e18, // Notional
        //     50000, // Fixed rate (5%)
        //     365 days, // Term (1 year)
        //     address(0) // Asset (mocked)
        // );

        vm.stopBroadcast();
    }
}
