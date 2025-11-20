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
    // ... snip ...
    // function refundTimedOutRequest (updated per user request)
    function refundTimedOutRequest(uint256 requestId) external nonReentrant {
        GameSession storage session = gameRequests[requestId];
        require(session.player == msg.sender, "Not request owner");
        require(!session.fulfilled, "Request already fulfilled");
        require(!refundedRequests[requestId], "Already refunded");
        require(block.timestamp >= session.timestamp + VRF_REQUEST_TIMEOUT, "Timeout period not reached");
        // Refunds come from the contract reward pool and reduce contractBalance accordingly
        require(contractBalance >= SPIN_COST, "reward pool insufficient for refund");
        contractBalance -= SPIN_COST;
        refundedRequests[requestId] = true;
        require(potatoToken.balanceOf(address(this)) >= SPIN_COST, "Insufficient balance for refund");
        require(potatoToken.transfer(msg.sender, SPIN_COST), "Refund transfer failed");
        emit EmergencyRefund(msg.sender, SPIN_COST);
        emit VRFRequestTimedOut(requestId, msg.sender);
    }
    // ... rest of contract unchanged ...
}
