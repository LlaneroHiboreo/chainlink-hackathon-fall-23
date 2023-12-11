// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract TencentLinkConsumer is FunctionsClient, ConfirmedOwner{
      ////////////////////////////////////
     //      VARIABLES/CONTRACTS       //
    ////////////////////////////////////

    // Oracle contracts
    using FunctionsRequest for FunctionsRequest.Request;

    // errors
    error getLatestRecord__noRecordsFoundForProvidedUser();
    error addAllowedAddress__AddressAlreadyAllowed();
    error addAllowedAddress__FeeProvidedNotCorrect();
    error requestAccess__CanNotRequestAutoAccess();
    error requestAccess__AlreadyRequested();
    error approveAccess_NotPendingApprovals();
    error UnexpectedRequestID(bytes32 requestId);

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes s_lastResponse;
    bytes public s_lastError;

    // Initialize oracle info
    address router;
    bytes32 donID;
    uint32 gasLimit = 300000;

    // Java code string
    string sourceCode;

    // Structs
    struct TLEHR{
        bytes32 requestId;
        string url;
        uint256 accessFee;
    }

    struct AccessRequest {
        address requester;
        bool isApproved;
        bool isPending;
    }

    // Mapping TLEHR with user 
    mapping(address => TLEHR[]) private mapUserRecord;
    // Mapping user with allowed addresses
    mapping(address => address[]) private allowedUsers;
    // Mapping that tracks user request approvals
    mapping(address => mapping(address => AccessRequest)) public accessRequests;
    // Map request id with user
    mapping(bytes32=> address) private requestIdToMsgSender;
    // Map user with its custom access fee
    mapping(address => uint256) public userAccessFees;

    // Event logs
    event Response(
        bytes32 indexed requestId,
        string linkUrl,
        bytes response,
        bytes err
    );

    event RecordAdded(
        address user,
        bytes32 requestid,
        string fileurl,
        uint256 accessFee
    );

    event AccessRequested(
        address indexed requester, 
        address indexed targetUser);

    event AccessApproved(
        address requester,
        address approver
    );

    modifier onlyAllowed(address _targetUser, address _requesterUser ) {
        require(isAddressAllowed(_targetUser, _requesterUser), "Require permissions to access information from this user");
        _;
    }

    constructor(address _router, bytes32 _donId, string memory _sourceCode) FunctionsClient(_router) ConfirmedOwner(msg.sender){
        router = _router;
        donID = _donId;
        sourceCode = _sourceCode;
    }

      //////////////////////////
     //      FUNCTIONS       //
    //////////////////////////
    
    // Function for a user to request access
    function requestAccess(address _targetUser) external payable{
        if (_targetUser == msg.sender){
            revert requestAccess__CanNotRequestAutoAccess();
        }

        // Check if there is already request
        if(accessRequests[_targetUser][msg.sender].isPending){
            revert requestAccess__AlreadyRequested();
        }

        // Get price to access record
        uint256 recordFee = userAccessFees[_targetUser];

        // Check that amount send is correct
        if(msg.value != recordFee){
            revert addAllowedAddress__FeeProvidedNotCorrect();
        }

        // Create a new access request
        accessRequests[_targetUser][msg.sender] = AccessRequest({
            requester: msg.sender,
            isApproved: false,
            isPending: true
        });

        emit AccessRequested(msg.sender, _targetUser);
    }

    // Function for the target user to approve access
    function approveAccess(address requester) external {
        if(!accessRequests[msg.sender][requester].isPending){
            revert approveAccess_NotPendingApprovals();
        }

        accessRequests[msg.sender][requester].isApproved = true;
        accessRequests[msg.sender][requester].isPending = false;

        emit AccessApproved(requester, msg.sender);

        addAllowedAddress(msg.sender, requester);
    }

    // Function to check if a user has allowance to get access to user record
    function isAddressAllowed(address _user, address _checkAddress) public view returns (bool) {
        address[] storage allowedAddresses = allowedUsers[_user];

        for (uint256 i = 0; i < allowedAddresses.length; i++) {
            if (allowedAddresses[i] == _checkAddress) {
                return true;
            }
        }
        return false;
    }

    // Function to add an allowed address for a specific user
    function addAllowedAddress(address _user, address _requester) public{
        // Check that addresses is not already approved
        if(isAddressAllowed(_user, _requester)){
            revert addAllowedAddress__AddressAlreadyAllowed();
        }
        
        // Get price to access record
        uint256 recordFee = userAccessFees[_user];

        // Transfer tokens to the user and make sure the transfer succeded
        (bool sent, ) =_user.call{value: recordFee}("");
        require(sent, "Eth could not be send");

        // Add user to patient allowed users array
        allowedUsers[_user].push(_requester);
    }

    // User must set fee
    function setUserAccessFee(uint256 _newFee) external {
        userAccessFees[msg.sender] = _newFee;
    }

    // Function to upload record
    function uploadRecord(bytes32 _requestid, address _user, string memory _file_url, uint256 _accessFee) public{
        // Create a new TLEHR struct and populate the mapping
        TLEHR memory newRecord = TLEHR(_requestid, _file_url, _accessFee);
        mapUserRecord[_user].push(newRecord); 
        // emit event
        emit RecordAdded(_user, _requestid, _file_url, _accessFee);
    }

    // Function to retrieve latest record of a given address
    function getLatestRecord(address _userAddress) public view onlyAllowed(_userAddress, msg.sender) returns (bytes32, string memory, uint256) {
        // Check if record exists for user
        TLEHR[] storage userRecords = mapUserRecord[_userAddress];
        if(userRecords.length == 0){
            revert getLatestRecord__noRecordsFoundForProvidedUser();
        }

        // Get latest user record and return
        TLEHR storage latestRecord = userRecords[userRecords.length - 1];
        return (latestRecord.requestId, latestRecord.url, latestRecord.accessFee);
    }

    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId){
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
        string memory link_url = string(response);
        s_lastError = err;
        // Emit an event to log the response
        emit Response(requestId, link_url, s_lastResponse, s_lastError);

        // Get user
        address currentUser = requestIdToMsgSender[s_lastRequestId];
        
        // Get fee set by user
        uint256 accessFee = userAccessFees[msg.sender];

        // Upload record
        uploadRecord(s_lastRequestId, currentUser, link_url, accessFee);
    }
}