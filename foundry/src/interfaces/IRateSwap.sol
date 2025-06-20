// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRateSwap {
    struct InterestRateSwap {
        address fixedPayer;
        address floatingPayer; // Set when accepted
        uint256 notional;
        uint256 fixedRate; // 1e6 (100% = 1_000_000) or 1e4 = (5% = 50_000)
        uint256 startTimestamp;
        uint256 term;
        address asset;
        uint256 fixedCollateral;
        uint256 floatingCollateral;
        RateSwapStatus status;
    }

    ///@dev Rate record for floating rates
    struct RateRecord {
        uint256 timestamp;
        uint256 rateBps;
    }

    enum RateSwapStatus {
        OPEN,
        ACTIVE,
        SETTLED,
        EXPIRED
    }

    event SwapCreated(uint256 indexed swapId, address indexed fixedPayer, uint256 indexed notional);
    event SwapAccepted(uint256 indexed swapId, address indexed floatingPayer);
    event FloatingRateRecorded(uint256 indexed swapId, uint256 rateBps, uint256 timestamp);
    event SwapSettled(uint256 indexed swapId, address winner, uint256 interestDelta);
}
