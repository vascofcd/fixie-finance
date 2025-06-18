// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RateSwap} from "../src/RateSwap.sol";

contract RateSwapTest is Test {
    RateSwap public rateSwap;

    function setUp() public {
        rateSwap = new RateSwap();
        rateSwap.createSwap(address(0x1234567890123456789012345678901234567890), 1000000, 500, 30);
        rateSwap.createSwap(address(0x0987654321098765432109876543210987654321), 2000000, 300, 60);
        rateSwap.createSwap(address(0x1122334455667788990011223344556677889900), 1500000, 400, 90);
        rateSwap.createSwap(address(0xAAbbCCDdeEFf00112233445566778899aABBcCDd), 500000, 600, 120);
        rateSwap.createSwap(address(0xFFEEDDCCbBaa99887766554433221100fFeedDcC), 750000, 700, 150);
    }

    function test_SwapCreation() public view {
        assertEq(rateSwap.nextSwapId(), 5);
    }
}
