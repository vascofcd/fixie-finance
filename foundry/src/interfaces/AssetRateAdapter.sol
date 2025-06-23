// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface AssetRateAdapter {
    function getAnnualizedSupplyRate(address underlying) external view returns (uint256);
}
