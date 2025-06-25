// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IAaveV3LendingPool} from "../../src/interfaces/aave/IAaveV3LendingPool.sol";

contract MockAaveV3LendingPool is IAaveV3LendingPool {
    mapping(address => uint256) private _normalizedIncome;

    function setReserveNormalizedIncome(address asset, uint256 indexRay) external {
        _normalizedIncome[asset] = indexRay;
    }

    function getReserveNormalizedIncome(address asset) external view override returns (uint256) {
        uint256 idx = _normalizedIncome[asset];
        require(idx != 0, "MOCK: index not set");
        return idx;
    }
}
