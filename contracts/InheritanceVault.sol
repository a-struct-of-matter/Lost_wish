// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InheritanceVault
 * @dev A "dead-man switch" inheritance contract.
 * The owner deposits ETH and must periodically call keepAlive().
 * If they don't, the nominee can claim the funds after a timeout.
 * Additionally, the owner can trigger an immediate transfer
 * to the nominee using a kill switch.
 */
contract InheritanceVault {
    address public owner;
    address public nominee;

    uint256 public heartbeatInterval; // in seconds
    uint256 public lastCheckIn;       // timestamp of last keepAlive

    bool public claimed;              // to prevent double-claim

    event Deposited(address indexed from, uint256 amount);
    event KeepAlive(address indexed owner, uint256 timestamp);
    event OwnerWithdraw(address indexed owner, uint256 amount);
    event Claimed(address indexed nominee, uint256 amount);
    event EmergencyTransfer(address indexed owner, address indexed nominee, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyNominee() {
        require(msg.sender == nominee, "Not nominee");
        _;
    }

    constructor(address _nominee, uint256 _heartbeatInterval) payable {
        require(_nominee != address(0), "Invalid nominee");
        require(_heartbeatInterval > 0, "Interval must be > 0");

        owner = msg.sender;
        nominee = _nominee;
        heartbeatInterval = _heartbeatInterval;
        lastCheckIn = block.timestamp;
    }

    // Allow owner to deposit more ETH
    function deposit() external payable onlyOwner {
        require(msg.value > 0, "No ETH sent");
        emit Deposited(msg.sender, msg.value);
    }

    // Called by owner to prove they're still active
    function keepAlive() external onlyOwner {
        lastCheckIn = block.timestamp;
        emit KeepAlive(msg.sender, block.timestamp);
    }

    // Owner can withdraw while considered "alive"
    function ownerWithdraw(uint256 amount) external onlyOwner {
        require(!claimed, "Already claimed");
        require(isOwnerActive(), "Owner considered inactive");
        require(address(this).balance >= amount, "Insufficient balance");

        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "Transfer failed");

        emit OwnerWithdraw(owner, amount);
    }

    // Nominee can claim after timeout
    function claim() external onlyNominee {
        require(!claimed, "Already claimed");
        require(!isOwnerActive(), "Owner still active");

        uint256 bal = address(this).balance;
        require(bal > 0, "No funds to claim");

        claimed = true;

        (bool ok, ) = payable(nominee).call{value: bal}("");
        require(ok, "Transfer failed");

        emit Claimed(nominee, bal);
    }

    // Kill switch: owner willingly transfers everything to nominee immediately
    function emergencyTransferToNominee() external onlyOwner {
        require(!claimed, "Already claimed");
        uint256 bal = address(this).balance;
        require(bal > 0, "No funds to transfer");

        claimed = true;

        (bool ok, ) = payable(nominee).call{value: bal}("");
        require(ok, "Transfer failed");

        emit EmergencyTransfer(owner, nominee, bal);
    }

    // View function: is owner still within heartbeat interval?
    function isOwnerActive() public view returns (bool) {
        return block.timestamp <= lastCheckIn + heartbeatInterval;
    }

    // Helper: get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
