// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RateSwap} from "../src/RateSwap.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {MockOracle} from "./mocks/MockOracle.sol";

contract RateSwapTest is Test {
    RateSwap public rateSwap;
    ERC20Mock public asset;
    MockOracle public oracle;

    address public alice = address(0x1);
    address public bob = address(0x2);

    uint256 public constant NOTIONAL_AMOUNT = 1e17;
    uint256 public constant FIXED_RATE = 50000; // 5%
    uint256 public constant TENOR = 180 days;

    function setUp() public {
        rateSwap = new RateSwap();
        asset = new ERC20Mock("Thether", "USDT");
        oracle = new MockOracle(asset, 3600);

        setMintAndApprove(alice, address(rateSwap));
        setMintAndApprove(bob, address(rateSwap));
    }

    function test_createSwap() public {
        // ** CREATE SWAP ** //
        vm.prank(alice);
        uint256 swapCreatedId = rateSwap.createSwap(NOTIONAL_AMOUNT, FIXED_RATE, TENOR, address(asset));

        // ** ACCEPT SWAP ** //
        vm.prank(bob);
        rateSwap.acceptSwap(swapCreatedId);

        console.log("settlementTimes: %s", rateSwap.settleSwap(swapCreatedId));

        assertEq(rateSwap.nextSwapId(), swapCreatedId + 1);
        assertEq(rateSwap.settlementTimes(swapCreatedId), block.timestamp + TENOR);
        assertEq(asset.balanceOf(address(rateSwap)), NOTIONAL_AMOUNT * 2); // Alice's notional + Bob's notional
    }

    function setMintAndApprove(address user, address spender) internal {
        vm.startPrank(user);
        asset.mint(user, 1e18);
        asset.approve(address(spender), type(uint256).max);
        vm.stopPrank();
    }
}
