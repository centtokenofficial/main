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

contract CENTAirdrop {
    CENT public centToken;
    address public owner;
    uint256 public airdropAmount = 10000 * 10**uint256(18); // 10,000 CTPAY per participant
    uint256 public airdropTotalAmount = 1000000 * 10**uint256(18); // Total airdrop amount of 1,000,000 CTPAY
    uint256 public airdropUnlockTime;

    mapping(address => bool) public hasClaimedAirdrop;

    event AirdropClaimed(address indexed participant, uint256 amount);

    constructor(address _centToken) {
        centToken = CENT(_centToken);
        owner = msg.sender;
        airdropUnlockTime = block.timestamp + 365 days; // Airdrop tokens will be locked for 1 year
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier airdropEnabled() {
        require(block.timestamp < airdropUnlockTime, "Airdrop period has ended");
        _;
    }

    function claimAirdrop() external airdropEnabled {
        require(!hasClaimedAirdrop[msg.sender], "You have already claimed the airdrop");

        hasClaimedAirdrop[msg.sender] = true;
        centToken.transfer(msg.sender, airdropAmount);

        emit AirdropClaimed(msg.sender, airdropAmount);
    }

    function recoverAirdropTokens(uint256 amount) external onlyOwner {
        require(block.timestamp >= airdropUnlockTime, "Airdrop tokens are still locked");
        require(amount <= centToken.balanceOf(address(this)), "Insufficient contract balance");

        centToken.transfer(owner, amount);
    }
}
