// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IAaveV3PoolAddressesProvider} from "../../src/interfaces/aave/IAaveV3PoolAddressesProvider.sol";

contract MockAaveV3PoolAddressesProvider is IAaveV3PoolAddressesProvider {
    address private _pool;

    constructor(address initialPool) {
        _pool = initialPool;
    }

    function setPool(address newPool) external {
        _pool = newPool;
    }

    function getPool() external view override returns (address) {
        return _pool;
    }
}
