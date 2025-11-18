// src/lib/contracts.ts

const ETHEREUM_ADDRESS_REGEX = /^0x[a-fA-F0-9]{40}$/

function validateAddress(envKey: string, input: string | undefined): string {
  if (!input) {
    throw new Error(`Missing required environment variable: ${envKey}`)
  }
  if (!ETHEREUM_ADDRESS_REGEX.test(input)) {
    throw new Error(`Invalid Ethereum address in ${envKey}: ${input}`)
  }
  return input
}

function validateChainId(envKey: string, input: string | undefined): number {
  const DEFAULT_CHAIN_ID = 84532
  if (!input) return DEFAULT_CHAIN_ID
  const trimmed = input.trim()
  const parsed = parseInt(trimmed, 10)
  if (!Number.isFinite(parsed) || !Number.isInteger(parsed) || parsed < 1) {
    throw new Error(`Invalid chainId in ${envKey}: ${input}`)
  }
  return parsed
}

export const CONTRACTS = {
  POTATO_TOKEN: validateAddress('NEXT_PUBLIC_POTATO_TOKEN_ADDRESS', process.env.NEXT_PUBLIC_POTATO_TOKEN_ADDRESS),
  GAME_CONTRACT: validateAddress('NEXT_PUBLIC_GAME_CONTRACT_ADDRESS', process.env.NEXT_PUBLIC_GAME_CONTRACT_ADDRESS),
  NFT_CONTRACT: validateAddress('NEXT_PUBLIC_NFT_CONTRACT_ADDRESS', process.env.NEXT_PUBLIC_NFT_CONTRACT_ADDRESS),
  TASKS_CONTRACT: validateAddress('NEXT_PUBLIC_TASKS_CONTRACT_ADDRESS', process.env.NEXT_PUBLIC_TASKS_CONTRACT_ADDRESS),
  REFERRAL_CONTRACT: validateAddress('NEXT_PUBLIC_REFERRAL_CONTRACT_ADDRESS', process.env.NEXT_PUBLIC_REFERRAL_CONTRACT_ADDRESS),
}

const SAFE_CHAIN_ID = validateChainId('NEXT_PUBLIC_CHAIN_ID', process.env.NEXT_PUBLIC_CHAIN_ID)

export const CHAIN_CONFIG = {
  chainId: SAFE_CHAIN_ID,
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
