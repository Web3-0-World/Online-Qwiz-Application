## QuizApp Contract

The `QuizApp` contract allows users to create quizzes, participate in them, and claim rewards based on their answers.

### Key Features

- **Create Quizzes**: Creators can create quizzes by providing hash id of quiz questions and options store on ipfs/arweave through frontend interaction.
- **Participate in Quizzes**: Users can participate in quizzes and submit their answers in form of an array.
- **Manage Quizzes**: Quiz creators can end quizzes and set correct answers.
- **Claim Rewards**: Users can claim rewards based on the correctness of their answers.


### Usage Example

1. Deploy the `QuizApp` contract.
2. Create a quiz using `createQuiz`.
3. Users can participate using `participateInQuiz`.
4. Quiz owners can end the quiz using `endQuiz` and set correct answers with `tellCorrectAnswers`.
5. Users can check their scores and claim rewards using `checkAndClaim`.


## Documentation of Foundry

https://book.getfoundry.sh/

## Usage

## Install Openzeppelin Contracts
```shell
$ forge install OpenZeppelin/openzeppelin-contracts --no-commit
```


### Build

```shell
$ forge build
```

### Compile

```shell
$ forge compile
```

### Deploy

```shell
$ forge script script/Deploy.s.sol
```

### Test

```shell
$ forge test
```