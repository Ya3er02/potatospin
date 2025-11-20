// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPotatoNFT
 * @dev Interface for PotatoNFT contract
 */
interface IPotatoNFT {
    function awardJackpot(
        address player,
        uint256 rarity,
        string memory metadataUri
    ) external returns (uint256);
    
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external;
}