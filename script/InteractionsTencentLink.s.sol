// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {TencentLinkConsumer} from "../src/TencentLinkConsumer.sol";

// user1 sets price fee
contract InteractionsSetUp is Script{
    // Initialize contract
    TencentLinkConsumer tenlink;

    function run() external{
        tenlink = TencentLinkConsumer(0xEA191e44b4576A37Db103f413C27DF5419956B0d);
        return setUserFee();
    }

    function setUserFee() public{
        vm.broadcast();
        tenlink.setUserAccessFee(10000000000000000 wei);
    }
}

// user2 requests access to user1
contract InteractionsRequestAccess is Script{
    // Initialize contract
    TencentLinkConsumer tenlink;
    address user1; // Add address of user1

    function run() external{
        tenlink = TencentLinkConsumer(0xEA191e44b4576A37Db103f413C27DF5419956B0d);
        return requestNewAccess();
    }

    function requestNewAccess() public{
        vm.startBroadcast();
        tenlink.requestAccess{value:10000000000000000 wei}(user1);
        vm.stopBroadcast();
    }
}

// user1 approves access of user 2
contract InteractionsApproveAccess is Script{
    // Initialize contract
    TencentLinkConsumer tenlink;
    address user2; // Add address of user2

    function run() external{
        tenlink = TencentLinkConsumer(0xEA191e44b4576A37Db103f413C27DF5419956B0d);
        return approveNewAccess();
    }

    function approveNewAccess() public{
        vm.broadcast();
        tenlink.approveAccess(user2);
    }
}

// User 1 send requests to upload records
contract InteractionSendRequest is Script{
    // Initialize contract
    TencentLinkConsumer tenlink;

    function run() external{
        tenlink = TencentLinkConsumer(0xEA191e44b4576A37Db103f413C27DF5419956B0d);
        return makeSendRequest();
    }

    function makeSendRequest() public {
        vm.startBroadcast();
        // Set records fee
        tenlink.setUserAccessFee(0.01 ether);

        // Prepare arguments
        string[] memory args = new string[](1);
        args[0] = "P001";

        // Make request to cloud
        tenlink.sendRequest( 516,  args);
        vm.stopBroadcast();
    }
}

// User 2 checks information about user 1
contract InteractionCheckRecords is Script{
    // Initialize contract
    TencentLinkConsumer tenlink;
    address user2; //add address user2

    function run() external{
        tenlink = TencentLinkConsumer(0xEA191e44b4576A37Db103f413C27DF5419956B0d);
        return checkUploadedRecord();
    }

    function checkUploadedRecord() public {
        vm.startBroadcast();
        // Get latest record
        (, string memory url,) = tenlink.getLatestRecord(user2);
        vm.stopBroadcast();
        console.log(url);
    }
}
