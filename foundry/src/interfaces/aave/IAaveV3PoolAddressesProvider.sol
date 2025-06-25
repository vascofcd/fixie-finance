// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @notice Resolves the current Pool address for a given Aave market
interface IAaveV3PoolAddressesProvider {
    function getPool() external view returns (address);
}
