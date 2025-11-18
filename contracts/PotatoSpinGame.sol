// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PotatoToken.sol";
import "./PotatoNFT.sol";

/**
 * @title PotatoSpinGame
 * @dev Main game contract with Chainlink VRF v2.5 for verifiable randomness
 */
contract PotatoSpinGame is VRFConsumerBaseV2Plus, Ownable, ReentrancyGuard {
    IVRFCoordinatorV2Plus private immutable i_vrfCoordinator;
    
    // VRF v2.5 Configuration (uint256 subscriptionId)
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId; // Changed from uint64 to uint256
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    bool private immutable i_nativePayment; // VRF v2.5: support native token payment
    
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
        uint256 subscriptionId, // Changed from uint64 to uint256
        uint32 callbackGasLimit,
        bool nativePayment, // VRF v2.5: native payment flag
        address _potatoToken,
        address _potatoNFT
    ) 
        VRFConsumerBaseV2Plus(vrfCoordinator) 
        Ownable(msg.sender)
    {
        i_vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_nativePayment = nativePayment;
        
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
        
        // Request randomness from Chainlink VRF v2.5
        // VRF v2.5 uses VRFV2PlusClient.RandomWordsRequest with extraArgs
        requestId = i_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // VRF v2.5: extraArgs for native payment configuration
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: i_nativePayment})
                )
            })
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
     * @dev VRF v2.5 Callback to fulfill randomness
     * @notice Changed to calldata for gas optimization in v2.5
     */
    function fulfillRandomWords(
        uint256 requestId, 
        uint256[] calldata randomWords // Changed from memory to calldata
    ) 
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
