// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PiggyBank {
    mapping(address => uint256) private balances;
    address public owner;
    IERC20 public token;
    uint256 public goalAmount;
    uint256 public deadline;
    address[] public approvers;
    uint256 public approvalsRequired;
    mapping(address => bool) public approved;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier goalReached() {
        require(token.balanceOf(address(this)) >= goalAmount, "Savings goal not reached");
        require(block.timestamp >= deadline, "Deadline not reached");
        _;
    }

    constructor(
        address _tokenAddress,
        uint256 _goalAmount,
        uint256 _deadline,
        address[] memory _approvers,
        uint256 _approvalsRequired
    ) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        goalAmount = _goalAmount;
        deadline = _deadline;
        approvers = _approvers;
        approvalsRequired = _approvalsRequired;
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Deposit amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        balances[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external goalReached {
        require(_amount <= token.balanceOf(address(this)), "Insufficient contract balance");
        require(token.transfer(msg.sender, _amount), "Token transfer failed");
        emit Withdrawal(owner, _amount);
    }

    function approveEmergencyWithdraw() external {
        require(isApprover(msg.sender), "Not an approver");
        approved[msg.sender] = true;
    }

    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        require(approvalsCount() >= approvalsRequired, "Not enough approvals");
        require(_amount <= token.balanceOf(address(this)), "Insufficient contract balance");
        for (uint256 i = 0; i < approvers.length; i++) {
            approved[approvers[i]] = false;
        }
        require(token.transfer(owner, _amount), "Token transfer failed");
        emit Withdrawal(owner, _amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getTimeUntilDeadline() external view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function isApprover(address _addr) internal view returns (bool) {
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function approvalsCount() internal view returns (uint256 count) {
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approved[approvers[i]]) {
                count++;
            }
        }
    }
}