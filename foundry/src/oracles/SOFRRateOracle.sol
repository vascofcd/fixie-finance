// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {BaseRateOracle} from "../oracles/BaseRateOracle.sol";

contract SOFRRateOracle is BaseRateOracle, FunctionsClient {
    using Strings for uint256;
    using FunctionsRequest for FunctionsRequest.Request;

    error UnexpectedRequestID(bytes32 requestId);

    struct FunctionsConfig {
        string source;
        uint64 subId;
        uint32 gasLimit;
        bytes32 donId;
    }

    bytes32 public s_lastRequestId;
    bytes32 public s_lastResponse;
    bytes32 public s_lastError;
    uint32 public s_lastResponseLength;
    uint32 public s_lastErrorLength;

    FunctionsConfig public s_functionsConfig;

    constructor(address functionsRouter, FunctionsConfig memory _config)
        Ownable(msg.sender)
        FunctionsClient(functionsRouter)
    {
        s_functionsConfig = _config;
    }

    function decimals() external pure override returns (uint8) {
        return 5;
    }

    function description() external pure override returns (string memory) {
        return "Secured Overnight Financing Rate Data";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {}

    function update() external override {
        ///@dev 1 because it fetches the latest SOFR rate
        _sendFunctionsSOFRRateFetchRequest(1);
    }

    function rateSinceLast() external view override returns (uint256 yieldRay) {
        return uint256(s_lastResponse);
    }

    function _sendFunctionsSOFRRateFetchRequest(uint256 _tenor) internal returns (bytes32 _reqId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_functionsConfig.source);

        string[] memory _args = new string[](1);
        _args[0] = _tenor.toString();

        if (_args.length > 0) req.setArgs(_args);

        _reqId =
            _sendRequest(req.encodeCBOR(), s_functionsConfig.subId, s_functionsConfig.gasLimit, s_functionsConfig.donId);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }

        s_lastResponse = bytesToBytes32(response);
        s_lastResponseLength = uint32(response.length);
        s_lastError = bytesToBytes32(err);
        s_lastErrorLength = uint32(err.length);
    }

    function bytesToBytes32(bytes memory b) private pure returns (bytes32 out) {
        uint256 maxLen = 32;
        if (b.length < 32) {
            maxLen = b.length;
        }
        for (uint256 i = 0; i < maxLen; ++i) {
            out |= bytes32(b[i]) >> (i * 8);
        }
        return out;
    }

    // ---------------------------------------------------------------------
    // FunctionsConfig setters
    // ---------------------------------------------------------------------
    function updateFunctionsGasLimit(uint32 newGaslimit) external onlyOwner {
        s_functionsConfig.gasLimit = newGaslimit;
    }

    function updateSubId(uint64 newSubId) external onlyOwner {
        s_functionsConfig.subId = newSubId;
    }

    function updateSource(string memory newSource) external onlyOwner {
        s_functionsConfig.source = newSource;
    }
}
