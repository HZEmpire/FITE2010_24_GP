# FITE2010_24_GP
The Group Project for the HKU FITE2010 24 Spring Course

This project is a group project for the HKU FITE2010 24 Spring Course. The project is to create a decentralized application with smart contract and web3.js. The selected topic is a crowdfunding platform. 

The project is done by a group of 5 students. The group members are:
Xu Haozhou, Zhu Lingxiao, Song Wenhao, Jin Qizheng, and .

## Feature

### Create a Campaign
The contract allowed the user to create a campaign by setting the target amount and the deadline of the campaign.

### Donate to a Campaign
The contract allowed the user to donate to a campaign by specifying the campaign ID and the amount to donate if the campaign is still open.

### Get the Campaign Information
The contract allowed the user to get the information of a campaign by specifying the campaign ID.

### Claim the Fund
The contract allowed the creator of the campaign to claim the fund if the campaign is ended. Other users could not claim the fund.

## Test Cases
The test cases are provided in the [`test`](/test/) folder.
- Task 1: Create a Campaign
- Task 2: Donate to a Campaign
- Task 3: Block claim from non-creator
- Task 4: Block claim if the campaign is not ended
- Task 5: Claim the fund

## Sample Output
The sample output of deploy and test be found in the [`Sample`](/Sample/) folder.

## Initialization and Deployment
Please run the deploy and test scripts under the Docker environment provided for the Lab 1 to Lab 3.

The test environment is the Ganache and Truffle provided by the Docker environment.

### Step 1
Please create a new folder as project folder and enter the folder, run the following command to initialize the project:
```bash
truffle init
```

### Step 2
Please copy the files in the [`contracts`](/contracts/) folder to the `contracts` folder in the project.

### Step 3
Please copy the files in the [`migrations`](/migrations/) folder to the `migrations` folder in the project.

### Step 4
Please copy the files in the [`test`](/test/) folder to the `test` folder in the project.

### Step 5
Please compile the smart contract by running the following command:
```bash
truffle compile
```

### Step 6
Start a new terminal and run the following command to start the Ganache:
```bash
ganache
```

### Step 7
Deploy the smart contract and test the smart contract by running the following command:
```bash
truffle migrate
truffle test
```

## Contributors
- Xu Haozhou