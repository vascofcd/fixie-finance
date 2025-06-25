// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RateOracle} from "../../src/oracles/RateOracle.sol";

contract MockOracle is RateOracle {
    uint256 private mockRate = 200;

    constructor(ERC20 _underlying, uint256 _minSeconds) RateOracle(_underlying, _minSeconds) Ownable(msg.sender) {
        require(address(_underlying) != address(0), "underlying must exist");
    }

    function calculateRateFromTo(uint256 _from, uint256 _to) external view override returns (uint256) {
        require(_from <= _to, "from > to");
        return mockRate;
    }

    function recordRate() external override {}

    function setCurrentRate(address _underlying) internal {
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, _underlying, block.timestamp))) % mockRate;
        mockRate = mockRate + block.timestamp + random;
    }

    function getCurrentRate(address _underlying) internal view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, _underlying, block.timestamp))) % mockRate;
        return mockRate + random;
    }

    function setMockRate(uint256 _rate) external {
        mockRate = _rate;
    }
}
