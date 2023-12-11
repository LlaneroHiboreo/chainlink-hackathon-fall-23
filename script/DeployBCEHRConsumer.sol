// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {BCEHR} from "../src/BCEHRConsumer.sol";

contract DeployApiCall is Script{

    string source = 
        "const userid = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://service-80iaz38k-1322254003.de.apigw.tencentcs.com/chainlink/${userid}/stats`});"
        "const weightStepsWalked = 0.1;"
        "const weightBmi = 0.15;"
        "const weightCalories = 0.2;"
        "const weightTemperature = 0.1;"
        "const weightAirQuality = 0.15;"
        "const weightUvExposure = 0.1;"
        "const weightHumidity = 0.2;"
        "const { data } = apiResponse;"
        "const stepsWalked = data[0].steps_walked;"
        "const bmi = data[0].bmi;"
        "const calories = data[0].calories;"
        "const temperature = data[0].temperature;"
        "const airquality = data[0].airquality;"
        "const uvexposure = data[0].uvexposure;"
        "const humidity = data[0].humidity;"
        "const insuranceParameter ="
        "(weightStepsWalked * stepsWalked) +"
        "(weightBmi * bmi) +"
        "(weightCalories * calories) +"
        "(weightTemperature * temperature) +"
        "(weightAirQuality * airquality) +"
        "(weightUvExposure * uvexposure) +"
        "(weightHumidity * humidity);"
        "console.log(Math.floor(insuranceParameter));"
        "return Functions.encodeUint256(Math.floor(insuranceParameter));";

    function run() external returns(BCEHR){
        vm.startBroadcast();
        BCEHR bcehr = new BCEHR(0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, source);
        vm.stopBroadcast();

        return(bcehr);
    }
}
