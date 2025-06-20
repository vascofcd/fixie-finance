// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RateSwap} from "../src/RateSwap.sol";

contract RateSwapTest is Test {
    RateSwap public rateSwap;

    function setUp() public {
        rateSwap = new RateSwap();
        rateSwap.createSwap(
            1000e18, // Notional
            50000, // Fixed rate (5%)
            365 days, // Term (1 year)
            address(0) // Asset (mocked)
        );
    }

    function test_SwapCreation() public view {
        assertEq(rateSwap.nextSwapId(), 5);
    }
}
