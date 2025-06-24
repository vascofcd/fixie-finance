// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract RateOracle is Ownable {
    ERC20 public underlying;
    uint256 public minSeconds;
    uint256 public startTimestamp = 0;
    uint256 public lastUpdateTimestamp = 0;

    mapping(uint256 => uint256) rateTimestamps;

    uint256 constant PRECISION = 100_0000; // 1e6 for 100%

    constructor(ERC20 _underlying, uint256 _minSeconds) {
        require(address(_underlying) != address(0), "Underlying cannot be zero address");

        underlying = _underlying;
        minSeconds = _minSeconds;
    }

    function getRate(uint256 _timestamp) public view returns (uint256 rate) {
        return rateTimestamps[_timestamp];
    }

    function getRateByTimestamp(uint256 _timestamp) public view returns (uint256 rate) {
        uint256 standardTime = getStandardTime(_timestamp);
        return rateTimestamps[standardTime];
    }

    function getStandardTime(uint256 _timestamp) public view returns (uint256 standardTime) {
        return (_timestamp / minSeconds) * minSeconds;
    }

    function setMinSeconds(uint256 _minSeconds) external {
        if (minSeconds != _minSeconds) {
            minSeconds = _minSeconds;
        }
    }

    function calculateRateBetweenTimestamps(uint256 from, uint256 to) external view virtual returns (uint256);
    function recordRate() external virtual;

    function _setRate(uint256 _rate) internal {
        uint256 time = block.timestamp;

        if (time - lastUpdateTimestamp < minSeconds) return; //@todo

        if (time - minSeconds >= lastUpdateTimestamp) {
            uint256 standardTime = (time / minSeconds) * minSeconds;
            rateTimestamps[standardTime] = _rate;
            lastUpdateTimestamp = standardTime;
        }
    }
}
