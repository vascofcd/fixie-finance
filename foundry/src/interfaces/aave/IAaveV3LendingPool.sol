// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @notice Minimal subset of the Aave V3 Pool
interface IAaveV3LendingPool {
    function getReserveNormalizedIncome(address asset) external view returns (uint256);
}
