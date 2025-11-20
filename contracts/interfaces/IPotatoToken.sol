// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IPotatoToken
 * @dev Interface for PotatoToken contract
 * @notice Enables contract swapping and reduces tight coupling
 */
interface IPotatoToken is IERC20 {
    function burn(uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
    function mint(address to, uint256 amount) external;
    function pause() external;
    function unpause() external;
}