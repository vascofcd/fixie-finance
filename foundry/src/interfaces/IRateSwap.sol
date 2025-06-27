// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRateSwap {
    /// @param notional     Scaled by leverage
    /// @param collateral   Margin on deposit
    /// @param leverage     1 – maxLeverage inclusive.
    /// @param fixedRate    Trader‑agreed annual fixed rate (WAD)
    /// @param start        Unix ts when opened
    /// @param maturity     Unix ts for settlement
    /// @param payFixed     Pay fixed / receive floating? (true) otherwise the converse.
    /// @param settled      Flag to block re‑entrance.
    /// @param owner        Position owner
    struct Position {
        uint256 notional;
        uint256 collateral;
        uint256 leverage;
        uint256 fixedRate;
        uint256 start;
        uint256 maturity;
        bool payFixed;
        bool settled;
        address trader;
    }

    struct InterestRateSwap {
        address fixedPayer;
        address floatingPayer; // Set when accepted
        uint256 notional;
        uint256 fixedRate; // 1e6 (100% = 1_000_000) or 1e4 = (5% = 50_000)
        uint256 startTimestamp;
        uint256 tenor;
        address asset;
        RateSwapStatus status;
    }

    enum RateSwapStatus {
        OPEN,
        ACTIVE,
        SETTLED,
        EXPIRED
    }

    event SwapCreated(uint256 indexed swapId, uint256 indexed notional, address indexed fixedPayer);
    event SwapAccepted(uint256 indexed swapId, address indexed floatingPayer);
    event FloatingRateRecorded(uint256 indexed swapId, uint256 rateBps, uint256 timestamp);
    event SwapSettled(uint256 indexed swapId, address winner, uint256 interestDelta);
}
