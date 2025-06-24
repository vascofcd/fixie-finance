// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IAaveV3LendingPool {
    function getReserveNormalizedIncome(address asset) external view returns (uint256);
}
