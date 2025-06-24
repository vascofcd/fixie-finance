// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AaveRateOracle} from "./AaveRateOracle.sol";
import {RateOracle} from "./RateOracle.sol";

contract RateOracleAggregator is Ownable {
    enum OracleType {
        AAVE,
        COMPOUND
    }

    // Current impls
    address public aaveAddress;

    // Oracles
    uint256 public internalId = 1;
    mapping(OracleType => mapping(address => address)) public oracleTypes;
    mapping(uint256 => address) public oracles;

    constructor(address _aaveAddress) Ownable(msg.sender) {
        aaveAddress = _aaveAddress;
    }

    function createAaveOracle(ERC20 asset) public {
        require(oracleTypes[OracleType.AAVE][address(asset)] == address(0), "Oracle already exists");

        oracleTypes[OracleType.AAVE][address(asset)] = address(new AaveRateOracle(aaveAddress, asset));

        oracles[internalId] = oracleTypes[OracleType.AAVE][address(asset)];
        internalId++;
    }

    function getRateFromTo(uint256 _oracleId, uint256 _from, uint256 _to) external view returns (uint256) {
        return RateOracle(oracles[_oracleId]).calculateRateBetweenTimestamps(_from, _to);
    }

    function updateAaveOracle(address asset) external {
        address oracle = oracleTypes[OracleType.AAVE][asset];
        require(oracle != address(0), "Aave oracle not found for this asset");
        RateOracle(oracle).recordRate();
    }
}
