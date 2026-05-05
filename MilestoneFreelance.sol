// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
}

contract MilestoneFreelance {

    struct Milestone {
        string description;
        uint payoutAmount;
        bytes32 deliverableHash;
        bool isApproved;
    }

    IERC20 public token;
    address public client;
    address public freelancer;

    Milestone[3] public milestones;
    uint public currentMilestone;

    constructor(address _token, address _freelancer) {
        client = msg.sender;
        freelancer = _freelancer;
        token = IERC20(_token);
    }

    //  Lock total escrow
    function fundContract(uint totalAmount) external {
        require(msg.sender == client, "Only client");
        require(totalAmount > 0, "Invalid amount");

        token.transferFrom(msg.sender, address(this), totalAmount);

        uint split = totalAmount / 3;

        milestones[0] = Milestone("Phase 1", split, 0, false);
        milestones[1] = Milestone("Phase 2", split, 0, false);
        milestones[2] = Milestone("Phase 3", split, 0, false);
    }

    //  Approve milestone
    function approveMilestoneDelivery(uint id, bytes32 hash) external {
        require(msg.sender == client, "Only client");
        require(id < 3, "Invalid milestone");

        // Sequential gate
        if (id > 0) {
            require(milestones[id - 1].isApproved, "Previous milestone not approved");
        }

        Milestone storage m = milestones[id];

        require(!m.isApproved, "Already approved");

        m.deliverableHash = hash;
        m.isApproved = true;

        //  Payment release
        token.transfer(freelancer, m.payoutAmount);
    }

    //  View milestone
    function getMilestone(uint id) public view returns (Milestone memory) {
        return milestones[id];
    }
}
