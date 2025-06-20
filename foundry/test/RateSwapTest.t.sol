// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RateSwap} from "../src/RateSwap.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

contract RateSwapTest is Test {
    RateSwap public rateSwap;
    ERC20Mock public asset;

    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // ** Deploy contracts ** //
        rateSwap = new RateSwap();
        asset = new ERC20Mock("Ethereum", "ETH");

        // ** Users ** //
        setMintAndApprove(alice, address(rateSwap));
        setMintAndApprove(bob, address(rateSwap));

        // ** Create a swap ** //
        vm.prank(alice);
        rateSwap.createSwap(1e17, 50000, 365 days, address(asset));

        // ** Accept the swap ** //
        vm.startPrank(bob);
        rateSwap.acceptSwap(0);
        vm.stopPrank();
    }

    function test_createSwap() public view {
        assertEq(rateSwap.nextSwapId(), 1);
        assertEq(rateSwap.settlementTimes(0), block.timestamp + 365 days);
        assertEq(asset.balanceOf(address(rateSwap)), 1e17 + 1e17); // Alice's notional + Bob's collateral
    }

    function setMintAndApprove(address user, address spender) internal {
        vm.startPrank(user);
        asset.mint(user, 1e18);
        asset.approve(address(spender), type(uint256).max);
        vm.stopPrank();
    }
}
