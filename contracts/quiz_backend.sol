// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract QuizApplication is Ownable {
    IERC20 public rewardToken;
    uint256 public quizCount;

    struct Quiz {
        string title;
        string[] questions;
        mapping(uint256 => string[]) answers;
        mapping(uint256 => uint256) correctAnswers;
        uint256 rewardPerCorrectAnswer;
        uint256 maxParticipants;
        address[] participants;
        mapping(address => bool) hasParticipated;
        mapping(address => uint256) scores;
    }

    mapping(uint256 => Quiz) public quizzes;

    event QuizCreated(uint256 quizId, string title, uint256 rewardPerCorrectAnswer, uint256 maxParticipants);
    event QuizParticipated(uint256 quizId, address participant, uint256 score);
    event RewardDistributed(address participant, uint256 reward);

    constructor(address _rewardTokenAddress) Ownable(msg.sender) {
        rewardToken = IERC20(_rewardTokenAddress);
        quizCount = 0;
    }

    function createQuiz(
        string memory _title,
        string[] memory _questions,
        string[][] memory _answers,
        uint256[] memory _correctAnswers,
        uint256 _rewardPerCorrectAnswer,
        uint256 _maxParticipants
    ) public onlyOwner {
        require(_questions.length == _answers.length, "Mismatched questions and answers count");
        require(_questions.length == _correctAnswers.length, "Mismatched questions and correct answers count");

        quizCount++;
        Quiz storage quiz = quizzes[quizCount];
        quiz.title = _title;
        quiz.rewardPerCorrectAnswer = _rewardPerCorrectAnswer;
        quiz.maxParticipants = _maxParticipants;

        for (uint256 i = 0; i < _questions.length; i++) {
            quiz.questions.push(_questions[i]);
            quiz.answers[i] = _answers[i];
            quiz.correctAnswers[i] = _correctAnswers[i];
        }

        emit QuizCreated(quizCount, _title, _rewardPerCorrectAnswer, _maxParticipants);
    }

    function participateInQuiz(uint256 _quizId, uint256[] memory _answers) public {
        Quiz storage quiz = quizzes[_quizId];
        require(!quiz.hasParticipated[msg.sender], "You have already participated in this quiz");
        require(quiz.participants.length < quiz.maxParticipants, "Max participants reached");

        uint256 score = 0;
        for (uint256 i = 0; i < _answers.length; i++) {
            if (_answers[i] == quiz.correctAnswers[i]) {
                score++;
            }
        }

        quiz.hasParticipated[msg.sender] = true;
        quiz.scores[msg.sender] = score;
        quiz.participants.push(msg.sender);

        emit QuizParticipated(_quizId, msg.sender, score);

        _distributeReward(msg.sender, score, quiz.rewardPerCorrectAnswer);
    }

    function _distributeReward(address _participant, uint256 _score, uint256 _rewardPerCorrectAnswer) internal {
        uint256 rewardAmount = _score * _rewardPerCorrectAnswer;
        require(rewardToken.transfer(_participant, rewardAmount), "Reward transfer failed");

        emit RewardDistributed(_participant, rewardAmount);
    }

    function getQuizDetails(uint256 _quizId) public view returns (
        string memory title, 
        uint256 questionCount, 
        uint256 maxParticipants, 
        uint256 currentParticipants
    ) {
        Quiz storage quiz = quizzes[_quizId];
        title = quiz.title;
        questionCount = quiz.questions.length;
        maxParticipants = quiz.maxParticipants;
        currentParticipants = quiz.participants.length;
    }

    function hasUserParticipated(uint256 _quizId, address _user) public view returns (bool) {
        return quizzes[_quizId].hasParticipated[_user];
    }

    function getScore(uint256 _quizId, address _participant) public view returns (uint256) {
        return quizzes[_quizId].scores[_participant];
    }

    function fundContract(uint256 _amount) public onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Funding failed");
    }

    function withdrawTokens(uint256 _amount) public onlyOwner {
        require(rewardToken.transfer(msg.sender, _amount), "Withdraw failed");
    }
}
