// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRateSwap} from "./interfaces/IRateSwap.sol";

contract RateSwap is IRateSwap, AutomationCompatible {
    uint256 public constant COLLATERAL_MULTIPLIER = 1_200_000; // 120% collateralization
    uint256 public constant SECONDS_PER_YEAR = 31536000;
    uint256 public constant PRECISION = 1_000_000;

    mapping(uint256 => InterestRateSwap) public swaps;
    mapping(uint256 => uint256) public settlementTimes;
    uint256 public nextSwapId;

    constructor() {
        nextSwapId = 1;
    }

    function createSwap(uint256 _notional, uint256 _fixedRate, uint256 _tenor, address _asset)
        external
        returns (uint256 swapId)
    {
        // ** Validations ** //
        //@todo Check benchmark rate for _asset

        require(_notional > 0, "Notional must be positive");
        require(_fixedRate > 0, "Fixed rate must be positive");
        require(_tenor > 0, "Tenor must be positive");

        swapId = nextSwapId++;

        IERC20(_asset).transferFrom(msg.sender, address(this), _notional);

        swaps[swapId] = InterestRateSwap({
            fixedPayer: msg.sender,
            floatingPayer: address(0),
            notional: _notional,
            fixedRate: _fixedRate,
            startTimestamp: block.timestamp,
            tenor: _tenor,
            asset: _asset,
            status: RateSwapStatus.OPEN
        });

        settlementTimes[swapId] = block.timestamp + _tenor;

        emit SwapCreated(swapId, _notional, msg.sender);
    }

    function acceptSwap(uint256 swapId) external {
        InterestRateSwap storage swap = swaps[swapId];

        require(swap.status == RateSwapStatus.OPEN, "Swap not open");
        require(swap.floatingPayer == address(0), "Already accepted");

        IERC20(swap.asset).transferFrom(msg.sender, address(this), swap.notional);

        swap.floatingPayer = msg.sender;
        swap.status = RateSwapStatus.ACTIVE;

        emit SwapAccepted(swapId, msg.sender);
    }

    function settleSwap(uint256 swapId) external {}

    function checkUpkeep(bytes calldata) external view returns (bool, bytes memory) {}

    function performUpkeep(bytes calldata performData) external {}

    function getAnnualizedSupplyRate() external pure returns (uint256) {
        return 1e18;
    }
}
