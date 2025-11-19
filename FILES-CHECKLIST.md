# PotatoSpin Files Creation Checklist

This document provides a file-by-file checklist with source references from the attached implementation guide files.

## Smart Contracts (Reference: IMPLEMENTATION-GUIDE.md)

### To Create:
- [ ] `contracts/PotatoTasks.sol` - Task verification with Merkle proofs
- [ ] `contracts/PotatoReferral.sol` - Multi-level referral system

### To Update:
- [ ] `contracts/PotatoSpinGame.sol` - Add task & referral integration
  - Add: `IPotatoTasks public tasksContract;`
  - Add: `IPotatoReferral public referralContract;`
  - In `spin()` function: Call `tasksContract.completeTask()`
  - In `distributeWinnings()`: Call `referralContract.distributeReferralRewards()`

## Configuration Files (Reference: hardhat-config.md)

### To Update:
- [ ] `hardhat.config.js`
  - Solidity version: 0.8.20
  - Add networks: baseSepolia, base, localhost
  - Add etherscan configuration
  - Add gas reporter setup

- [ ] `.env.example`
  - PRIVATEKEY
  - BASESEPOLIARPCURL
  - BASERPCURL
  - BASESCANAPIKEY
  - CHAINLINKVRFCOORDINATOR: 0x2D159aE3BFF84D20a3dC6277126F570224fA9623
  - CHAINLINKVRFKEYHASH: 0x7bb3c0c5e2f0e21dc24bc2d0e34fa31f8e77f7bbcf5c4bc8e8d7fc3b3c09d0f3
  - CHAINLINKVRFSUBSCRIPTIONID
  - CHAINLINKVRFCALLBACKGASLIMIT: 500000
  - CHAINLINKVRFREQUESTCONFIRMATIONS: 3
  - NEXTPUBLICWALLETCONNECTPROJECTID
  - All contract addresses

- [ ] `package.json`
  - Add scripts: compile, test, testgas, coverage, deploy*
  - Add dependencies:
    - nomicfoundationhardhat-toolbox
    - nomiclabshardhat-etherscan
    - hardhat-gas-reporter
    - solidity-coverage
    - openzeppelincontracts
    - chainlinkcontracts
    - dotenv
    - wagmi, viem, tanstackreact-query
    - rainbow-merainbowkit
    - farcasterframe-sdk
    - zustand
    - framer-motion

## Frontend Infrastructure (Reference: wagmi-contracts-config.md)

### To Create in `src/lib/`:
- [ ] `wagmi.ts`
  - Import: wagmi, wagmi/chains, rainbow-merainbowkit
  - Chains: base, baseSepolia
  - Connectors: injected, walletConnect, coinbaseWallet
  - Config: createConfig with transports

- [ ] `contracts.ts`
  - Export: CONTRACTS object with addresses
  - Export: ABIS object with contract ABIs
  - Export: VRF_CONFIG with coordinator details
  - Export: GAME_CONFIG with game constants
  - Export: Helper functions (formatTokenAmount, parseTokenAmount)
  - Export: Individual contract configurations
  - Export: EVENT_SIGNATURES for event filtering

### To Create in `src/components/`:
- [ ] `Providers.tsx`
  - WagmiProvider with config
  - QueryClientProvider
  - RainbowKitProvider with theme & settings

- [ ] `GameDashboard.tsx`
  - Import useGameState, useChainlinkVRF hooks
  - Display: energy, balance, pet level
  - ConnectButton from rainbow-merainbowkit
  - Spin button with energy cost
  - Show game stats

### App Layout (Reference: wagmi-contracts-config.md)
- [ ] `src/app/layout.tsx`
  - Import Providers component
  - Add metadata (title, description, icons)
  - Wrap children with Providers
  - Add Farcaster script tag

- [ ] `src/app/page.tsx`
  - Import GameDashboard
  - Render main game component

## Custom Hooks (Reference: custom-hooks.md)

### To Create in `src/hooks/`:
- [ ] `useGameState.ts`
  - Zustand store for: energy, balance, petLevel, petXP
  - Read contract functions for player data
  - Watch contract events
  - Return store state + refetch functions

- [ ] `useChainlinkVRF.ts`
  - useWriteContract for spin request
  - useWatchContractEvent for fulfillment
  - Track requestId, randomResult, isRequesting, isFulfilled
  - requestRandomness function
  - resetState function

- [ ] `useFarcasterContext.ts`
  - Load Farcaster SDK context
  - Get user info (fid, username, displayName, pfpUrl)
  - castToFeed function for sharing
  - shareWin function with embed

- [ ] `useTasks.ts`
  - Read all tasks
  - Read user task status
  - completeTask function with proof
  - claimReward function
  - Track completion and claiming state

- [ ] `useReferral.ts`
  - Read user referral code
  - Read referral stats
  - generateReferralCode function
  - registerWithReferral function
  - Track generation and registration state

## Farcaster Integration (Reference: farcaster-manifest.md)

### To Create:
- [ ] `public/.well-known/farcaster.json`
  - accountAssociation with header, payload, signature
  - frame configuration
  - name, icons, URLs
  - buttonTitle, splashImage
  - webhookUrl for notifications

### Setup Steps:
1. Generate manifest: `npx create-onchain-manifest --domain potatospin.xyz`
2. Sign with your Farcaster private key
3. Place at `.well-known/farcaster.json`
4. Submit to Warpcast portal

## Deployment Scripts

### To Create in `scripts/`:
- [ ] `deploy.js`
  - Deploy PotatoToken
  - Deploy PotatoNFT
  - Deploy PotatoSpinGame
  - Deploy PotatoTasks
  - Deploy PotatoReferral
  - Save addresses to deployments/baseSepolia.env

## Testing Files

### To Create in `test/`:
- [ ] `PotatoToken.test.js`
- [ ] `PotatoSpinGame.test.js`
- [ ] `PotatoTasks.test.js`
- [ ] `PotatoReferral.test.js`

## Quick Reference: Chain IDs
- Base Sepolia: 84532
- Base Mainnet: 8453

## File Sources in Attached Documents
1. **IMPLEMENTATION-GUIDE.md**: Complete smart contract and hook code
2. **wagmi-contracts-config.md**: Frontend config files and usage examples
3. **hardhat-config.md**: Hardhat configuration and .env setup
4. **farcaster-manifest.md**: Farcaster manifest generation
5. **custom-hooks.md**: All React hook implementations

## Implementation Order
1. Create smart contracts (PotatoTasks, PotatoReferral)
2. Update hardhat.config.js and .env
3. Deploy and test contracts
4. Install frontend dependencies
5. Create frontend infrastructure (wagmi, contracts.ts)
6. Create React components and hooks
7. Setup Farcaster integration
8. Test and deploy

Refer to IMPLEMENTATION-SETUP.md for detailed step-by-step phases.
