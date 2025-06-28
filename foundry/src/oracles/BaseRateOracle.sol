// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IAaveV3PoolAddressesProvider} from "../interfaces/aave/IAaveV3PoolAddressesProvider.sol";
import {IRateOracle} from "../interfaces/IRateOracle.sol";

abstract contract BaseRateOracle is IRateOracle, Ownable {
    /// @param ts           timestamp of the snapshot   (fits until year 2106)
    /// @param indexRay     liquidity index at that ts  (27-decimals)
    struct Observation {
        uint40 ts;
        uint216 indexRay;
    }

    address public immutable asset;
    Observation public lastObs;

    uint256 constant PRECISION = 10_000;
}
