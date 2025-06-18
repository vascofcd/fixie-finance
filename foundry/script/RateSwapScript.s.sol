// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RateSwap} from "../src/RateSwap.sol";

contract RateSwapScript is Script {
    RateSwap public rateSwap;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        rateSwap = new RateSwap();

        vm.stopBroadcast();
    }
}
