// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {QuizApp} from "../src/QuizApp.sol";

contract Deploy is Script {
    QuizApp quizapp;

    function run() public returns(QuizApp) {
        vm.startBroadcast();
        quizapp = new QuizApp();
        vm.stopBroadcast();
        return quizapp;

    }
}
