// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {TencentLinkConsumer} from "../src/TencentLinkConsumer.sol";

contract testTencentLinkConsumer is Test {
    // Declare contract
    TencentLinkConsumer consumer;
    
    // Declare users
    address deployer;
    address user1;
    address user2;

    // Access fee for records
    uint256 accessFee;

    // Declare events
    event RecordAdded(
        address user,
        bytes32 requestid,
        string fileurl,
        uint256 accessFee
    );

    event AccessRequested(
        address indexed requester, 
        address indexed targetUser);

    // Structs
    struct TLEHR{
        bytes32 requestId;
        string url;
    }

    function setUp() public{
        // Initiate users
        deployer = address(1);
        user1 = address(2);
        user2 = address(3);

        // Access fee amount
        accessFee = 2 ether;
        string memory source =
            "const userid = args[0];"
            "const apiResponse = await Functions.makeHttpRequest({"
            "url: `https://service-80iaz38k-1322254003.de.apigw.tencentcs.com/chainlink/${userid}`});"
            "const { data } = apiResponse;"
            "return Functions.encodeString(data[0].directory_sample);";
            
        // Deploy consumer
        vm.prank(deployer);
        consumer = new TencentLinkConsumer(0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C,0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, source); 

        // Provide users with tokens
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(address(consumer), 10 ether);
    }

    function testupdateRecord() public{
        // User sets fee
        vm.prank(user1);
        consumer.setUserAccessFee(accessFee);

        // update record and expect emit
        vm.expectEmit(true, true, false, true);
        emit RecordAdded(user1, 0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6, 'www.tencent.cloud.com', 2 ether);
        consumer.uploadRecord(0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6, user1, 'www.tencent.cloud.com', accessFee);

        // Request access
        vm.startPrank(user2);
        vm.expectEmit(true, true, false, true);
        emit AccessRequested(user2, user1);
        consumer.requestAccess{value: accessFee}(user1);
        vm.stopPrank();

        // Approve access
        vm.startPrank(user1);
        consumer.approveAccess(user2);
        vm.stopPrank();

        // get data
        vm.prank(user2);
        (bytes32 reqid, string memory uri, uint256 recordFee)= consumer.getLatestRecord(user1);

        // Check returned values
        assertEq(reqid, 0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6);
        assertEq(uri, 'www.tencent.cloud.com');
        assertEq(recordFee, accessFee);
    }

    function testAddAllowedAddressDuplicated() public{
        // record is uploaded
        consumer.uploadRecord(0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6, user1, 'www.tencent.cloud.com', accessFee);

        // A user tries to get whitelisted 2 times and reverts
        vm.startPrank(user2);
        consumer.addAllowedAddress(user1, user2);
        vm.expectRevert();
        consumer.addAllowedAddress(user1, user2);
        vm.stopPrank();
    }

    function testRequestAccessToItself() public{
        vm.prank(user1);
        vm.expectRevert();
        // Request to itself
        consumer.requestAccess(user1);
    }

    function testRequestAccessWithAlreadyRequestToUser() public{
        // User sets fee
        vm.prank(user1);
        consumer.setUserAccessFee(accessFee);
        // Create record for user 1
        consumer.uploadRecord(0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6, user1, 'www.tencent.cloud.com', accessFee);
        // As user 2
        vm.startPrank(user2);
        // Make request to user1
        consumer.requestAccess{value: accessFee}(user1);
        // Request again and expect revert
        vm.expectRevert();
        consumer.requestAccess{value: accessFee}(user1);
        vm.stopPrank();
    }

    function testRequestAccessWithoutFeeProvided() public{
        // User sets fee
        vm.prank(user1);
        consumer.setUserAccessFee(accessFee);
        // Create record for user 1
        consumer.uploadRecord(0x2ea3e39b471e3e17041d7c9fce4af33e94cbc0f40062b7be8172870fdc324aa6, user1, 'www.tencent.cloud.com', accessFee);
        // As user 2
        vm.startPrank(user2);
        // Request expect revert
        vm.expectRevert();
        consumer.requestAccess(user1);
        vm.stopPrank();
    }

    function testRequestAccessWithoutUploadedRecord() public{
        // As user 2
        vm.prank(user2);
        // Request expect revert
        vm.expectRevert();
        consumer.requestAccess{value: accessFee}(user1);
    }

}
