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
 * @notice Fixes: CEI pattern, balance checks, cooldown, proper events, interface usage, VRF fallback
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
    uint32 private i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    bool private immutable i_nativePayment;
    
    // Game Configuration
    uint256 public constant SPIN_COST = 10 * 10**18; // 10 POTATO
    uint256 public constant MIN_REWARD = 0;
    uint256 public constant MAX_REWARD = 10_000 * 10**18; // 10k POTATO max
    uint256 public constant COOLDOWN_PERIOD = 3 seconds; // Anti-spam
    uint256 public constant VRF_REQUEST_TIMEOUT = 10 minutes; // Fallback timeout
    
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
    
    // State mappings
    mapping(uint256 => GameSession) public gameRequests;
    mapping(address => uint256) public playerSpins;
    mapping(address => uint256) public playerWins;
    mapping(address => uint256) public playerEarnings;
    mapping(address => uint256) public lastSpinTime; // Cooldown tracking
    mapping(uint256 => bool) public refundedRequests; // VRF failure tracking
    
    // Prize Configuration (100 total probability)
    uint8[8] public prizeProbabilities = [25, 21, 20, 15, 10, 5, 3, 1];
    uint256[8] public prizeRewards = [0, 10, 20, 50, 100, 200, 500, 1000]; // Base values without decimals
    
    // Stats
    uint256 public totalSpins;
    uint256 public totalRewardsDistributed;
    uint256 public contractBalance;
    
    // Events
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
        i_callbackGasLimit = callbackGasLimit;
        i_nativePayment = nativePayment;
        
        potatoToken = IPotatoToken(_potatoToken);
        potatoNFT = IPotatoNFT(_potatoNFT);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(PRIZE_MANAGER_ROLE, msg.sender);
    }
    
    /**
     * @dev Request a spin with comprehensive security checks (Checks-Effects-Interactions pattern)
     */
    function spin() external nonReentrant whenNotPaused returns (uint256 requestId) {
        // CHECKS
        require(
            potatoToken.balanceOf(msg.sender) >= SPIN_COST,
            "Insufficient POTATO tokens"
        );
        require(
            block.timestamp >= lastSpinTime[msg.sender] + COOLDOWN_PERIOD,
            "Cooldown period active"
        );
        
        // EFFECTS (update state BEFORE external calls)
        lastSpinTime[msg.sender] = block.timestamp;
        playerSpins[msg.sender]++;
        totalSpins++;
        
        // INTERACTIONS (external calls last)
        // Transfer and burn tokens
        require(
            potatoToken.transferFrom(msg.sender, address(this), SPIN_COST),
            "Token transfer failed"
        );
        potatoToken.burn(SPIN_COST);
        
        // Request randomness from Chainlink VRF v2.5
        requestId = i_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: i_nativePayment})
                )
            })
        );
        
        // Store request details
        gameRequests[requestId] = GameSession({
            player: msg.sender,
            timestamp: block.timestamp,
            fulfilled: false,
            randomWord: 0,
            prize: PrizeType.TRY_AGAIN,
            reward: 0
        });
        
        emit SpinRequested(msg.sender, requestId, block.timestamp);
        return requestId;
    }
    
    /**
     * @dev VRF v2.5 Callback with balance validation and safe transfers
     */
    function fulfillRandomWords(
        uint256 requestId, 
        uint256[] calldata randomWords
    ) 
        internal 
        override 
    {
        GameSession storage session = gameRequests[requestId];
        
        // Validation
        require(!session.fulfilled, "Request already fulfilled");
        require(session.player != address(0), "Invalid session");
        
        // Update state first (CEI pattern)
        session.randomWord = randomWords[0];
        session.fulfilled = true;
        
        // Calculate prize
        PrizeType prize = _determinePrize(randomWords[0]);
        session.prize = prize;
        
        uint256 reward = prizeRewards[uint256(prize)] * 10**18;
        session.reward = reward;
        
        // Award prize with balance check
        if (reward > 0) {
            require(
                potatoToken.balanceOf(address(this)) >= reward,
                "Insufficient contract balance for reward"
            );
            
            playerEarnings[session.player] += reward;
            playerWins[session.player]++;
            totalRewardsDistributed += reward;
            contractBalance -= reward;
            
            require(
                potatoToken.transfer(session.player, reward),
                "Reward transfer failed"
            );
        }
        
        // Award NFT for JACKPOT
        if (prize == PrizeType.JACKPOT) {
            uint256 nftId = potatoNFT.awardJackpot(
                session.player,
                2, // LEGENDARY rarity
                "ipfs://jackpot-metadata"
            );
            emit JackpotWon(session.player, nftId, block.timestamp);
        }
        
        emit SpinResult(session.player, requestId, prize, reward);
    }
    
    /**
     * @dev Determine prize with gas-optimized probability calculation
     */
    function _determinePrize(uint256 randomNumber) private view returns (PrizeType) {
        uint256 result = randomNumber % 100;
        uint256 cumulative = 0;
        
        // Gas optimization: unroll loop for small array
        for (uint8 i = 0; i < 8; i++) {
            cumulative += prizeProbabilities[i];
            if (result < cumulative) {
                return PrizeType(i);
            }
        }
        
        return PrizeType.TRY_AGAIN;
    }
    
    /**
     * @dev Emergency refund for timed-out VRF requests
     */
    function refundTimedOutRequest(uint256 requestId) external nonReentrant {
        GameSession storage session = gameRequests[requestId];
        
        require(session.player == msg.sender, "Not request owner");
        require(!session.fulfilled, "Request already fulfilled");
        require(!refundedRequests[requestId], "Already refunded");
        require(
            block.timestamp >= session.timestamp + VRF_REQUEST_TIMEOUT,
            "Timeout period not reached"
        );
        
        refundedRequests[requestId] = true;
        
        // Refund SPIN_COST
        require(
            potatoToken.balanceOf(address(this)) >= SPIN_COST,
            "Insufficient balance for refund"
        );
        
        require(
            potatoToken.transfer(msg.sender, SPIN_COST),
            "Refund transfer failed"
        );
        
        emit EmergencyRefund(msg.sender, SPIN_COST);
        emit VRFRequestTimedOut(requestId, msg.sender);
    }
    
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
     * @dev Update prize probabilities with validation
     */
    function updatePrizeProbabilities(uint8[8] memory newProbabilities) 
        external 
        onlyRole(PRIZE_MANAGER_ROLE)
    {
        uint256 total = 0;
        for (uint8 i = 0; i < 8; i++) {
            total += newProbabilities[i];
        }
        require(total == 100, "Probabilities must sum to 100");
        
        prizeProbabilities = newProbabilities;
        emit PrizeProbabilitiesUpdated(newProbabilities, msg.sender);
    }
    
    /**
     * @dev Update prize rewards with validation
     */
    function updatePrizeRewards(uint256[8] memory newRewards) 
        external 
        onlyRole(PRIZE_MANAGER_ROLE)
    {
        for (uint8 i = 0; i < 8; i++) {
            require(
                newRewards[i] >= MIN_REWARD && newRewards[i] <= MAX_REWARD,
                "Reward out of valid range"
            );
        }
        
        prizeRewards = newRewards;
        emit PrizeRewardsUpdated(newRewards, msg.sender);
    }
    
    /**
     * @dev Update callback gas limit
     */
    function updateCallbackGasLimit(uint32 newLimit) 
        external 
        onlyRole(OPERATOR_ROLE)
    {
        require(
            newLimit >= MIN_CALLBACK_GAS_LIMIT && newLimit <= MAX_CALLBACK_GAS_LIMIT,
            "Invalid gas limit"
        );
        
        uint32 oldLimit = i_callbackGasLimit;
        i_callbackGasLimit = newLimit;
        emit CallbackGasLimitUpdated(oldLimit, newLimit);
    }
    
    /**
     * @dev Emergency pause
     */
    function pause() external onlyRole(OPERATOR_ROLE) {
        _pause();
    }
    
    /**
     * @dev Unpause
     */
    function unpause() external onlyRole(OPERATOR_ROLE) {
        _unpause();
    }
    
    /**
     * @dev Get game session details
     */
    function getGameSession(uint256 requestId) 
        external 
        view 
        returns (GameSession memory) 
    {
        return gameRequests[requestId];
    }
    
    /**
     * @dev Get player statistics
     */
    function getPlayerStats(address player) 
        external 
        view 
        returns (
            uint256 spins, 
            uint256 wins, 
            uint256 earnings,
            uint256 lastSpin
        ) 
    {
        return (
            playerSpins[player], 
            playerWins[player], 
            playerEarnings[player],
            lastSpinTime[player]
        );
    }
    
    /**
     * @dev Get contract statistics
     */
    function getContractStats() 
        external 
        view 
        returns (
            uint256 _totalSpins,
            uint256 _totalRewards,
            uint256 _contractBalance
        )
    {
        return (totalSpins, totalRewardsDistributed, contractBalance);
    }
}