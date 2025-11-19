// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./PotatoToken.sol";

/**
 * @title PotatoReferral
 * @dev Multi-tier referral system with unique code generation
 */
contract PotatoReferral is Ownable, ReentrancyGuard, Pausable {
    PotatoToken public potatoToken;
    
    // Referral configuration
    uint256 public constant LEVEL1_REWARD_PERCENT = 10; // 10%
    uint256 public constant LEVEL2_REWARD_PERCENT = 5;  // 5%
    uint256 public constant MAX_REFERRAL_DEPTH = 2;
    
    // Structs
    struct ReferralStats {
        uint256 totalReferrals;
        uint256 totalEarnings;
        uint256 level1Count;
        uint256 level2Count;
        bool isRegistered;
    }
    
    // Storage
    mapping(address => bytes6) public userReferralCode;
    mapping(bytes6 => address) public codeToUser;
    mapping(address => address) public referrer; // user => their referrer
    mapping(address => ReferralStats) public stats;
    mapping(address => address[]) public referrals; // user => list of referrals
    
    uint256 public totalReferrals;
    uint256 public totalRewardsDistributed;
    
    // Events
    event ReferralCodeGenerated(address indexed user, bytes6 code);
    event UserRegistered(address indexed user, address indexed referrer, bytes6 code);
    event ReferralRewardDistributed(address indexed referrer, address indexed referee, uint256 amount, uint256 level);
    event ReferralStatsUpdated(address indexed user, uint256 totalReferrals, uint256 totalEarnings);
    
    constructor(address _potatoToken) {
        potatoToken = PotatoToken(_potatoToken);
    }
    
    /**
     * @dev Generate unique referral code for user
     */
    function generateReferralCode() external returns (bytes6) {
        require(userReferralCode[msg.sender] == bytes6(0), "Code already exists");
        
        bytes6 code = _generateUniqueCode(msg.sender);
        
        userReferralCode[msg.sender] = code;
        codeToUser[code] = msg.sender;
        stats[msg.sender].isRegistered = true;
        
        emit ReferralCodeGenerated(msg.sender, code);
        
        return code;
    }
    
    /**
     * @dev Register with a referral code
     */
    function registerWithReferral(bytes6 _referralCode) external {
        require(referrer[msg.sender] == address(0), "Already registered");
        require(codeToUser[_referralCode] != address(0), "Invalid referral code");
        require(codeToUser[_referralCode] != msg.sender, "Cannot refer yourself");
        
        address referrerAddress = codeToUser[_referralCode];
        
        // Set referrer
        referrer[msg.sender] = referrerAddress;
        
        // Update stats
        stats[referrerAddress].totalReferrals++;
        stats[referrerAddress].level1Count++;
        referrals[referrerAddress].push(msg.sender);
        
        // Check for level 2 referrer
        address level2Referrer = referrer[referrerAddress];
        if (level2Referrer != address(0)) {
            stats[level2Referrer].level2Count++;
        }
        
        totalReferrals++;
        
        // Generate code for new user
        if (userReferralCode[msg.sender] == bytes6(0)) {
            bytes6 newCode = _generateUniqueCode(msg.sender);
            userReferralCode[msg.sender] = newCode;
            codeToUser[newCode] = msg.sender;
        }
        
        stats[msg.sender].isRegistered = true;
        
        emit UserRegistered(msg.sender, referrerAddress, _referralCode);
    }
    
    /**
     * @dev Distribute referral rewards (called by game contract)
     */
    function distributeReferralRewards(address _user, uint256 _amount) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        require(_amount > 0, "Amount must be positive");
        
        address level1Referrer = referrer[_user];
        
        // Level 1 reward
        if (level1Referrer != address(0)) {
            uint256 level1Reward = (_amount * LEVEL1_REWARD_PERCENT) / 100;
            
            stats[level1Referrer].totalEarnings += level1Reward;
            totalRewardsDistributed += level1Reward;
            
            require(
                potatoToken.transfer(level1Referrer, level1Reward),
                "Level 1 reward transfer failed"
            );
            
            emit ReferralRewardDistributed(level1Referrer, _user, level1Reward, 1);
            emit ReferralStatsUpdated(
                level1Referrer,
                stats[level1Referrer].totalReferrals,
                stats[level1Referrer].totalEarnings
            );
            
            // Level 2 reward
            address level2Referrer = referrer[level1Referrer];
            if (level2Referrer != address(0)) {
                uint256 level2Reward = (_amount * LEVEL2_REWARD_PERCENT) / 100;
                
                stats[level2Referrer].totalEarnings += level2Reward;
                totalRewardsDistributed += level2Reward;
                
                require(
                    potatoToken.transfer(level2Referrer, level2Reward),
                    "Level 2 reward transfer failed"
                );
                
                emit ReferralRewardDistributed(level2Referrer, _user, level2Reward, 2);
                emit ReferralStatsUpdated(
                    level2Referrer,
                    stats[level2Referrer].totalReferrals,
                    stats[level2Referrer].totalEarnings
                );
            }
        }
    }
    
    /**
     * @dev Generate unique code based on address and timestamp
     */
    function _generateUniqueCode(address _user) private view returns (bytes6) {
        bytes32 hash = keccak256(abi.encodePacked(_user, block.timestamp, totalReferrals));
        return bytes6(hash);
    }
    
    /**
     * @dev Get referral stats for user
     */
    function getReferralStats(address _user) 
        external 
        view 
        returns (
            uint256 totalRefs,
            uint256 totalEarn,
            uint256 level1,
            uint256 level2,
            bool registered
        ) 
    {
        ReferralStats memory userStats = stats[_user];
        return (
            userStats.totalReferrals,
            userStats.totalEarnings,
            userStats.level1Count,
            userStats.level2Count,
            userStats.isRegistered
        );
    }
    
    /**
     * @dev Get list of direct referrals
     */
    function getDirectReferrals(address _user) external view returns (address[] memory) {
        return referrals[_user];
    }
    
    /**
     * @dev Get referral chain (up to max depth)
     */
    function getReferralChain(address _user) 
        external 
        view 
        returns (address[] memory chain) 
    {
        chain = new address[](MAX_REFERRAL_DEPTH);
        address current = _user;
        
        for (uint256 i = 0; i < MAX_REFERRAL_DEPTH; i++) {
            address ref = referrer[current];
            if (ref == address(0)) break;
            chain[i] = ref;
            current = ref;
        }
        
        return chain;
    }
    
    /**
     * @dev Check if user has referral code
     */
    function hasReferralCode(address _user) external view returns (bool) {
        return userReferralCode[_user] != bytes6(0);
    }
    
    /**
     * @dev Get user by referral code
     */
    function getUserByCode(bytes6 _code) external view returns (address) {
        return codeToUser[_code];
    }
    
    /**
     * @dev Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Emergency withdraw
     */
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        require(
            potatoToken.transfer(owner(), _amount),
            "Withdrawal failed"
        );
    }
}