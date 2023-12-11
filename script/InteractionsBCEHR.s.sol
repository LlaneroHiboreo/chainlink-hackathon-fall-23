// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {BCEHR} from "../src/BCEHRConsumer.sol";

contract InteractionSendRequest is Script{
    // Initialize contract
    BCEHR bcehr;

    function run() external{
        bcehr = BCEHR(0xA676080452DD28adEcCbcfB582803DFE96f93Ec1);
        return makeSendRequest();
    }

    function makeSendRequest() public {
        vm.startBroadcast();
        // Prepare arguments
        string[] memory args = new string[](1);
        args[0] = "P002";

        // Make request to cloud
        bcehr.sendRequest( 516,  args);
        vm.stopBroadcast();   

    }
}

contract InteractionGetInfo is Script{
    // Initialize contract
    BCEHR bcehr;
    address user; // add address user

    function run() external{
        bcehr = BCEHR(0xA676080452DD28adEcCbcfB582803DFE96f93Ec1);
        return getInfo();
    }
    
    function getInfo() public{
        vm.startBroadcast();
        // Get amount in map
        uint256 scoremap = bcehr.getAmountByAdrs(user);
        console.log(scoremap);
        vm.stopBroadcast();
    }
}
