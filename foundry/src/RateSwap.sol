// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRateSwap} from "./interfaces/IRateSwap.sol";

contract RateSwap is IRateSwap, AutomationCompatible {
    uint256 public constant COLLATERAL_MULTIPLIER = 1.2e18; // 120% collateralization
    uint256 public constant SECONDS_PER_YEAR = 31536000;
    uint256 public constant PRECISION = 1e6;

    mapping(uint256 => InterestRateSwap) public swaps;
    mapping(uint256 => uint256) public settlementTimes;
    uint256 public nextSwapId = 1;

    function createSwap(uint256 notional, uint256 fixedRate, uint256 term, address asset)
        external
        returns (uint256 swapId)
    {
        swapId = nextSwapId++;

        uint256 collateral = (notional * fixedRate * COLLATERAL_MULTIPLIER) / PRECISION;

        IERC20(asset).transferFrom(msg.sender, address(this), collateral);

        swaps[swapId] = InterestRateSwap({
            fixedPayer: msg.sender,
            floatingPayer: address(0),
            notional: notional,
            fixedRate: fixedRate,
            startTimestamp: block.timestamp,
            term: term,
            asset: asset,
            fixedCollateral: collateral,
            floatingCollateral: 0,
            status: RateSwapStatus.OPEN
        });

        settlementTimes[swapId] = block.timestamp + term;

        emit SwapCreated(swapId, msg.sender, notional);
    }

    ///@dev Anyone can accept an OPEN swap
    function acceptSwap(uint256 swapId) external {
        InterestRateSwap storage swap = swaps[swapId];
        require(swap.status == RateSwapStatus.OPEN, "Swap not open");
        require(swap.floatingPayer == address(0), "Already accepted");

        uint256 collateral = (swap.notional * swap.fixedRate * COLLATERAL_MULTIPLIER) / PRECISION;
        IERC20(swap.asset).transferFrom(msg.sender, address(this), collateral);

        swap.floatingPayer = msg.sender;
        swap.floatingCollateral = collateral;
        swap.status = RateSwapStatus.ACTIVE;

        emit SwapAccepted(swapId, msg.sender);
    }

    function settleSwap(uint256 swapId) external {}

    function checkUpkeep(bytes calldata) external view returns (bool, bytes memory) {}

    function performUpkeep(bytes calldata performData) external {}
}
