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

    uint256 constant RAY = 1e27;

    function setUp() public {
        asset = new MockERC20("USDC", "USDC");

        aavePool = new MockAaveV3LendingPool();
        aavePool.setReserveNormalizedIncome(address(asset), RAY);

        aaveProvider = new MockAaveV3PoolAddressesProvider(address(aavePool));

        aaveRateOracle = new AaveRateOracle(address(aaveProvider), address(asset));
        rateSwap = new RateSwap(address(asset), address(aaveRateOracle));

        setMintAndApprove(alice, address(rateSwap));
        setMintAndApprove(bob, address(rateSwap));
        setMintAndApprove(address(rateSwap), address(rateSwap));
    }

    function test_aaveRate() public {
        ///@dev 105_00000_00000_00000_00000_00000 (i.e., 1.05 * 1e27)
        ///@dev This means your aToken has accrued 5% interest since it was minted
        aaveRateOracle.update();

        ///@dev 1.05 or 5%
        aavePool.setReserveNormalizedIncome(address(asset), (RAY * 105) / 100);

        ///@dev 5_00000_00000_00000_00000_00000 or  0.05 * RAY
        uint256 y = aaveRateOracle.rateSinceLast();

        ///@dev 5 % in Ray units
        assertEq(y, (RAY * 5) / 100);
    }

    function test_openSwap() public {
        // ---------------------------------------------------------------------
        // Open swap
        // ---------------------------------------------------------------------

        bool isFixed = true;
        uint256 collAmount = 1e18;
        uint256 leverageX = 1;
        uint256 fixedRate = 5_000; // 5% in basis points (1e8 scale)
        uint256 tenorDays = 28 days;

        vm.prank(alice);

        uint256 swapId = rateSwap.openSwap({
            _payFixed: isFixed,
            _collateralAmount: collAmount,
            _leverageX: leverageX,
            _fixedRateWad: fixedRate,
            _tenorDays: tenorDays
        });

        (uint256 notional,, uint256 lev,, uint256 start, uint256 maturity, bool payFixed,, address owner) =
            rateSwap.positions(swapId);

        assertEq(notional, 1e18, "notional");
        assertEq(lev, 1, "leverage");
        assertGt(start, 0, "start ts");
        assertEq(maturity, block.timestamp + tenorDays * 1 days, "maturity");
        assertEq(payFixed, true, "direction");
        assertEq(owner, alice, "owner");

        // ---------------------------------------------------------------------
        // Settle swap
        // ---------------------------------------------------------------------

        // Trader pays fixed 5%, floating ends up at 10% → trader gains.
        aaveRateOracle.update();
        aavePool.setReserveNormalizedIncome(address(asset), (RAY * 110) / 100); // 1.10 or 10%
        vm.warp(block.timestamp + tenorDays * 1 days);

        uint256 before = asset.balanceOf(alice);
        rateSwap.settleSwap(swapId);
        uint256 afterBal = asset.balanceOf(alice);

        assertGt(afterBal, before, "trader should profit");
    }

    function setMintAndApprove(address user, address spender) internal {
        vm.startPrank(user);
        asset.mint(user, 1e18);
        asset.approve(address(spender), type(uint256).max);
        vm.stopPrank();
    }
}
