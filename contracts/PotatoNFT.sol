// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PotatoNFT
 * @dev ERC-721 NFT contract for Potato Spin game jackpot winners
 * Awards legendary potatoes with unique attributes
 */
contract PotatoNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
    
    struct PotatoAttributes {
        Rarity rarity;
        uint256 creationDate;
        uint256 powerLevel;
        string specialAbility;
    }
    
    mapping(uint256 => PotatoAttributes) public potatoTraits;
    
    event JackpotNFTMinted(address indexed winner, uint256 indexed tokenId, Rarity rarity);
    
    constructor(address initialOwner) 
        ERC721("Legendary Potato", "LPOTATO") 
        Ownable(initialOwner) 
    {}
    
    /**
     * @dev Award a jackpot NFT to a winner
     * @param winner Address of the winner
     * @param rarity Rarity tier of the NFT
     * @param tokenURI URI pointing to metadata
     * @return tokenId The ID of the minted NFT
     */
    function awardJackpot(address winner, Rarity rarity, string memory tokenURI) 
        external 
        onlyOwner 
        returns (uint256) 
    {
        require(winner != address(0), "PotatoNFT: Invalid winner address");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        potatoTraits[newTokenId] = PotatoAttributes({
            rarity: rarity,
            creationDate: block.timestamp,
            powerLevel: uint256(rarity) * 250,
            specialAbility: _getAbility(rarity)
        });
        
        _safeMint(winner, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        emit JackpotNFTMinted(winner, newTokenId, rarity);
        return newTokenId;
    }
    
    /**
     * @dev Get special ability based on rarity
     */
    function _getAbility(Rarity rarity) private pure returns (string memory) {
        if (rarity == Rarity.LEGENDARY) return "Double Spin Chance";
        if (rarity == Rarity.EPIC) return "Bonus Multiplier";
        if (rarity == Rarity.RARE) return "Extra Coins";
        return "Lucky Charm";
    }
    
    /**
     * @dev Get potato attributes for a token
     */
    function getPotatoAttributes(uint256 tokenId) 
        external 
        view 
        returns (PotatoAttributes memory) 
    {
        require(_exists(tokenId), "PotatoNFT: Token does not exist");
        return potatoTraits[tokenId];
    }
    
    // Override required functions
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}
