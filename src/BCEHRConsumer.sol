// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract BCEHR is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes s_lastResponse;
    bytes public s_lastError;

    // Router address
    address router;
    
    //Callback gas limit
    uint32 gasLimit = 300000;
    
    // donID 
    bytes32 donID;
    
    // State variable to store the returned amountGenerated information
    uint256 amountGenerated;

    // Map oracle info
    mapping(bytes32=> address) private requestIdToMsgSender;

    // Mapping to keep track of balance
    mapping(address=>uint256) private mapAdrsToBalance;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        uint256 amountGenerated,
        bytes response,
        bytes err
    );

    // java code
    string sourceCode;

    constructor(address _router, bytes32 _donId, string memory _sourceCode) FunctionsClient(_router) ConfirmedOwner(msg.sender){
        router = _router;
        donID = _donId;
        sourceCode = _sourceCode;
    }


    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(sourceCode); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        requestIdToMsgSender[s_lastRequestId] = msg.sender;

        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        amountGenerated = uint256(bytes32(response));
        s_lastError = err;
        // Emit an event to log the response
        emit Response(requestId, amountGenerated, s_lastResponse, s_lastError);

        // Get user current balance
        uint256 currentUserBalance = mapAdrsToBalance[requestIdToMsgSender[requestId]];
        // Updated balance
        uint256 updatedBalance = amountGenerated + currentUserBalance;
        mapAdrsToBalance[requestIdToMsgSender[requestId]] = updatedBalance;
    }

    // Function to get amount by address
    function getAmountByAdrs(address userAddress) public view returns(uint256){
        return mapAdrsToBalance[userAddress];
    }
}
