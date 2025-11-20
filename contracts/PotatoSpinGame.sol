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
    // ... snip (rest unchanged) ...

    event TokensWithdrawn(address indexed recipient, uint256 amount); // Ensure event present

    // ... withdrawal function
    /**
     * @dev Admin-only withdrawal from the reward pool
     */
    function adminWithdrawTokens(uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {
        require(amount > 0, "Withdraw amount must be > 0");
        require(potatoToken.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(contractBalance >= amount, "Reward pool insufficient");
        contractBalance -= amount;
        require(potatoToken.transfer(msg.sender, amount), "Token withdrawal failed");
        emit TokensWithdrawn(msg.sender, amount);
    }

    // ... rest of contract unchanged ...
}
