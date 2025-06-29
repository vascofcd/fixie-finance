// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BaseRateOracle} from "../oracles/BaseRateOracle.sol";
import {IAaveV3PoolAddressesProvider} from "../interfaces/aave/IAaveV3PoolAddressesProvider.sol";
import {IAaveV3LendingPool} from "../interfaces/aave/IAaveV3LendingPool.sol";
import {WadRayMath} from "../libraries/WadRayMath.sol";

contract AaveRateOracle is BaseRateOracle {
    IAaveV3PoolAddressesProvider public immutable provider;

    uint256 public s_lastResponse;

    uint256 constant RAY = 1e27;

    constructor(address _provider, address _asset) Ownable(msg.sender) {
        provider = IAaveV3PoolAddressesProvider(_provider);
        asset = _asset;

        uint256 startIdx = IAaveV3LendingPool(provider.getPool()).getReserveNormalizedIncome(_asset);
        lastObs = Observation(uint40(block.timestamp), uint216(startIdx));
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function description() public pure override returns (string memory) {
        return "Aave reserve normalized income (18-dec)";
    }

    function version() public pure override returns (uint256) {
        return 1;
    }

    function update() external override {
        uint256 nowIdx = IAaveV3LendingPool(provider.getPool()).getReserveNormalizedIncome(asset);
        s_lastResponse = WadRayMath.rayDiv(nowIdx, uint256(lastObs.indexRay)) - WadRayMath.RAY;
    }
}
