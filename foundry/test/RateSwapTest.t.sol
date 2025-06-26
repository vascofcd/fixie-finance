// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RateSwap} from "../src/RateSwap.sol";
import {AaveRateOracle} from "../src/oracles/AaveRateOracle.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockAaveV3LendingPool} from "./mocks/MockAaveV3LendingPool.sol";
import {MockAaveV3PoolAddressesProvider} from "./mocks/MockAaveV3PoolAddressesProvider.sol";

contract RateSwapTest is Test {
    MockERC20 public asset;
    MockAaveV3LendingPool public aavePool;
    MockAaveV3PoolAddressesProvider aaveProvider;
    AaveRateOracle public aaveRateOracle;
    RateSwap public rateSwap;

    address public alice = address(0x1);
    address public bob = address(0x2);

    uint256 public constant NOTIONAL_AMOUNT = 1e18;
    uint256 public constant FIXED_RATE = 1_000; // 5% in basis points (1e8 scale)
    uint256 public constant TENOR = 365 days;
    uint256 constant RAY = 1e27;

    function setUp() public {
        asset = new MockERC20("USDC", "USDC");
        aavePool = new MockAaveV3LendingPool();
        aaveProvider = new MockAaveV3PoolAddressesProvider(address(aavePool));

        aavePool.setReserveNormalizedIncome(address(asset), RAY);

        aaveRateOracle = new AaveRateOracle(address(aaveProvider), address(asset));
        rateSwap = new RateSwap(address(aaveRateOracle));

        setMintAndApprove(alice, address(rateSwap));
        setMintAndApprove(bob, address(rateSwap));
    }

    function test_aaveRate() public {
        // 105_00000_00000_00000_00000_00000 (i.e., 1.05 * 1e27)
        // This means your aToken has accrued 5% interest since it was minted.
        aaveRateOracle.update();

        aavePool.setReserveNormalizedIncome(address(asset), (RAY * 105) / 100); // 1.05 or 5%
        uint256 y = aaveRateOracle.rateSinceLast(); // 5_00000_00000_00000_00000_00000 or  0.05 * RAY

        assertEq(y, (RAY * 5) / 100); // 5 % in Ray units
    }

    function test_createSwap() public {
        /* ───────────────────────────────── create swap ───────────────────────────────── */
        vm.prank(alice);
        uint256 swapCreatedId = rateSwap.createSwap(NOTIONAL_AMOUNT, FIXED_RATE, TENOR, address(asset));

        /* ──────────────────────────────── update oracle ──────────────────────────────── */
        aaveRateOracle.update();
        aavePool.setReserveNormalizedIncome(address(asset), (RAY * 105) / 100); // 1.05

        /* ───────────────────────────────── accept swap ───────────────────────────────── */
        vm.prank(bob);
        rateSwap.acceptSwap(swapCreatedId);

        console.log("payment %s ", rateSwap.settleSwap(swapCreatedId));

        assertEq(rateSwap.nextSwapId(), swapCreatedId + 1);
        assertEq(rateSwap.settlementTimes(swapCreatedId), block.timestamp + TENOR);
        assertEq(asset.balanceOf(address(rateSwap)), NOTIONAL_AMOUNT * 2);
    }

    function setMintAndApprove(address user, address spender) internal {
        vm.startPrank(user);
        asset.mint(user, 1e18);
        asset.approve(address(spender), type(uint256).max);
        vm.stopPrank();
    }
}
