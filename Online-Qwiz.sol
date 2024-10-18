// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract QuizContract {
    address public owner;
    IERC20 public rewardToken;

    struct Quiz {
        string title;
        string[] questions;
        bytes32[] correctAnswers; // Store as keccak256 hashed answers for security
        uint256 rewardPerQuestion;
        uint256 participants;
    }

    struct Participant {
        bool participated;
        uint256 score;
    }

    mapping(uint256 => Quiz) public quizzes;
    mapping(uint256 => mapping(address => Participant)) public quizParticipants;
    uint256 public quizCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _rewardTokenAddress) {
        owner = msg.sender;
        rewardToken = IERC20(_rewardTokenAddress);
    }

    // Creates a new quiz with questions, answers, and reward per correct answer
    function createQuiz(
        string memory _title,
        string[] memory _questions,
        string[] memory _correctAnswers,
        uint256 _rewardPerQuestion
    ) public onlyOwner {
        require(_questions.length == _correctAnswers.length, "Questions and answers length mismatch");

        Quiz storage newQuiz = quizzes[quizCount];
        newQuiz.title = _title;
        newQuiz.rewardPerQuestion = _rewardPerQuestion;
        newQuiz.questions = _questions;

        // Store hashed answers to prevent easy cheating
        for (uint256 i = 0; i < _correctAnswers.length; i++) {
            newQuiz.correctAnswers.push(keccak256(abi.encodePacked(_correctAnswers[i])));
        }

        quizCount++;
    }

    // Allows a user to participate in a quiz by submitting their answers
    function participateInQuiz(uint256 _quizId, string[] memory _answers) public {
        require(_quizId < quizCount, "Quiz does not exist");
        require(!quizParticipants[_quizId][msg.sender].participated, "Already participated");

        Quiz storage quiz = quizzes[_quizId];
        require(_answers.length == quiz.questions.length, "Invalid number of answers");

        uint256 score = 0;

        // Calculate score by comparing submitted answers with correct ones
        for (uint256 i = 0; i < _answers.length; i++) {
            if (keccak256(abi.encodePacked(_answers[i])) == quiz.correctAnswers[i]) {
                score++;
            }
        }

        quizParticipants[_quizId][msg.sender] = Participant(true, score);
        quiz.participants++;

        _distributeReward(msg.sender, score * quiz.rewardPerQuestion);
    }

    // Distributes reward tokens based on the quiz score
    function _distributeReward(address _participant, uint256 _amount) internal {
        require(rewardToken.transfer(_participant, _amount), "Reward transfer failed");
    }

    // Returns basic details of a quiz
    function getQuizDetails(uint256 _quizId) public view returns (
        string memory title,
        uint256 questionsCount,
        uint256 participants
    ) {
        require(_quizId < quizCount, "Quiz does not exist");
        Quiz storage quiz = quizzes[_quizId];
        return (quiz.title, quiz.questions.length, quiz.participants);
    }

    // Checks if a user has participated in a specific quiz
    function hasUserParticipated(uint256 _quizId, address _user) public view returns (bool) {
        require(_quizId < quizCount, "Quiz does not exist");
        return quizParticipants[_quizId][_user].participated;
    }

    // Retrieves the score of a participant for a specific quiz
    function getScore(uint256 _quizId, address _user) public view returns (uint256) {
        require(_quizId < quizCount, "Quiz does not exist");
        require(quizParticipants[_quizId][_user].participated, "User did not participate");
        return quizParticipants[_quizId][_user].score;
    }

    // Allows the owner to fund the contract with reward tokens
    function fundContract(uint256 _amount) public onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Funding failed");
    }

    // Allows the owner to withdraw tokens from the contract
    function withdrawTokens(uint256 _amount) public onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= _amount, "Insufficient balance");
        require(rewardToken.transfer(msg.sender, _amount), "Withdraw failed");
    }
}
