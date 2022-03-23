// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /**
    * We will using this below to help generate a random number
     */
    uint256 private seed;

    /**
    * A little magic, Google what events are in solidity
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    /*
    * Variable to hold all the wave sent.
     */
    Wave[] waves;
    
    /*
    * THis is an address => mapping, meaning I can associate an address with a number!
    * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("I AM A SMART CONTRACT. POG.");
        /**
        * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        /**
        * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp
         */
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "wait 15m"
        );

        /*
        *   Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
        *   Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
        *   Give a 50% chance that user wins the prize. 
        */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
            *   The same code we had before to send the price 
            */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);

        
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}