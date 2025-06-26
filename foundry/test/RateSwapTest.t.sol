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

    uint256 public constant NOTIONAL_AMOUNT = 1e17;
    uint256 public constant FIXED_RATE = 50000; // 5%
    uint256 public constant TENOR = 180 days;

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
        aaveRateOracle.update(); // snapshot 1

        aavePool.setReserveNormalizedIncome(address(asset), (RAY * 103) / 100); // 1.03
        uint256 y = aaveRateOracle.rateSinceLast(); // 0.03 * RAY

        assertEq(y, (RAY * 3) / 100); // 3 % in Ray units
    }

    function test_createSwap() public {
        /* ─────────── create swap ─────────── */
        vm.prank(alice);
        uint256 swapCreatedId = rateSwap.createSwap(NOTIONAL_AMOUNT, FIXED_RATE, TENOR, address(asset));

        /* ─────────── accept swap ─────────── */
        vm.prank(bob);
        rateSwap.acceptSwap(swapCreatedId);

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
