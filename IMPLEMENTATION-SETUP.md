# PotatoSpin Implementation Guide

## Overview
This guide provides step-by-step instructions to apply all the enhancements from the IMPLEMENTATION-GUIDE.md attachments to your PotatoSpin project.

## Files to Create

### 1. Smart Contracts (in `/contracts` folder)

#### PotatoTasks.sol
- Task verification system with Merkle proofs
- Tasks with completion tracking and reward claims
- Reference: See attached wagmi-contracts-config.md

#### PotatoReferral.sol
- Multi-level referral system
- User referral codes and reward distribution
- Referral stats tracking

### 2. Frontend Files (in `/src` folder)

Create the following directory structure:
```
src/
  lib/
    wagmi.ts
    contracts.ts
  hooks/
    useGameState.ts
    useChainlinkVRF.ts
    useFarcasterContext.ts
    useTasks.ts
    useReferral.ts
  components/
    Providers.tsx
    GameDashboard.tsx
  app/
    layout.tsx
    page.tsx
```

### 3. Configuration Files

#### Root Level
- Update: hardhat.config.js (see attached hardhat-config.md)
- Update: .env.example (add new environment variables)
- Update: package.json (add dependencies and scripts)

#### Public Folder
- Add Farcaster manifest at: `public/.well-known/farcaster.json`

## Implementation Steps

### Phase 1: Smart Contracts (Week 1-2)

1. **Create PotatoTasks.sol**
   - Copy from attached IMPLEMENTATION-GUIDE.md
   - Includes task creation, verification, and reward claiming
   - Uses Merkle proofs for verification

2. **Create PotatoReferral.sol**
   - Copy from attached IMPLEMENTATION-GUIDE.md
   - Implements multi-level referral system
   - Tracks referral codes and earnings

3. **Update PotatoSpinGame.sol**
   - Add task integration (call tasksContract.completeTask)
   - Add referral integration (call referralContract.distributeReferralRewards)
   - Already has Chainlink VRF v2.5 integration

4. **Install Dependencies**
   ```bash
   npm install --save-dev nomicfoundationhardhat-toolbox
   npm install --save-dev nomiclabshardhat-etherscan
   npm install --save-dev hardhat-gas-reporter solidity-coverage
   npm install openzeppelincontracts
   npm install chainlinkcontracts
   npm install dotenv
   ```

5. **Compile & Test**
   ```bash
   npm run compile
   npm run test
   npm run testgas
   npm run coverage
   ```

### Phase 2: Environment Setup (Week 2)

1. **Configure Hardhat** (Update hardhat.config.js)
   - Base Sepolia testnet configuration
   - Base mainnet configuration  
   - Gas reporter setup
   - BaseScan verification

2. **Setup Environment Variables** (Update .env.example)
   - Add all Chainlink VRF configuration
   - Add WalletConnect Project ID
   - Add contract addresses
   - Add API keys for verification

3. **Deployment**
   ```bash
   cp .env.example .env
   # Fill in all values
   npm run deploytestnet
   # Copy addresses to .env
   npm run deploymainnet  # After testing
   ```

### Phase 3: Frontend Setup (Week 3-4)

1. **Install Frontend Dependencies**
   ```bash
   npm install wagmi viem tanstackreact-query
   npm install rainbow-merainbowkit
   npm install farcasterframe-sdk
   npm install zustand
   npm install framer-motion
   ```

2. **Create Frontend Infrastructure** (`src/lib/`)
   - **wagmi.ts**: Wagmi v2 configuration with Rainbow wallet support
   - **contracts.ts**: Contract ABIs and addresses configuration

3. **Create Components** (`src/components/`)
   - **Providers.tsx**: RainbowKit and QueryClient providers
   - **GameDashboard.tsx**: Main game UI component

4. **Create Custom Hooks** (`src/hooks/`)
   - **useGameState.ts**: Game state management with Zustand
   - **useChainlinkVRF.ts**: VRF interaction wrapper
   - **useFarcasterContext.ts**: Farcaster SDK integration
   - **useTasks.ts**: Task interaction hooks
   - **useReferral.ts**: Referral system hooks

5. **Update App Structure** (`src/app/`)
   - **layout.tsx**: Add Providers and meta tags
   - **page.tsx**: Import GameDashboard component

### Phase 4: Farcaster Integration (Week 4)

1. **Generate Manifest**
   ```bash
   npx create-onchain-manifest --domain potatospin.xyz
   # Or use the manual script in attached farcaster-manifest.md
   ```

2. **Place Manifest**
   - Save generated manifest to `public/.well-known/farcaster.json`

3. **Submit to Farcaster**
   - Visit Warpcast Mini Apps portal
   - Submit your app URL
   - Wait for approval (24-48 hours)

### Phase 5: Testing & Deployment (Week 5-6)

1. **Run Tests**
   ```bash
   npm run test
   npm run testgas
   npm run coverage
   ```

2. **Security Audit**
   - Run Slither: `slither contracts`
   - Run Mythril: `myth analyze contracts/PotatoSpinGame.sol`
   - Use provided Security Vulnerability Matrix

3. **Beta Testing**
   - Deploy to Base Sepolia
   - Test with 10-20 beta users
   - Monitor for 1 week
   - Fix any P0/P1 bugs

4. **Production Deployment**
   ```bash
   npm run deploymainnet
   # Verify contracts on BaseScan
   ```

## Configuration Files Reference

### hardhat.config.js
- Solidity version: 0.8.20
- Network configurations for testnet and mainnet
- Gas reporter enabled
- Etherscan verification setup

### .env.example Variables
- `PRIVATEKEY`: Deployment wallet private key
- `BASESCANAPIKEY`: For contract verification
- `CHAINLINKVRFCOORDINATOR`: VRF coordinator address
- `CHAINLINKVRFKEYHASH`: Gas lane key hash
- `CHAINLINKVRFSUBSCRIPTIONID`: Your VRF subscription
- `NEXTPUBLICWALLETCONNECTPROJECTID`: From WalletConnect
- Contract addresses (populated after deployment)

### Environment Chain IDs
- Base Sepolia: 84532
- Base Mainnet: 8453

## Chainlink VRF Setup

1. Visit https://vrf.chain.link
2. Create a subscription on Base Sepolia
3. Fund subscription with LINK tokens
4. Create consumer (add Game contract address)
5. Note the subscription ID and key hash
6. Add to .env file

## Quick Start Commands

```bash
# Clone and setup
git clone https://github.com/Ya3er02/potatospin.git
cd potatospin
npm install

# Compile
npm run compile

# Test
npm run test

# Deploy to testnet
cp .env.example .env
# Edit .env with your values
npm run deploytestnet

# Run frontend
npm run dev
```

## Support Resources

- Base Docs: https://docs.base.org
- Chainlink VRF: https://docs.chain.link/vrf
- Wagmi Docs: https://wagmi.sh
- Farcaster Docs: https://docs.farcaster.xyz
- OpenZeppelin: https://docs.openzeppelin.com

## Critical Checklist Before Mainnet

- [ ] All contracts compiled without errors
- [ ] 80+ test coverage achieved
- [ ] No high/critical vulnerabilities in Slither/Mythril
- [ ] VRF subscription funded with LINK
- [ ] Contract addresses updated in .env
- [ ] Contracts verified on BaseScan
- [ ] Wagmi connects to wallet successfully
- [ ] Can read contract data (balances, energy)
- [ ] Can write to contracts (spin, claim)
- [ ] Events watched and UI updates
- [ ] Mobile responsive design tested
- [ ] Farcaster manifest signed and accessible
- [ ] Mini App submitted to Warpcast
- [ ] SSL certificate active
- [ ] Domain configured correctly
- [ ] All private keys in .env (never committed)
- [ ] Rate limiting active
- [ ] CORS properly configured

For detailed code, refer to the attached implementation files in your PR.
