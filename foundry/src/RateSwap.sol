// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRateSwap} from "./interfaces/IRateSwap.sol";
import {IRateOracle} from "./interfaces/IRateOracle.sol";

contract RateSwap is IRateSwap, Ownable {
    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------
    event OpenSwap(
        uint256 indexed id,
        address indexed trader,
        bool payFixed,
        uint256 notional,
        uint256 leverage,
        uint256 collateral,
        uint256 fixedRate,
        uint256 maturity
    );
    event AddCollateral(uint256 indexed id, uint256 amount);
    event Settled(uint256 indexed id, int256 pnl);

    // ---------------------------------------------------------------------
    // Config & Constants
    // ---------------------------------------------------------------------

    ///@dev Collateral/settlement token, e.g. USDC
    IERC20 public immutable asset;

    ///@dev Floating‑rate source
    IRateOracle public oracle;

    ///@dev Auto‑incrementing ID
    uint256 public nextId;

    ///@dev id ⇒ Position
    mapping(uint256 => Position) public positions;

    ///@dev Fixed‑point scalar (1e18) for rates
    uint256 public constant WAD = 1e18;

    ///@dev Simple day‑count convention
    uint256 public constant YEAR_SECONDS = 365 days;

    // ---------------------------------------------------------------------
    // Governance‑controlled risk knobs
    // ---------------------------------------------------------------------

    ///@dev bps; default 10 % of notional
    uint256 public minCollateralRatio = 10_000;

    ///@dev 10×
    uint256 public maxLeverage = 10;

    // ---------------------------------------------------------------------
    // Constructor & Admin
    // ---------------------------------------------------------------------
    constructor(address _asset, address _oracle) Ownable(msg.sender) {
        require(_asset != address(0) && _oracle != address(0), "zero addr");
        asset = IERC20(_asset);
        oracle = IRateOracle(_oracle);
    }

    function setMaxLeverage(uint256 _lev) external onlyOwner {
        require(_lev >= 1, "bad leverage");
        maxLeverage = _lev;
    }

    function setMinCollateralRatio(uint256 _bps) external onlyOwner {
        require(_bps > 0 && _bps < 100_000, "range");
        minCollateralRatio = _bps;
    }

    // ---------------------------------------------------------------------
    // Core: open / manage / settle
    // ---------------------------------------------------------------------

    /**
     * @notice Opens a leveraged rate swap.
     *
     * @param _payFixed         true ⇒ trader pays fixed, receives floating; false ⇒ trader pays floating.
     * @param _collateralAmount Margin the trader is willing to post (asset.decimals).
     * @param _leverageX        Leverage multiplier (integer up to maxLeverage).
     * @param _fixedRateWad     Annual fixed‑rate quote, scaled by 1e18.
     * @param _tenorDays        Swap tenor in days.
     */
    function openSwap(
        bool _payFixed,
        uint256 _collateralAmount,
        uint256 _leverageX,
        uint256 _fixedRateWad,
        uint256 _tenorDays
    ) external returns (uint256) {
        require(_leverageX >= 1 && _leverageX <= maxLeverage, "leverage");
        require(_collateralAmount > 0, "collateral 0");
        require(_tenorDays > 0, "tenor 0");

        uint256 notional = _collateralAmount * _leverageX;

        ///@notice Enforce minimum collateral ratio ⇢ notional × minCR / 10_000 ≤ collateralAmount
        uint256 required = (notional * minCollateralRatio) / 10_000;
        require(_collateralAmount >= required, "margin too low");

        ///@notice Pull collateral
        asset.approve(address(this), _collateralAmount);
        asset.transferFrom(msg.sender, address(this), _collateralAmount);

        uint256 maturityTs = block.timestamp + _tenorDays * 1 days;

        nextId++;
        positions[nextId] = Position({
            notional: notional,
            collateral: _collateralAmount,
            leverage: _leverageX,
            fixedRate: _fixedRateWad,
            start: block.timestamp,
            maturity: maturityTs,
            payFixed: _payFixed,
            settled: false,
            trader: msg.sender
        });

        emit OpenSwap(nextId, msg.sender, _payFixed, notional, _leverageX, _collateralAmount, _fixedRateWad, maturityTs);
        return nextId;
    }

    /**
     * @notice Allow owner of a position to top‑up collateral mid‑life.
     *
     * @param id      Position ID to top‑up.
     * @param amount  Amount of collateral to add (asset.decimals).
     */
    function addCollateral(uint256 id, uint256 amount) external {
        Position storage p = positions[id];
        require(!p.settled, "settled");
        require(msg.sender == p.trader, "owner");
        require(amount > 0, "amt 0");

        asset.transferFrom(msg.sender, address(this), amount);
        p.collateral += amount;
        emit AddCollateral(id, amount);
    }

    /**
     * @notice Net fixed vs floating and release margin. Settle a position after maturity.
     *
     * @param id  Position ID to settle.
     */
    function settleSwap(uint256 id) public {
        Position storage p = positions[id];
        require(block.timestamp >= p.maturity, "not matured");
        require(!p.settled, "re-settl");

        ///@dev whole days for simplicity
        uint256 elapsedDays = (p.maturity - p.start) / 1 days;

        ///@dev WAD annualised
        uint256 floatRate = oracle.rateSinceLast() * 100_000 / 1e27; //@todo

        ///@dev interestPayable = notional × rate × days / 365 / 1e18
        uint256 fixedInt = (p.notional * p.fixedRate * elapsedDays) / (100_000 * YEAR_SECONDS);
        uint256 floatInt = (p.notional * floatRate * elapsedDays) / (100_000 * YEAR_SECONDS);

        int256 pnl;
        if (p.payFixed) {
            ///@dev Trader paid fixed, receives floating ⇒ profit = float − fixed.
            pnl = int256(floatInt) - int256(fixedInt);
        } else {
            ///@dev Trader paid floating ⇒ profit = fixed − float.
            pnl = int256(fixedInt) - int256(floatInt);
        }

        int256 newBal = int256(p.collateral) + pnl;
        p.settled = true;

        if (newBal > 0) {
            asset.transfer(p.trader, uint256(newBal));
        }
        ///@dev else newBal ≤ 0: collateral exhausted, protocol retains deficit.

        emit Settled(id, pnl);
    }
}
