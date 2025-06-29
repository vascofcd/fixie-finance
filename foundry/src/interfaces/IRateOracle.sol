// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRateOracle {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);

    function update() external;
}
