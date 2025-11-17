// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PotatoToken.sol";
import "./PotatoNFT.sol";

/**
 * @title PotatoSpinGame
 * @dev Main game contract with Chainlink VRF for verifiable randomness
 */
contract PotatoSpinGame is VRFConsumerBaseV2, Ownable, ReentrancyGuard {
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    
    // VRF Configuration
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    
    // Game Configuration
    uint256 public constant SPIN_COST = 10 * 10**18; // 10 POTATO
    
    PotatoToken public potatoToken;
    PotatoNFT public potatoNFT;
    
    enum PrizeType { TRY_AGAIN, CANDY, BALLOON, GIFT, STAR, LUCKY, DIAMOND, JACKPOT }
    
    struct GameSession {
        address player;
        uint256 requestId;
        bool fulfilled;
        uint256 randomWord;
        PrizeType prize;
    }
    
    mapping(uint256 => GameSession) public gameRequests;
    mapping(address => uint256) public playerSpins;
    mapping(address => uint256) public playerWins;
    mapping(address => uint256) public playerEarnings;
    
    // Prize Probabilities (total = 100)
    uint8[8] public prizeProbabilities = [25, 21, 20, 15, 10, 5, 3, 1];
    uint256[8] public prizeRewards = [0, 10, 20, 50, 100, 200, 500, 1000];
    
    event SpinRequested(address indexed player, uint256 requestId);
    event SpinResult(address indexed player, PrizeType prize, uint256 reward);
    event JackpotWon(address indexed player, uint256 nftTokenId);
    
    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        address _potatoToken,
        address _potatoNFT
    ) 
        VRFConsumerBaseV2(vrfCoordinator) 
        Ownable(msg.sender)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        
        potatoToken = PotatoToken(_potatoToken);
        potatoNFT = PotatoNFT(_potatoNFT);
    }
    
    /**
     * @dev Request a spin (requires SPIN_COST tokens)
     */
    function spin() external nonReentrant returns (uint256 requestId) {
        require(
            potatoToken.balanceOf(msg.sender) >= SPIN_COST,
            "PotatoSpinGame: Insufficient POTATO tokens"
        );
        
        // Burn spin cost
        potatoToken.transferFrom(msg.sender, address(this), SPIN_COST);
        potatoToken.burn(SPIN_COST);
        
        // Request randomness from Chainlink VRF
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        
        gameRequests[requestId] = GameSession({
            player: msg.sender,
            requestId: requestId,
            fulfilled: false,
            randomWord: 0,
            prize: PrizeType.TRY_AGAIN
        });
        
        playerSpins[msg.sender]++;
        
        emit SpinRequested(msg.sender, requestId);
        return requestId;
    }
    
    /**
     * @dev VRF Callback to fulfill randomness
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) 
        internal 
        override 
    {
        GameSession storage session = gameRequests[requestId];
        require(!session.fulfilled, "PotatoSpinGame: Request already fulfilled");
        require(session.player != address(0), "PotatoSpinGame: Invalid session");
        
        session.randomWord = randomWords[0];
        session.fulfilled = true;
        
        // Calculate prize based on probability
        PrizeType prize = _determinePrize(randomWords[0]);
        session.prize = prize;
        
        uint256 reward = prizeRewards[uint256(prize)] * 10**18;
        
        // Award prize
        if (reward > 0) {
            potatoToken.transfer(session.player, reward);
            playerEarnings[session.player] += reward;
            playerWins[session.player]++;
        }
        
        // Award NFT for JACKPOT
        if (prize == PrizeType.JACKPOT) {
            uint256 nftId = potatoNFT.awardJackpot(
                session.player,
                PotatoNFT.Rarity.LEGENDARY,
                "ipfs://jackpot-metadata"
            );
            emit JackpotWon(session.player, nftId);
        }
        
        emit SpinResult(session.player, prize, reward);
    }
    
    /**
     * @dev Determine prize from random number
     */
    function _determinePrize(uint256 randomNumber) private view returns (PrizeType) {
        uint256 result = randomNumber % 100;
        uint256 cumulative = 0;
        
        for (uint8 i = 0; i < prizeProbabilities.length; i++) {
            cumulative += prizeProbabilities[i];
            if (result < cumulative) {
                return PrizeType(i);
            }
        }
        
        return PrizeType.TRY_AGAIN;
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
        returns (uint256 spins, uint256 wins, uint256 earnings) 
    {
        return (playerSpins[player], playerWins[player], playerEarnings[player]);
    }
    
    /**
     * @dev Update prize probabilities (owner only)
     */
    function updatePrizeProbabilities(uint8[8] memory newProbabilities) 
        external 
        onlyOwner 
    {
        uint256 total = 0;
        for (uint8 i = 0; i < newProbabilities.length; i++) {
            total += newProbabilities[i];
        }
        require(total == 100, "PotatoSpinGame: Probabilities must sum to 100");
        prizeProbabilities = newProbabilities;
    }
    
    /**
     * @dev Update prize rewards (owner only)
     */
    function updatePrizeRewards(uint256[8] memory newRewards) 
        external 
        onlyOwner 
    {
        prizeRewards = newRewards;
    }
}
