// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IRateOracle} from "../interfaces/IRateOracle.sol";
import {IAaveV3PoolAddressesProvider} from "../interfaces/aave/IAaveV3PoolAddressesProvider.sol";
import {IAaveV3LendingPool} from "../interfaces/aave/IAaveV3LendingPool.sol";
import {WadRayMath} from "../libraries/WadRayMath.sol";

/**
 * @title Aave Reserve Income Oracle (Chainlink-compatible)
 *
 * @notice Publishes the current liquidity index for a single reserve so that
 *  other contracts can read it via `latestRoundData()` in the familiar
 *  Chainlink AggregatorV3 format
 *
 */
contract AaveRateOracle is IRateOracle {
    /* ─────────── immutable config ─────────── */
    IAaveV3PoolAddressesProvider public immutable provider;
    address public immutable asset;

    /* ─────────── snapshot struct ─────────── */
    struct Observation {
        uint40 ts; // timestamp of the snapshot   (fits until year 2106)
        uint216 indexRay; // liquidity index at that ts  (27-decimals)
    }

    Observation public lastObs;

    /* ─────────── constructor ─────────── */
    constructor(address _provider, address _asset) {
        provider = IAaveV3PoolAddressesProvider(_provider);
        asset = _asset;

        // seed the first observation
        uint256 startIdx = IAaveV3LendingPool(provider.getPool()).getReserveNormalizedIncome(_asset);
        lastObs = Observation(uint40(block.timestamp), uint216(startIdx));
    }

    /* ─────────── chainlink feed section ─────────── */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function description() public pure override returns (string memory) {
        return "Aave reserve normalized income (18-dec)";
    }

    function version() public pure override returns (uint256) {
        return 1;
    }

    /// @dev core Chainlink pull — returns *current* index down-scaled to 18 dec
    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        // 1. Resolve the pool for this market
        IAaveV3LendingPool pool = IAaveV3LendingPool(provider.getPool());

        // 2. Pull the 27-dec index
        uint256 indexRay = pool.getReserveNormalizedIncome(asset);

        // 3. Convert 27-dec → 18-dec so consumers don’t need bespoke math
        uint256 index18 = indexRay / 1e9;

        // 4. Return in Chainlink schema (we ignore round IDs for a pure on-chain feed)
        return (
            0, // roundId (static)
            int256(index18), // answer
            block.timestamp, // startedAt
            block.timestamp, // updatedAt
            0 // answeredInRound
        );
    }

    /* ─────────── Yield-specific helpers ─────────── */

    ///@notice Records a new `{timestamp, index}` pair.
    function update() external {
        uint256 idxRay = IAaveV3LendingPool(provider.getPool()).getReserveNormalizedIncome(asset);
        lastObs = Observation(uint40(block.timestamp), uint216(idxRay));
    }

    /**
     * @notice Realised yield (Ray precision) between the stored snapshot and now.
     * @dev    *yieldRay* = (indexNow / indexSnapshot) − 1
     */
    function yieldSinceLast() external view returns (uint256 yieldRay) {
        uint256 nowIdx = IAaveV3LendingPool(provider.getPool()).getReserveNormalizedIncome(asset);
        return WadRayMath.rayDiv(nowIdx, uint256(lastObs.indexRay)) - WadRayMath.RAY;
    }

    /**
     * @notice Same realised yield but returned as a human-readable percentage
     *         with 1e4 precision (i.e. 1 % = 1_0000).
     */
    function yieldPct1e4() external view returns (uint256 pct1e4) {
        uint256 yRay = this.yieldSinceLast(); // 1e27
        return (yRay * 10_000) / 1e27; // scale to basis-points
    }
}
