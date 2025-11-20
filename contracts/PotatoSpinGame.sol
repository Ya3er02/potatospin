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
    // ...rest above here unchanged

    event TokensWithdrawn(address indexed recipient, uint256 amount);
    event TokensDeposited(address indexed depositor, uint256 amount); // <-- Added event

    // ...rest unchanged, events are now adjacent

    // ...rest unchanged...
}
