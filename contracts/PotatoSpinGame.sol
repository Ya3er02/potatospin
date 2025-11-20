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
    uint256 public constant SPIN_COST = 10 * 10**18;
    uint256 public constant MIN_REWARD = 0;
    uint256 public constant MAX_REWARD = 10_000 * 10**18; // 10k POTATO in wei
    uint256 public constant MIN_REWARD_BASE = 0;
    uint256 public constant MAX_REWARD_BASE = 10_000;     // 10k POTATO base units
    // ... rest unchanged ...

    function updatePrizeRewards(uint256[8] memory newRewards) 
        external 
        onlyRole(PRIZE_MANAGER_ROLE)
    {
        for (uint8 i = 0; i < 8; i++) {
            require(
                newRewards[i] >= MIN_REWARD_BASE && newRewards[i] <= MAX_REWARD_BASE,
                "Reward must be 0 to 10,000 base units"
            );
        }
        prizeRewards = newRewards;
        emit PrizeRewardsUpdated(newRewards, msg.sender);
    }
    // ... rest of contract unchanged ...
}
