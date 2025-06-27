// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRateOracle {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function update() external;
    function rateSinceLast() external view returns (uint256 yieldRay);
}
