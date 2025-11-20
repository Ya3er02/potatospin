// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title PotatoToken
 * @dev Enhanced ERC-20 token with multi-role access control and emergency pause
 * @notice Fixes: Added Pausable, AccessControl, proper burn permissions, comprehensive events
 */
contract PotatoToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ReentrancyGuard {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18; // 100 million tokens
    
    // Events
    event TokensMinted(address indexed to, uint256 amount, address indexed minter);
    event TokensBurned(address indexed from, uint256 amount, address indexed burner);
    event EmergencyPaused(address indexed pauser);
    event EmergencyUnpaused(address indexed pauser);
    
    constructor() ERC20("Potato Token", "POTATO") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, INITIAL_SUPPLY);
        emit TokensMinted(msg.sender, INITIAL_SUPPLY, msg.sender);
    }
    
    /**
     * @dev Burn tokens from a specific address. Only accounts with BURNER_ROLE can call this function.
     *      Burns tokens from `from` up to the caller's allowance, as defined in the ERC20Allowance standard.
     *      Respects standard allowance mechanics (spender must have prior approval by `from`).
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) public override onlyRole(BURNER_ROLE) nonReentrant whenNotPaused {
        require(from != address(0), "PotatoToken: Cannot burn from zero address");
        require(amount > 0, "PotatoToken: Amount must be greater than zero");
        super.burnFrom(from, amount);
        emit TokensBurned(from, amount, msg.sender);
    }
    // ... rest of contract unchanged ...
}