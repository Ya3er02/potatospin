export const CONTRACTS = {
  POTATO_TOKEN: process.env.NEXT_PUBLIC_POTATO_TOKEN_ADDRESS as `0x${string}`,
  GAME_CONTRACT: process.env.NEXT_PUBLIC_GAME_CONTRACT_ADDRESS as `0x${string}`,
  NFT_CONTRACT: process.env.NEXT_PUBLIC_NFT_CONTRACT_ADDRESS as `0x${string}`,
  TASKS_CONTRACT: process.env.NEXT_PUBLIC_TASKS_CONTRACT_ADDRESS as `0x${string}`,
  REFERRAL_CONTRACT: process.env.NEXT_PUBLIC_REFERRAL_CONTRACT_ADDRESS as `0x${string}`,
}

export const CHAIN_CONFIG = {
  chainId: parseInt(process.env.NEXT_PUBLIC_CHAIN_ID || '84532'),
  rpcUrl: process.env.NEXT_PUBLIC_RPC_URL || 'https://sepolia.base.org',
  explorerUrl: process.env.NEXT_PUBLIC_EXPLORER_URL || 'https://sepolia.basescan.org',
}

// ABI excerpts - full ABIs should be imported from compiled contracts
export const POTATO_TOKEN_ABI = [
  'function balanceOf(address owner) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  'function approve(address spender, uint256 amount) returns (bool)',
] as const

export const GAME_CONTRACT_ABI = [
  'function spin(uint8 spinCount) payable',
  'function getUserEnergy(address user) view returns (uint256)',
  'function getUserLevel(address user) view returns (uint256)',
  'function claimRewards() returns (uint256)',
  'event SpinCompleted(address indexed user, uint256 result, uint256 reward)',
] as const