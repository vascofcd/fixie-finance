// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BaseRateOracle} from "../../src/oracles/BaseRateOracle.sol";
import {WadRayMath} from "../../src/libraries/WadRayMath.sol";

contract MockAaveOracle is BaseRateOracle {
    uint256 private _currentIndexRay;

    constructor(uint256 initialIndexRay) Ownable(msg.sender) {
        _currentIndexRay = initialIndexRay;
        lastObs = Observation(uint40(block.timestamp), uint216(initialIndexRay));
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function description() public pure override returns (string memory) {
        return "Mock Aave liquidity index (18-dec)";
    }

    function version() public pure override returns (uint256) {
        return 1;
    }

    function setCurrentIndexRay(uint256 newIndexRay) external {
        _currentIndexRay = newIndexRay;
    }

    function update() external override {
        lastObs = Observation(uint40(block.timestamp), uint216(_currentIndexRay));
    }

    function rateSinceLast() external view override returns (uint256) {
        return WadRayMath.rayDiv(_currentIndexRay, uint256(lastObs.indexRay)) - WadRayMath.RAY;
    }
}
