// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CharityFundraiser {

    uint public totalBalance;
    address payable public manager;
    uint public goal;
    uint public donorCount;
    bool public isFundraiserOpen = true;

    // Mapping to track unique donors
    mapping(address => bool) private donors;

    // Events to track donations and withdrawals
    event DonationReceived(address indexed donor, uint amount);
    event FundsWithdrawn(address indexed manager, uint amount);
    event FundraiserClosed();
    event FundraiserReopened();

    // Modifier for actions restricted to the manager
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can perform this operation");
        _;
    }

    // Modifier to check the donation amount
    modifier validDonation() {
        require(msg.value > 0, "Donation must be greater than zero");
        _;
    }

    // Contract constructor, sets the manager and the fundraising goal
    constructor(uint _goal) {
        manager = payable(msg.sender);
        goal = _goal;
    }

    // Function to view the fundraising status
    function fundraiserStatus() public view returns (string memory) {
        if (!isFundraiserOpen) {
            return "Fundraiser closed.";
        } else if (totalBalance >= goal) {
            return "Goal achieved, fundraiser ready to be closed.";
        } else {
            return "Fundraiser open.";
        }
    }

    // Function to donate funds
    function donate() public payable validDonation {
        require(isFundraiserOpen, "Fundraiser is closed");

        totalBalance += msg.value;

        // Add donor only if they have not donated before
        if (!donors[msg.sender]) {
            donors[msg.sender] = true; 
            donorCount += 1;           
        }

        emit DonationReceived(msg.sender, msg.value);
    }

    // Function to withdraw funds only if the goal is reached
    function withdrawFunds() public onlyManager {
        require(isFundraiserOpen, "Fundraiser is closed");
        require(totalBalance >= goal, "Goal not yet reached");

        uint amount = totalBalance;
        totalBalance = 0;

        (bool success, ) = manager.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit FundsWithdrawn(manager, amount);
    }

    // Function to close the fundraiser
    function closeFundraiser() public onlyManager {
        isFundraiserOpen = false;
        emit FundraiserClosed();
    }

    // Function to reopen the fundraiser with restrictions
    function reopenFundraiser() public onlyManager {
        require(totalBalance < goal, "Fundraiser goal has been reached, cannot reopen");

        isFundraiserOpen = true;
        emit FundraiserReopened();
    }
}
