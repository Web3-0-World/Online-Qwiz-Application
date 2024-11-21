// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Contract {
    address private provider;
    constructor () {
        provider = msg.sender;
    }
   
    // Structure for User Data
    struct Users{
        string userName;
        uint score;
    }

    // Course structure
    struct Courses{
        uint id;
        string imgsrc;
        string title;
        string descrip;
        string videourl;
        uint price;
    }

    // Quiz structure
    struct Quiz{
        string question;
        string choiceA;
        string choiceB;
        string choiceC;
        string choiceD;
        string correctAns;
    }

    // Array to record all users address
    address[] usersAddress;

    // Array to record all id of course
    uint[] courseIds;

    // Array to record all Courses
    mapping(uint => Courses) courseRecord;

    // Mapping of address of user to user data
    mapping (address => Users) usersRecord;

    // Quiz Id
    uint quizId = 0;

    // Quiz Mapping
    mapping (uint => Quiz[]) public  quizRecord;

    // Course => Quize mapping
    mapping (uint => uint)  public  courseQuizRecord;

    // Events for Smart Contract
    event registerNewUserEvent(address,string,uint,string);

    // Add user
    function registerNewUser(string memory userName) external returns(string memory)  {
        if(bytes(usersRecord[msg.sender].userName).length == 0){
            usersAddress.push(msg.sender);
            usersRecord[msg.sender].userName = userName;
            usersRecord[msg.sender].score = 0;
            emit registerNewUserEvent(msg.sender,userName,0,"Registration Successful");
            return "Registeration Successful!";
        }
        else
        emit registerNewUserEvent(msg.sender,userName,0,"You already have an Account");{
            return "You have already have an Account";
        }
    }

    // Display User Profile
    function displayUserProfile() external view returns(string memory,uint ) {
        return (usersRecord[msg.sender].userName,usersRecord[msg.sender].score);
    }
   
    mapping(address => mapping(uint256 => bool)) public userCourses;

    // Add the function to mark a course as purchased for a user
    function addPurchasedCourse(uint256 courseId) public {
        userCourses[msg.sender][courseId] = true;
    }

    // Add a function to check if a course has been purchased by a user
    function hasPurchasedCourse(address user, uint256 courseId) public view returns (bool) {
        return userCourses[user][courseId];
    }
    // // Display Added Users
    // function displayAllUsers() external view returns (address[] memory, string[] memory) {
    //     require(msg.sender == provider,"Only Provider can access this feature");
    //     uint userCount = usersAddress.length;
    //     address[] memory addresses = new address[](userCount);
    //     string[] memory usernames = new string[](userCount);
    //     for (uint i = 0; i < userCount; i++) {
    //         addresses[i] = usersAddress[i];
    //         usernames[i] = usersRecord[usersAddress[i]].userName;
    //     }
    //     return (addresses, usernames);
    // }

    // Check for account
    function Login() external view returns (bool) {
        if(bytes(usersRecord[msg.sender].userName).length == 0){
            // User Not Registered
            return false;
        }
        else{
            // User Registered
            return true;
        }
    }

    // Check for admin
    function checkAdmin() external view returns(bool){
        if(msg.sender == provider){
            return true;
        }
        else{
            return false;
        }
    }

    // Function to get and store course
    function getCourse(uint _id,string memory _imgsrc,string memory _title,string memory _descrip,string memory _videourl,uint _price) external returns(string memory){
        if(_id > 0 && bytes(courseRecord[_id].videourl).length == 0){
            courseIds.push(_id);
            courseRecord[_id].id = _id;
            courseRecord[_id].imgsrc = _imgsrc;
            courseRecord[_id].title = _title;
            courseRecord[_id].descrip = _descrip;
            courseRecord[_id].videourl = _videourl;
            courseRecord[_id].price = _price;
            return "Course Added";
        }
        else{
            return "Cannot Add Course";
        }
    }
   

    // Display All Courses
    function displayCourses() external view returns(Courses[] memory){
        uint courseLength = courseIds.length;
        Courses[] memory course = new Courses[](courseLength);
        for(uint i=0; i<courseLength; i++){
            course[i] = courseRecord[courseIds[i]];
        }

        return course;
    }

    // To update score of the user
    function updateScore( uint _score) public {
        usersRecord[msg.sender].score += _score;
    }

    function getDataForLeaderBoard() view public  returns(address[] memory) {
        return usersAddress;
    }

   
    function questionCreation(string memory _question,
    string memory _choiceA,
    string memory _choiceB,
    string memory _choiceC,
    string memory _choiceD,
    string memory _crcAns
    ) public  returns (Quiz memory) {
        Quiz memory q = Quiz(_question,_choiceA,_choiceB,_choiceC,_choiceD,_crcAns);
        quizId += 1;
        quizRecord[quizId].push(q);
        return q;
    }

    function quizCreate(uint _courseId,uint _noOfQuestions,Quiz[] memory _quizzes) public  {
        quizId += 1;
        for (uint i = 0; i < _noOfQuestions; i++)
        {
            Quiz memory  newq = Quiz(
            _quizzes[i].question,
            _quizzes[i].choiceA,
            _quizzes[i].choiceB,
            _quizzes[i].choiceC,
            _quizzes[i].choiceD,
            _quizzes[i].correctAns);
            quizRecord[quizId].push(newq);
        }        
        courseQuizRecord[_courseId] = quizId;

    }

    function getQuizAns(uint _quizId) public view returns(string[] memory) {
        uint length = quizRecord[_quizId].length;
        string[] memory answers = new string[](length);
        for (uint i=0; i < quizRecord[_quizId].length; i++)
        {
            answers[i] = quizRecord[_quizId][i].correctAns;
        }
        return answers;
    }

    // Function to get quiz questions for a course
    function getQuiz(uint _courseId) public view returns (Quiz[] memory) {
        uint quizIdForCourse = courseQuizRecord[_courseId];
        return quizRecord[quizIdForCourse];
    }

    // Get leader Board
    function getLeaderboard() public view returns (Users[] memory) {
        Users[] memory leaderboard = new Users[](usersAddress.length);
        
        for (uint i = 0; i < usersAddress.length; i++) {
            address userAddress = usersAddress[i];
            leaderboard[i] = usersRecord[userAddress];
        }
        
        return leaderboard;
    }
}

// Deployed Contract Address: 0xaAE04Cd5c6ed58B1448C359F78f6AF9A3A117812
