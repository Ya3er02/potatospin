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

/**
 * @title PotatoSpinGame
 * @dev Enhanced game contract with comprehensive security measures
 */
contract PotatoSpinGame is VRFConsumerBaseV2Plus, AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant PRIZE_MANAGER_ROLE = keccak256("PRIZE_MANAGER_ROLE");
    
    IVRFCoordinatorV2Plus private immutable i_vrfCoordinator;
    
    // VRF v2.5 Configuration
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId;
    uint32 private constant MIN_CALLBACK_GAS_LIMIT = 100_000;
    uint32 private constant MAX_CALLBACK_GAS_LIMIT = 2_500_000;
    uint32 private s_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    bool private immutable i_nativePayment;
    
    // Game Configuration
    uint256 public constant SPIN_COST = 10 * 10**18;
    uint256 public constant MIN_REWARD = 0;
    uint256 public constant MAX_REWARD = 10_000 * 10**18; 
    uint256 public constant COOLDOWN_PERIOD = 3 seconds;
    uint256 public constant VRF_REQUEST_TIMEOUT = 10 minutes;
    
    IPotatoToken public potatoToken;
    IPotatoNFT public potatoNFT;
    
    enum PrizeType { TRY_AGAIN, CANDY, BALLOON, GIFT, STAR, LUCKY, DIAMOND, JACKPOT }
    
    struct GameSession {
        address player;
        uint256 timestamp;
        bool fulfilled;
        uint256 randomWord;
        PrizeType prize;
        uint256 reward;
    }
    
    mapping(uint256 => GameSession) public gameRequests;
    mapping(address => uint256) public playerSpins;
    mapping(address => uint256) public playerWins;
    mapping(address => uint256) public playerEarnings;
    mapping(address => uint256) public lastSpinTime;
    mapping(uint256 => bool) public refundedRequests;
    
    uint8[8] public prizeProbabilities = [25, 21, 20, 15, 10, 5, 3, 1];
    uint256[8] public prizeRewards = [0, 10, 20, 50, 100, 200, 500, 1000];
    
    uint256 public totalSpins;
    uint256 public totalRewardsDistributed;
    uint256 public contractBalance;
    
    event SpinRequested(address indexed player, uint256 indexed requestId, uint256 timestamp);
    event SpinResult(address indexed player, uint256 indexed requestId, PrizeType prize, uint256 reward);
    event JackpotWon(address indexed player, uint256 nftTokenId, uint256 timestamp);
    event PrizeProbabilitiesUpdated(uint8[8] newProbabilities, address indexed updater);
    event PrizeRewardsUpdated(uint256[8] newRewards, address indexed updater);
    event CallbackGasLimitUpdated(uint32 oldLimit, uint32 newLimit);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensWithdrawn(address indexed recipient, uint256 amount);
    event VRFRequestTimedOut(uint256 indexed requestId, address indexed player);
    event EmergencyRefund(address indexed player, uint256 amount);
    
    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        bool nativePayment,
        address _potatoToken,
        address _potatoNFT
    )
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        require(vrfCoordinator != address(0), "Invalid VRF coordinator");
        require(_potatoToken != address(0), "Invalid token address");
        require(_potatoNFT != address(0), "Invalid NFT address");
        require(
            callbackGasLimit >= MIN_CALLBACK_GAS_LIMIT && callbackGasLimit <= MAX_CALLBACK_GAS_LIMIT,
            "Invalid callback gas limit"
        );
        i_vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        s_callbackGasLimit = callbackGasLimit;
        i_nativePayment = nativePayment;
        potatoToken = IPotatoToken(_potatoToken);
        potatoNFT = IPotatoNFT(_potatoNFT);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(PRIZE_MANAGER_ROLE, msg.sender);

        // contractBalance sync with actual token balance if pre-funded
        contractBalance = potatoToken.balanceOf(address(this));
    }

    // ...rest of contract unchanged (functionality remains as before)...
