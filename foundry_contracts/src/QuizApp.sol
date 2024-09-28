// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ScoreToken} from "./ScoreToken.sol";

contract QuizApp {

    ScoreToken scoreToken;
    uint256 public quizCount;

    struct Quiz {
        uint256 id; // id of quiz
        address by; // address of user who started quiz
        string storageId; // storage id of Quiz on ipfs/arweave
        uint256 totalQues; // total ques in a quiz
        bool isActive; // whether quiz is active or not
        uint256[] correctOptions;
    }

    // id to Quiz
    mapping(uint256 => Quiz) public quizzes;
    // address of user to quiz participation
    mapping(address => mapping(uint256 => bool)) public participation;
    // option chosen by a user in a quiz
    mapping(address => mapping(uint256 => uint256[])) public userChosenOptions;
    // address of user to quiz rewards claimed
    mapping(address => mapping(uint256 => bool)) public claimed;

    // Events emitted
    event QuizCreated(uint quizId, string storageId, uint256 totalQues);
    event QuizParticipated(address participant, uint256 quizId, uint256[] selectedOptions);
    event QuizHasEnded(uint quizId);

    // Custom errors
    error QuizNotActive();
    error QuizActive();
    error AlreadyParticipated();
    error CorrectOptionsNotSet();
    error NotParticipated();
    error AlreadyClaimed();
    error AlreadySetCorrectOptions();
    error QuizEnded();
    error QuizNotEnded();
    error NotQuizOwner();
    error NotAllAnswersProvided();

    // Modifiers for checking quiz participation and status
    modifier quizActive(Quiz memory quiz) {
        require(quiz.isActive, QuizNotActive());
        _;
    }

    modifier quizNotActive(Quiz memory quiz) {
        require(!quiz.isActive, QuizActive());
        _;
    }

    modifier hasNotParticipated(uint256 quizId) {
        require(!participation[msg.sender][quizId], AlreadyParticipated());
        _;
    }

    modifier correctOptionsSet(Quiz memory quiz) {
        require(quiz.correctOptions.length != 0, CorrectOptionsNotSet());
        _;
    }

    modifier hasParticipated(uint256 quizId) {
        require(participation[msg.sender][quizId], NotParticipated());
        _;
    }

    modifier hasNotClaimed(uint256 quizId) {
        require(!claimed[msg.sender][quizId], AlreadyClaimed());
        _;
    }

    modifier quizEnded(uint quizId) {
        require(!quizzes[quizId].isActive, QuizNotEnded());
        _;
    }
    modifier quizNotEnded(uint quizId) {
        require(quizzes[quizId].isActive, QuizEnded());
        _;
    }

    modifier onlyQuizOwner(uint quizId) {
        require(quizzes[quizId].by == msg.sender, NotQuizOwner());
        _;
    }

    constructor(){
        scoreToken = new ScoreToken();
    }

    // create a quiz using hash id as the storage id provided by ipfs/arweave and total ques
    function createQuiz(
        string memory storageId,
        uint256 totalQues
    ) external {
        quizzes[quizCount] = Quiz(quizCount, msg.sender, storageId, totalQues, true, new uint256[](0));
        quizCount++;
        emit QuizCreated(quizCount, storageId, totalQues);
    }

    // users can participate and answer quiz ques
    function participateInQuiz(uint quizId, uint256[] memory selectedOptions) external quizActive(quizzes[quizId]) hasNotParticipated(quizId) {
        require(selectedOptions.length == quizzes[quizId].totalQues, NotAllAnswersProvided());
        participation[msg.sender][quizId] = true;
        userChosenOptions[msg.sender][quizId] = selectedOptions;
        emit QuizParticipated(msg.sender, quizId, selectedOptions);
    }

    // quiz creator can end participation in the quiz
    function endQuiz(uint quizId) external quizNotEnded(quizId) onlyQuizOwner(quizId) {
        quizzes[quizId].isActive = false;
        emit QuizHasEnded(quizId);
    }

    // quiz creator enters the correct answer sequence
    function tellCorrectAnswers(uint256 quizId, uint256[] memory correctOptions) public quizEnded(quizId) onlyQuizOwner(quizId) {
        Quiz memory quiz = quizzes[quizId];
        require(quiz.correctOptions.length == 0, AlreadySetCorrectOptions());
        quizzes[quizId].correctOptions = correctOptions;
    }

    // users can match their answers and claim their reward based on correct answers
    function checkAndClaim(uint256 quizId) external quizNotActive(quizzes[quizId])correctOptionsSet(quizzes[quizId]) hasParticipated(quizId) hasNotClaimed(quizId) {
        Quiz memory quiz = quizzes[quizId];
        uint256[] memory chosenOptions = userChosenOptions[msg.sender][quizId];
        uint256[] memory correctOptions = quiz.correctOptions;
        uint256 score = 0;
        for (uint256 i = 0; i < quiz.totalQues; i++) {
            if (chosenOptions[i] == correctOptions[i]) {
                score++;
            }
        }
        scoreToken.mint(msg.sender, score);
        claimed[msg.sender][quizId] = true;
    }

    // users can viwe the score tokens they have till now
    function viewTokens() public view returns (uint256){
        return scoreToken.bal(msg.sender);
    }

}
