// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {QuizApp} from "../src/QuizApp.sol";
import {Deploy} from "../script/Deploy.s.sol";

contract Unit is Test {
    QuizApp quizApp;
    Deploy deploy;

    function setUp() public {
        deploy = new Deploy();
        quizApp = deploy.run();
    }

    function testCreateQuiz() public {
        quizApp.createQuiz("quiz1", 5);
        (uint256 id, address by, string memory storageId, uint256 totalQues, bool isActive ) = quizApp.quizzes(0);
        assertEq(id, 0);
        assertEq(by, address(this));
        assertEq(storageId, "quiz1");
        assertEq(totalQues, 5);
        assertTrue(isActive);
    }

    function testParticipateInQuiz() public {
        quizApp.createQuiz("quiz1", 3);
        uint256[] memory selectedOptions = new uint256[](3);
        selectedOptions[0] = 1;
        selectedOptions[1] = 2;
        selectedOptions[2] = 3;
        quizApp.participateInQuiz(0, selectedOptions);
        assertTrue(quizApp.participation(address(this), 0));
    }

    function testClaimReward() public {
        quizApp.createQuiz("quiz1", 3);

        uint256[] memory selectedOptions = new uint256[](3);
        selectedOptions[0] = 1;
        selectedOptions[1] = 2;
        selectedOptions[2] = 3;
        quizApp.participateInQuiz(0, selectedOptions);

        uint256[] memory correctOptions = new uint256[](3);
        correctOptions[0] = 1;
        correctOptions[1] = 2;
        correctOptions[2] = 3;
        quizApp.endQuiz(0);
        
        quizApp.tellCorrectAnswers(0, correctOptions);
        
        quizApp.checkAndClaim(0);
        assertEq(quizApp.viewTokens(),3);
    }

}
