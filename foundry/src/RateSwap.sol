// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RateSwap {
    event SwapCreated(uint256 indexed swapId, address indexed fixedPayer, address indexed floatingPayer);
    event FloatingRateRecorded(uint256 indexed swapId, uint256 rateBps, uint256 timestamp);
    event SwapSettled(uint256 indexed swapId, address winner, uint256 interestDelta);

    ///@dev Interest rate swap
    struct InterestRateSwap {
        address fixedPayer;
        address floatingPayer;
        uint256 notional;
        uint256 fixedRate;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 duration;
        RateRecord[] recordedFloatingRates;
        bool settled;
    }

    ///@dev Rate record
    struct RateRecord {
        uint256 timestamp;
        uint256 rateBps;
    }

    ///@dev Swap Id
    uint256 public nextSwapId;

    ///@dev Swap ledger
    mapping(uint256 => InterestRateSwap) public swaps;

    /**
     * @dev Create swap
     */
    function createSwap(
        address _counterparty,
        uint256 _notional,
        uint256 _fixedRate, // in bps
        uint256 _duration // in days
    ) external {
        require(_notional > 0, "Invalid notional amount");

        //@todo check end calculation
        uint256 end = block.timestamp + (_duration * 1 days);

        InterestRateSwap storage newSwap = swaps[nextSwapId];
        newSwap.fixedPayer = msg.sender;
        newSwap.floatingPayer = _counterparty;
        newSwap.notional = _notional;
        newSwap.fixedRate = _fixedRate;
        newSwap.startTimestamp = block.timestamp;
        newSwap.endTimestamp = end;
        newSwap.duration = _duration;
        newSwap.settled = false;

        emit SwapCreated(nextSwapId, msg.sender, _counterparty);
        nextSwapId++;
    }

    /**
     * @dev Record floating rates
     */
    function recordFloatingRate(uint256 swapId, uint256 rateBps) external {
        InterestRateSwap storage swap = swaps[swapId];
        require(block.timestamp < swap.endTimestamp, "Swap expired");
        require(!swap.settled, "Already settled");

        swap.recordedFloatingRates.push(RateRecord({timestamp: block.timestamp, rateBps: rateBps}));

        emit FloatingRateRecorded(swapId, rateBps, block.timestamp);
    }

    /**
     * @dev Settles a swap
     */
    function settleSwap(uint256 swapId) external {
        InterestRateSwap storage swap = swaps[swapId];
        require(block.timestamp >= swap.endTimestamp, "Too early");
        require(!swap.settled, "Already settled");

        uint256 fixedInterest = (swap.notional * swap.fixedRate * swap.duration) / (36500 * 1e2); // APY to daily interest in USDC (6 decimals)

        RateRecord[] storage records = swap.recordedFloatingRates;
        require(records.length > 0, "No floating rates recorded");

        uint256 total;
        for (uint256 i = 0; i < records.length; i++) {
            total += records[i].rateBps;
        }

        uint256 avgFloatingRate = total / records.length;
        uint256 floatingInterest = (swap.notional * avgFloatingRate * swap.duration) / (36500 * 1e2);

        address winner;
        address loser;
        uint256 diff;

        if (floatingInterest > fixedInterest) {
            diff = floatingInterest - fixedInterest;
            winner = swap.floatingPayer;
            loser = swap.fixedPayer;
        } else {
            diff = fixedInterest - floatingInterest;
            winner = swap.fixedPayer;
            loser = swap.floatingPayer;
        }

        swap.settled = true;

        emit SwapSettled(swapId, winner, diff);
    }
}
