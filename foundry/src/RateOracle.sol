// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract RateOracle is FunctionsClient, ConfirmedOwner {
    struct Request {
        address caller;
        bytes32 swapId;
    }

    mapping(bytes32 => Request) public requests;
    mapping(bytes32 => uint256) public rates; // swapId => rate (1e18)

    uint64 public subscriptionId;
    uint32 public gasLimit;
    bytes32 public donId;
    string public source;

    event RateRequested(bytes32 requestId, bytes32 swapId);
    event RateReceived(bytes32 requestId, bytes32 swapId, uint256 rate);

    constructor(address router, uint64 _subscriptionId, uint32 _gasLimit, bytes32 _donId)
        FunctionsClient(router)
        ConfirmedOwner(msg.sender)
    {
        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
        donId = _donId;
        source = "const aaveEndpoint = 'https://aave-api-v3.onrender.com/reserve?symbol=USDC&chain=eth';"
            "const response = await Functions.makeHttpRequest({ url: aaveEndpoint });"
            "if (response.error) throw Error('API Error');" "const liquidityRate = response.data[0].liquidityRate;"
            "return Functions.encodeUint256(BigInt(liquidityRate) / 1e9;";
    }

    function requestRate(bytes32 swapId) external {
        bytes32 requestId = _sendRequest();
        requests[requestId] = Request(msg.sender, swapId);
        emit RateRequested(requestId, swapId);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory) internal override {
        Request memory req = requests[requestId];
        uint256 rate = abi.decode(response, (uint256));
        rates[req.swapId] = rate;
        emit RateReceived(requestId, req.swapId, rate);
    }

    function _sendRequest() private returns (bytes32) {
        // FunctionsRequest memory req;
        // req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
        // return _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donId);
    }
}
