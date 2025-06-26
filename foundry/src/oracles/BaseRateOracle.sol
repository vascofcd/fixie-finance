// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IAaveV3PoolAddressesProvider} from "../interfaces/aave/IAaveV3PoolAddressesProvider.sol";

abstract contract BaseRateOracle {
    struct Observation {
        uint40 ts; // timestamp of the snapshot   (fits until year 2106)
        uint216 indexRay; // liquidity index at that ts  (27-decimals)
    }

    address public immutable asset;
    Observation public lastObs;

    function decimals() external view virtual returns (uint8);
    function description() external view virtual returns (string memory);
    function version() external view virtual returns (uint256);
    function latestRoundData()
        external
        view
        virtual
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function update() external virtual;
    function rateSinceLast() external view virtual returns (uint256 yieldRay);
}
