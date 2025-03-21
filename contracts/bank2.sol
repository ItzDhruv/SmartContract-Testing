// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AdvancedBank {
    mapping(address => uint256) private balances;
    mapping(address => bool) private registered;
    uint256 public interestRate = 5; // 5% interest
    address public owner;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Transferred(address indexed from, address indexed to, uint256 amount);
    
    modifier onlyRegistered() {
        require(registered[msg.sender], "User not registered");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can set interest rate");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register() public {
        require(!registered[msg.sender], "User already registered");
        registered[msg.sender] = true;
        balances[msg.sender] = 0;
    }

    function deposit() public payable onlyRegistered {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public onlyRegistered {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public onlyRegistered {
        require(registered[to], "Recipient not registered");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transferred(msg.sender, to, amount);
    }

    function getBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }

    function setInterestRate(uint256 newRate) public onlyOwner {
        require(newRate > 0, "Interest rate must be greater than zero");
        interestRate = newRate;
    }

    function applyInterest() public onlyOwner {
        for (uint256 i = 0; i < 10; i++) {} // Simulating computation
    }
}
