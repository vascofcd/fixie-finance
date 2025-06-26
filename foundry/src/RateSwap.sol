// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRateSwap} from "./interfaces/IRateSwap.sol";
import {AaveRateOracle} from "./oracles/AaveRateOracle.sol";

contract RateSwap is IRateSwap {
    address public oracleAddr;
    uint256 public nextSwapId;
    mapping(uint256 => InterestRateSwap) public swaps;
    mapping(uint256 => uint256) public settlementTimes;

    uint256 public constant YEAR_SECONDS = 365 days;

    constructor(address _oracleAddr) {
        oracleAddr = _oracleAddr;
        nextSwapId = 1;
    }

    function createSwap(uint256 _notional, uint256 _fixedRate, uint256 _tenor, address _asset)
        external
        returns (uint256 swapId)
    {
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

    function settleSwap(uint256 swapId) public view returns (int256) {
        return _calculateNetPayment(swapId);
    }

    function _calculateNetPayment(uint256 swapId) private view returns (int256 netPayment) {
        AaveRateOracle oracle = AaveRateOracle(oracleAddr);
        InterestRateSwap storage swap = swaps[swapId];

        // 5_00000_00000_00000_00000_00000
        uint256 floatingRate = oracle.rateSinceLast() * 10_000 / 1e27;

        // 5000_00000_00000
        uint256 fixedPayment = (swap.fixedRate * swap.notional * swap.tenor) / (10_000 * YEAR_SECONDS);

        // 50000_00000_00000_00000_00000_00000_00000
        uint256 floatingPayment = (floatingRate * swap.notional * swap.tenor) / (10_000 * YEAR_SECONDS);

        netPayment = int256(fixedPayment) - int256(floatingPayment);

        return netPayment;
    }
}
