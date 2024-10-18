// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Quiz {
    struct Question {
        string questionText;  // The question text
        string[] options;     // Array of options for the question
        uint256 correctOption; // Index of the correct option
    }

    struct Participant {
        address participantAddress; // Participant's address
        uint256[] selectedOptions; // Array of selected options for each question
    }

    Question[] public questions; // Array to store questions
    mapping(address => Participant) public participants; // Mapping to store participants' selections

    event QuestionAdded(uint256 indexed questionId);
    event ParticipantRegistered(address indexed participant);
    event AnswerSubmitted(address indexed participant, uint256 indexed questionId, uint256 selectedOption);

    // Function to add a new question
    function addQuestion(string memory _questionText, string[] memory _options, uint256 _correctOption) public {
        require(_correctOption < _options.length, "Correct option must be within the range of options.");

        questions.push(Question({
            questionText: _questionText,
            options: _options,
            correctOption: _correctOption
        }));

        emit QuestionAdded(questions.length - 1); // Emit event with question ID
    }

    // Function to register a participant
    function registerParticipant() public {
        require(participants[msg.sender].participantAddress == address(0), "You are already registered.");

        participants[msg.sender] = Participant({
            participantAddress: msg.sender,
            selectedOptions: new uint256[](questions.length) // Initialize selected options array
        });

        emit ParticipantRegistered(msg.sender); // Emit event on registration
    }

    // Function to submit an answer for a question
    function submitAnswer(uint256 questionId, uint256 selectedOption) public {
        require(participants[msg.sender].participantAddress != address(0), "You must be registered to answer.");
        require(questionId < questions.length, "Invalid question ID.");
        require(selectedOption < questions[questionId].options.length, "Invalid option selected.");

        participants[msg.sender].selectedOptions[questionId] = selectedOption; // Store the selected option

        emit AnswerSubmitted(msg.sender, questionId, selectedOption); // Emit event on answer submission
    }

    // Function to get a question by its ID
    function getQuestion(uint256 questionId) public view returns (string memory, string[] memory, uint256) {
        require(questionId < questions.length, "Invalid question ID.");
        Question memory q = questions[questionId];
        return (q.questionText, q.options, q.correctOption);
    }

    // Function to get the participant's selected options
    function getSelectedOptions() public view returns (uint256[] memory) {
        require(participants[msg.sender].participantAddress != address(0), "You must be registered to view your answers.");
        return participants[msg.sender].selectedOptions;
    }

    // Function to check if the answer is correct
    function isAnswerCorrect(uint256 questionId) public view returns (bool) {
        require(questionId < questions.length, "Invalid question ID.");
        uint256 selectedOption = participants[msg.sender].selectedOptions[questionId];
        return selectedOption == questions[questionId].correctOption;
    }
}
