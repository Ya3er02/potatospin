// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./PotatoToken.sol";

/**
 * @title PotatoTasks
 * @dev Task verification and reward distribution system with Merkle proof verification
 */
contract PotatoTasks is Ownable, ReentrancyGuard, Pausable {
    PotatoToken public potatoToken;
    
    // Task types
    enum TaskType { DAILY, SOCIAL, REFERRAL, AD_WATCHED, SPECIAL }
    
    struct Task {
        uint256 taskId;
        string name;
        string description;
        TaskType taskType;
        uint256 reward;
        uint256 cooldown; // in seconds
        bool isActive;
        bytes32 merkleRoot; // for verification
    }
    
    // Storage
    mapping(uint256 => Task) public tasks;
    mapping(address => mapping(uint256 => uint256)) public lastCompletionTime;
    mapping(address => mapping(uint256 => bool)) public hasCompletedTask;
    mapping(uint256 => bool) public blacklistedTasks;
    
    uint256 public taskCounter;
    
    // Events
    event TaskCreated(uint256 indexed taskId, string name, uint256 reward, TaskType taskType);
    event TaskCompleted(address indexed user, uint256 indexed taskId, uint256 reward);
    event TaskUpdated(uint256 indexed taskId, bool isActive);
    event TaskBlacklisted(uint256 indexed taskId, bool status);
    event RewardClaimed(address indexed user, uint256 indexed taskId, uint256 amount);
    
    constructor(address _potatoToken) {
        potatoToken = PotatoToken(_potatoToken);
    }
    
    /**
     * @dev Create a new task (admin only)
     */
    function createTask(
        string memory _name,
        string memory _description,
        TaskType _taskType,
        uint256 _reward,
        uint256 _cooldown,
        bytes32 _merkleRoot
    ) external onlyOwner {
        taskCounter++;
        
        tasks[taskCounter] = Task({
            taskId: taskCounter,
            name: _name,
            description: _description,
            taskType: _taskType,
            reward: _reward,
            cooldown: _cooldown,
            isActive: true,
            merkleRoot: _merkleRoot
        });
        
        emit TaskCreated(taskCounter, _name, _reward, _taskType);
    }
    
    /**
     * @dev Complete a task with Merkle proof verification
     */
    function completeTask(
        uint256 _taskId,
        bytes32[] calldata _merkleProof
    ) external nonReentrant whenNotPaused {
        Task memory task = tasks[_taskId];
        
        require(task.isActive, "Task is not active");
        require(!blacklistedTasks[_taskId], "Task is blacklisted");
        require(
            block.timestamp >= lastCompletionTime[msg.sender][_taskId] + task.cooldown,
            "Task is on cooldown"
        );
        
        // For daily tasks, check if already completed today
        if (task.taskType == TaskType.DAILY) {
            require(
                !hasCompletedTask[msg.sender][_taskId] ||
                block.timestamp >= lastCompletionTime[msg.sender][_taskId] + 24 hours,
                "Daily task already completed"
            );
        }
        
        // Verify Merkle proof if required
        if (task.merkleRoot != bytes32(0)) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _taskId));
            require(
                MerkleProof.verify(_merkleProof, task.merkleRoot, leaf),
                "Invalid Merkle proof"
            );
        }
        
        // Update completion status
        lastCompletionTime[msg.sender][_taskId] = block.timestamp;
        hasCompletedTask[msg.sender][_taskId] = true;
        
        emit TaskCompleted(msg.sender, _taskId, task.reward);
    }
    
    /**
     * @dev Claim reward for completed task
     */
    function claimReward(uint256 _taskId) external nonReentrant whenNotPaused {
        require(hasCompletedTask[msg.sender][_taskId], "Task not completed");
        
        Task memory task = tasks[_taskId];
        
        // Reset completion status after claim
        hasCompletedTask[msg.sender][_taskId] = false;
        
        // Transfer reward
        require(
            potatoToken.transfer(msg.sender, task.reward),
            "Reward transfer failed"
        );
        
        emit RewardClaimed(msg.sender, _taskId, task.reward);
    }
    
    /**
     * @dev Update task status (admin only)
     */
    function updateTaskStatus(uint256 _taskId, bool _isActive) external onlyOwner {
        tasks[_taskId].isActive = _isActive;
        emit TaskUpdated(_taskId, _isActive);
    }
    
    /**
     * @dev Blacklist/unblacklist a task (admin only)
     */
    function setTaskBlacklist(uint256 _taskId, bool _status) external onlyOwner {
        blacklistedTasks[_taskId] = _status;
        emit TaskBlacklisted(_taskId, _status);
    }
    
    /**
     * @dev Update task Merkle root (admin only)
     */
    function updateTaskMerkleRoot(uint256 _taskId, bytes32 _newRoot) external onlyOwner {
        tasks[_taskId].merkleRoot = _newRoot;
    }
    
    /**
     * @dev Get task details
     */
    function getTask(uint256 _taskId) external view returns (Task memory) {
        return tasks[_taskId];
    }
    
    /**
     * @dev Get all tasks (up to 100)
     */
    function getAllTasks() external view returns (Task[] memory) {
        uint256 count = taskCounter > 100 ? 100 : taskCounter;
        Task[] memory allTasks = new Task[](count);
        
        for (uint256 i = 1; i <= count; i++) {
            allTasks[i - 1] = tasks[i];
        }
        
        return allTasks;
    }
    
    /**
     * @dev Check if user can complete task
     */
    function canCompleteTask(address _user, uint256 _taskId) external view returns (bool) {
        Task memory task = tasks[_taskId];
        
        if (!task.isActive || blacklistedTasks[_taskId]) {
            return false;
        }
        
        if (block.timestamp < lastCompletionTime[_user][_taskId] + task.cooldown) {
            return false;
        }
        
        if (task.taskType == TaskType.DAILY) {
            if (hasCompletedTask[_user][_taskId] &&
                block.timestamp < lastCompletionTime[_user][_taskId] + 24 hours) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @dev Get user's task completion status
     */
    function getUserTaskStatus(address _user, uint256 _taskId) 
        external 
        view 
        returns (
            bool completed,
            uint256 lastCompletion,
            uint256 cooldownRemaining
        ) 
    {
        completed = hasCompletedTask[_user][_taskId];
        lastCompletion = lastCompletionTime[_user][_taskId];
        
        Task memory task = tasks[_taskId];
        uint256 nextAvailable = lastCompletion + task.cooldown;
        
        if (block.timestamp >= nextAvailable) {
            cooldownRemaining = 0;
        } else {
            cooldownRemaining = nextAvailable - block.timestamp;
        }
    }
    
    /**
     * @dev Emergency pause (admin only)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause (admin only)
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Withdraw tokens (admin only, emergency)
     */
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        require(
            PotatoToken(_token).transfer(owner(), _amount),
            "Withdrawal failed"
        );
    }
}