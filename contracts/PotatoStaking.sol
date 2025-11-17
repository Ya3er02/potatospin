// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PotatoToken.sol";

/**
 * @title PotatoStaking
 * @dev Staking contract offering 10% APY on POTATO tokens
 */
contract PotatoStaking is ReentrancyGuard, Ownable {
    PotatoToken public immutable stakingToken;
    
    uint256 public constant APY = 10; // 10%
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    
    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
    }
    
    mapping(address => StakeInfo) public stakes;
    uint256 public totalStaked;
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 reward);
    
    constructor(address _stakingToken) Ownable(msg.sender) {
        stakingToken = PotatoToken(_stakingToken);
    }
    
    /**
     * @dev Stake tokens in the contract
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "PotatoStaking: Cannot stake 0");
        
        StakeInfo storage userStake = stakes[msg.sender];
        
        // Claim pending rewards first if user already has a stake
        if (userStake.amount > 0) {
            _claimRewards(msg.sender);
        }
        
        stakingToken.transferFrom(msg.sender, address(this), amount);
        
        userStake.amount += amount;
        userStake.startTime = block.timestamp;
        userStake.lastClaimTime = block.timestamp;
        totalStaked += amount;
        
        emit Staked(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw staked tokens
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "PotatoStaking: Insufficient staked amount");
        require(amount > 0, "PotatoStaking: Cannot withdraw 0");
        
        // Claim pending rewards first
        _claimRewards(msg.sender);
        
        userStake.amount -= amount;
        totalStaked -= amount;
        
        stakingToken.transfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }
    
    /**
     * @dev Claim accumulated rewards
     */
    function claimRewards() external nonReentrant {
        _claimRewards(msg.sender);
    }
    
    /**
     * @dev Internal function to claim rewards
     */
    function _claimRewards(address user) private {
        uint256 reward = calculateRewards(user);
        
        if (reward > 0) {
            stakes[user].lastClaimTime = block.timestamp;
            stakingToken.transfer(user, reward);
            emit RewardsClaimed(user, reward);
        }
    }
    
    /**
     * @dev Calculate pending rewards for a user
     * @param user Address of the user
     * @return reward Amount of pending rewards
     */
    function calculateRewards(address user) public view returns (uint256) {
        StakeInfo memory userStake = stakes[user];
        
        if (userStake.amount == 0) return 0;
        
        uint256 stakingDuration = block.timestamp - userStake.lastClaimTime;
        uint256 reward = (userStake.amount * APY * stakingDuration) / (100 * SECONDS_PER_YEAR);
        
        return reward;
    }
    
    /**
     * @dev Get stake information for a user
     * @param user Address of the user
     * @return Stake information struct
     */
    function getStakeInfo(address user) external view returns (StakeInfo memory) {
        return stakes[user];
    }
    
    /**
     * @dev Get total rewards earned by a user
     * @param user Address of the user
     * @return Total rewards (pending + historical)
     */
    function getTotalRewards(address user) external view returns (uint256) {
        StakeInfo memory userStake = stakes[user];
        
        if (userStake.amount == 0) return 0;
        
        uint256 totalTime = block.timestamp - userStake.startTime;
        uint256 totalRewards = (userStake.amount * APY * totalTime) / (100 * SECONDS_PER_YEAR);
        
        return totalRewards;
    }
}
