// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAaveV3LendingPool} from "../interfaces/aave/IAaveV3LendingPool.sol";
import {WadRayMath} from "../libraries/WadRayMath.sol";
import {RateOracle} from "./RateOracle.sol";

contract AaveRateOracle is RateOracle {
    IAaveV3LendingPool public aaveV3LendingPool;

    uint256 constant MIN_SECONDS = 3600; // 1 hour

    constructor(address _aaveV3LendingPoolAddress, ERC20 _underlying)
        RateOracle(_underlying, MIN_SECONDS)
        Ownable(msg.sender) //@todo check
    {
        require(address(_aaveV3LendingPoolAddress) != address(0), "AaveV3LendingPoolAddress cannot be zero address");
        require(address(_underlying) != address(0), "Underlying cannot be zero address");

        aaveV3LendingPool = IAaveV3LendingPool(_aaveV3LendingPoolAddress);
    }

    function calculateRateBetweenTimestamps(uint256 _from, uint256 _to) external view override returns (uint256) {
        require(_from <= _to, "From timestamp must be less than or equal to To timestamp");

        uint256 rateFrom = getRateByTimestamp(_from);
        uint256 rateTo = getRateByTimestamp(_to);
        if (getStandardTime(_to) > lastUpdateTimestamp) {
            rateTo = aaveV3LendingPool.getReserveNormalizedIncome(address(underlying));
        }
        if (rateTo >= rateFrom) {
            return WadRayMath.rayToWad(WadRayMath.rayDiv(rateTo, rateFrom) - WadRayMath.RAY);
        } else {
            return 0;
        }
    }

    function recordRate() external override {
        uint256 resultRay = aaveV3LendingPool.getReserveNormalizedIncome(address(underlying));
        if (resultRay != 0) {
            _setRate(resultRay);
        }
    }
}
