// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {TencentLinkConsumer} from "../src/TencentLinkConsumer.sol";

contract DeployApiCall is Script{
    string source =
        "const userid = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://service-80iaz38k-1322254003.de.apigw.tencentcs.com/chainlink/${userid}/record`});"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data[0].directory_sample);";

    function run() external returns(TencentLinkConsumer){
        vm.startBroadcast();
        TencentLinkConsumer tenlink = new TencentLinkConsumer(0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C,0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000,source);
        vm.stopBroadcast();

        return(tenlink);
    }
}
