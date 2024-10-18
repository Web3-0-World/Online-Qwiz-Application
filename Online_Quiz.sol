// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRewardToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract OnlineQuiz {
    struct Question {
        string questionText;
        string[] options;
        uint8 correctOptionIndex;
    }

    struct Quiz {
        string title;
        Question[] questions;
        mapping(address => uint8) scores;
        mapping(address => bool) participants;
        address[] participantAddresses;
        uint256 totalRewards;
    }

    address public owner;
    IRewardToken public rewardToken;
    Quiz[] public quizzes;

    event QuizCreated(uint quizId, string title);
    event ParticipantAdded(uint quizId, address participant, uint8 score);
    event TokensWithdrawn(address owner, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier quizExists(uint quizId) {
        require(quizId < quizzes.length, "Quiz does not exist");
        _;
    }

    constructor(address _rewardTokenAddress) {
        rewardToken = IRewardToken(_rewardTokenAddress);
        owner = msg.sender;
    }

    function createQuiz(string memory title, Question[] memory questions) public onlyOwner {
        Quiz storage newQuiz = quizzes.push();
        newQuiz.title = title;
        newQuiz.questions = questions;
        newQuiz.totalRewards = 0;  // Initialize total rewards
        emit QuizCreated(quizzes.length - 1, title);
    }

    function participateInQuiz(uint quizId, uint8[] memory selectedOptions) public quizExists(quizId) {
        require(!quizzes[quizId].participants[msg.sender], "User has already participated");
        
        uint8 score = 0;
        Quiz storage quiz = quizzes[quizId];

        for (uint i = 0; i < quiz.questions.length; i++) {
            if (selectedOptions[i] == quiz.questions[i].correctOptionIndex) {
                score++;
            }
        }

        quiz.participants[msg.sender] = true;
        quiz.scores[msg.sender] = score;
        quiz.participantAddresses.push(msg.sender);
        emit ParticipantAdded(quizId, msg.sender, score);

        _distributeReward(quizId, score);
    }

    function _distributeReward(uint quizId, uint8 score) internal {
        Quiz storage quiz = quizzes[quizId];
        uint256 reward = (score * 1e18) / quiz.questions.length;  // Example: reward per correct answer
        
        require(rewardToken.balanceOf(address(this)) >= reward, "Not enough reward tokens");
        rewardToken.transfer(msg.sender, reward);
        quiz.totalRewards += reward;
    }

    function getQuizDetails(uint quizId) public view quizExists(quizId) returns (string memory title, uint256 numberOfQuestions, uint256 numberOfParticipants) {
        Quiz storage quiz = quizzes[quizId];
        return (quiz.title, quiz.questions.length, quiz.participantAddresses.length);
    }

    function hasUserParticipated(uint quizId) public view quizExists(quizId) returns (bool) {
        return quizzes[quizId].participants[msg.sender];
    }

    function getScore(uint quizId) public view quizExists(quizId) returns (uint8) {
        return quizzes[quizId].scores[msg.sender];
    }

    function fundContract(uint256 amount) public onlyOwner {
        rewardToken.transfer(address(this), amount);
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient balance");
        rewardToken.transfer(msg.sender, amount);
        emit TokensWithdrawn(msg.sender, amount);
    }
}
