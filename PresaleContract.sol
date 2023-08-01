/*
   ____ _____ _   _ _____   _____ ___  _  _______ _   _ 
  / ___| ____| \ | |_   _| |_   _/ _ \| |/ / ____| \ | |
 | |   |  _| |  \| | | |     | || | | | ' /|  _| |  \| |
 | |___| |___| |\  | | |     | || |_| | . \| |___| |\  |
  \____|_____|_| \_| |_|     |_| \___/|_|\_\_____|_| \_|
                                                                                                               
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./CentToken.sol"; // Import the CENT token contract

contract CENTPresale {
    CENT public centToken;
    address public owner;
    uint256 public presalePrice = 41000000000000; // 0.000041 BNB per CTPAY token
    uint256 public presaleMaxLimit = 1000000 * 10**uint256(18); // Max limit of 1,000,000 CTPAY per account in presale
    uint256 public presaleTotalAmount = 2000000 * 10**uint256(18); // Total presale amount of 2,000,000 CTPAY
    uint256 public presaleUnlockTime;

    mapping(address => uint256) public presaleBalances;

    event PresaleTokensPurchased(address indexed participant, uint256 amount);
    event PresalePriceChanged(uint256 newPrice);

    constructor(address _centToken) {
        centToken = CENT(_centToken);
        owner = msg.sender;
        presaleUnlockTime = block.timestamp + 365 days; // Presale tokens will be locked for 1 year
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier presaleEnabled() {
        require(presaleTotalAmount > 0, "Presale has ended, all tokens sold");
        _;
    }

    function setPresalePrice(uint256 newPrice) external onlyOwner {
        presalePrice = newPrice;
        emit PresalePriceChanged(newPrice);
    }

    function purchasePresaleTokens(uint256 amount) external payable presaleEnabled {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= presaleMaxLimit, "Exceeds maximum limit");
        require(msg.value == amount * presalePrice, "Incorrect amount of BNB");

        require(presaleTotalAmount >= amount, "Not enough tokens available for purchase");

        presaleBalances[msg.sender] += amount;
        presaleTotalAmount -= amount;

        emit PresaleTokensPurchased(msg.sender, amount);
    }

    function claimPresaleTokens() external {
        require(presaleBalances[msg.sender] > 0, "No presale tokens to claim");
        require(block.timestamp >= presaleUnlockTime, "Presale tokens are still locked");

        uint256 amount = presaleBalances[msg.sender];
        presaleBalances[msg.sender] = 0;

        centToken.transfer(msg.sender, amount);
    }

    function recoverUnsoldTokens() external onlyOwner {
        require(block.timestamp >= presaleUnlockTime, "Presale tokens are still locked");
        require(presaleTotalAmount > 0, "No unsold tokens to recover");

        centToken.transfer(owner, presaleTotalAmount);
        presaleTotalAmount = 0;
    }
}
