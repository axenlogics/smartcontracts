// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract CrowdFunding {
    // Struct to represent a funding request
    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    // Mapping to track contributors and their contributions
    mapping(address=>uint) public contributors;
    uint public noOfContributors;
    uint public minimumContribution;
    address public manager;
    mapping(uint=>Request) public requests;
    uint public numRequests;
    uint public deadline;
    uint public target;
    uint public raisedAmount;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    // Modifier to restrict access to contract owner
    modifier onlyOwner {
        require(msg.sender == manager, "You are not the owner");
        _;
    }

    // Function to create a funding request
    function createRequest(string calldata _description, address payable _recipient, uint _value) public onlyOwner {
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    // Function for contributors to make a contribution
    function contribution() public payable {
        require(block.timestamp < deadline, "Deadline has been passed");
        require(msg.value >= minimumContribution, "Minimum contribution requie is 100 wei");

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    // Function to get the contract balance
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    // Function to refund contributors if conditions met
    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target, "Your are not eligible for refund");
        require(contributors[msg.sender] > 0, "You are not the contributors");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;

    }

    // Function for contributors to vote on a funding request
    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0, "You are not the contributors");
        Request storage request = requests[_requestNo];
        require(request.voters[msg.sender] == false, "You already voted");
        request.voters[msg.sender] = true;
        request.noOfVoters++;
    }

    // Function to make a payment to a funding request if conditions met
    function makePayment(uint _requestNo) public onlyOwner{
        require(raisedAmount >= target, "Target is not reached");
        Request storage request = requests[_requestNo];
        require(request.completed == false, "The request has been completed");
        require(request.noOfVoters > noOfContributors/2, "Majority does not support the request");
        request.recipient.transfer(request.value);
        request.completed = true;
    }

}


/* 
Algorithm 

*/