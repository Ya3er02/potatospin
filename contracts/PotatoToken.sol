// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PotatoToken
 * @dev ERC-20 token for Potato Spin game rewards
 * Enhanced with security validations and event emissions
 */
contract PotatoToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1000000000 * 10**18; // 1 billion tokens
    
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    
    constructor() ERC20("Potato Token", "POTATO") Ownable(msg.sender) {
        // Initial mint: 100 million tokens to contract owner
        _mint(msg.sender, 100000000 * 10**18);
        emit TokensMinted(msg.sender, 100000000 * 10**18);
    }
    
    /**
     * @dev Mint new tokens (only owner can call)
     * @param to Address to receive tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "PotatoToken: Cannot mint to zero address");
        require(amount > 0, "PotatoToken: Amount must be greater than zero");
        require(totalSupply() + amount <= MAX_SUPPLY, "PotatoToken: Exceeds max supply");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Burn tokens from caller's balance
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external {
        require(amount > 0, "PotatoToken: Amount must be greater than zero");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Burn tokens from a specific address (owner only)
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) external onlyOwner {
        require(from != address(0), "PotatoToken: Cannot burn from zero address");
        require(amount > 0, "PotatoToken: Amount must be greater than zero");
        
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }
}
