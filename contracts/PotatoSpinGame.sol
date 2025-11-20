// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IPotatoToken.sol";
import "./interfaces/IPotatoNFT.sol";

contract PotatoSpinGame is VRFConsumerBaseV2Plus, AccessControl, ReentrancyGuard, Pausable {
    // ... snip earlier ...
    event TokensWithdrawn(address indexed recipient, uint256 amount); // Ensure declared

    /**
     * @dev Deposit tokens to contract for rewards pool
     */
    function depositRewards(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(
            potatoToken.transferFrom(msg.sender, address(this), amount),
            "Deposit transfer failed"
        );
        contractBalance += amount;
        emit TokensDeposited(msg.sender, amount);
    }

    /**
     * @dev Admin-only withdrawal from the reward pool (matching deposit logic)
     */
    function withdrawRewards(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(amount > 0, "Withdraw amount must be > 0");
        require(contractBalance >= amount, "Insufficient reward pool");
        require(potatoToken.balanceOf(address(this)) >= amount, "Insufficient token balance");
        contractBalance -= amount;
        require(potatoToken.transfer(msg.sender, amount), "Token withdrawal failed");
        emit TokensWithdrawn(msg.sender, amount);
    }
    // ... rest of contract unchanged ...
}
