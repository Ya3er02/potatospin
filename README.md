# 🥔 Potato Spin - Farcaster Mini App

**A decentralized play-to-earn spinning game built on Base blockchain and integrated with Farcaster's social graph.**

🎉 **Now a Farcaster Mini App!** Play directly in Warpcast and earn real $POTATO tokens on Base L2.

## ✨ What's New in V2.0

This is a complete architectural transformation from a simple HTML game to a production-ready Web3 application:

### 🔄 Migration Highlights
- **From**: Telegram Bot (Python/Pyrogram) → **To**: Farcaster Mini App (Next.js 14)
- **From**: Centralized backend → **To**: Base blockchain (Ethereum L2)
- **From**: Local storage → **To**: On-chain state + smart contracts
- **From**: Off-chain points → **To**: ERC20 $POTATO token
- **From**: No wallet → **To**: Wallet Connect + Farcaster authentication

## 🎮 Features

### Core Gameplay
- **🎰 Slot Machine Spins**: Spin to win $POTATO tokens with provably fair randomness (Chainlink VRF)
- **⚡ Energy System**: Time-based energy regeneration (on-chain)
- **🥔 Virtual Pet**: Grow your potato pet through levels and upgrades
- **🎯 Task System**: Complete tasks for bonus rewards
- **🏆 Leaderboard**: Compete with other players globally

### Blockchain Features
- **ERC20 $POTATO Token**: True ownership, tradeable on DEXs
- **NFT Boosters**: ERC1155 collectible power-ups
- **Referral System**: Earn from friends' gameplay
- **Gasless Onboarding**: First spins sponsored via Coinbase Paymaster

### Social Features (Farcaster)
- **Cast Integration**: Share wins directly to your feed
- **Social Login**: Sign in with Farcaster account
- **Friend Discovery**: Connect with Farcaster social graph
- **Notifications**: Get alerts when energy refills

## 🛠️ Tech Stack

### Frontend
- **Next.js 14** (App Router) + TypeScript
- **Wagmi v2** + Viem (Ethereum interactions)
- **@farcaster/minikit** (Farcaster SDK)
- **Framer Motion** (animations)
- **Tailwind CSS** (styling)
- **RainbowKit** (wallet connection)

### Smart Contracts (Solidity)
- **PotatoToken.sol** (ERC20) - Game currency
- **PotatoSpinGame.sol** - Core game logic with Chainlink VRF
- **PotatoNFT.sol** (ERC1155) - Booster NFTs
- **PotatoTasks.sol** - Task verification system
- **PotatoReferral.sol** - Referral rewards

### Blockchain
- **Base** (Ethereum L2) - Mainnet: Chain ID 8453
- **Base Sepolia** - Testnet: Chain ID 84532
- **Chainlink VRF v2.5** - Verifiable randomness
- **The Graph** - Blockchain indexing

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- npm or yarn
- MetaMask or compatible wallet
- Base Sepolia testnet ETH ([faucet](https://faucet.quicknode.com/base/sepolia))

### Installation

```bash
# Clone the repository
git clone https://github.com/Ya3er02/potatospin.git
cd potatospin

# Checkout the Farcaster migration branch
git checkout farcaster-migration

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your values

# Compile smart contracts
npm run compile

# Run development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the app.

### Deploy Smart Contracts

```bash
# Deploy to Base Sepolia testnet
npm run deploy:testnet

# Deploy to Base mainnet (production)
npm run deploy:mainnet

# Verify contracts on BaseScan
npm run verify
```

## 📁 Project Structure

```
potatospin/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── layout.tsx       # Root layout with providers
│   │   ├── page.tsx         # Home page
│   │   └── globals.css      # Global styles
│   ├── components/          # React components
│   │   ├── Providers.tsx    # Web3 providers
│   │   ├── ConnectButton.tsx
│   │   ├── GameDashboard.tsx
│   │   └── SpinWheel.tsx
│   └── lib/                 # Utilities and configs
│       ├── wagmi.ts         # Wagmi configuration
│       └── contracts.ts     # Contract addresses and ABIs
├── contracts/              # Solidity smart contracts
│   ├── PotatoToken.sol
│   ├── PotatoSpinGame.sol
│   ├── PotatoNFT.sol
│   ├── PotatoTasks.sol
│   └── PotatoReferral.sol
├── public/
│   └── .well-known/
│       └── farcaster.json   # Farcaster Mini App manifest
├── hardhat.config.js       # Hardhat configuration
├── package.json
├── next.config.js
├── tailwind.config.ts
└── tsconfig.json
```

## 🔐 Environment Variables

Create a `.env` file with:

```env
# App Configuration
NEXT_PUBLIC_APP_NAME=Potato Spin
NEXT_PUBLIC_APP_URL=https://potatospin.xyz

# Base Blockchain
NEXT_PUBLIC_CHAIN_ID=84532  # Base Sepolia testnet
NEXT_PUBLIC_RPC_URL=https://sepolia.base.org

# Contract Addresses (update after deployment)
NEXT_PUBLIC_POTATO_TOKEN_ADDRESS=0x...
NEXT_PUBLIC_GAME_CONTRACT_ADDRESS=0x...
NEXT_PUBLIC_NFT_CONTRACT_ADDRESS=0x...

# WalletConnect
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id

# Private (for deployment only)
PRIVATE_KEY=your_private_key
BASESCAN_API_KEY=your_api_key
```

## 🏆 Tokenomics

**$POTATO Token (ERC20)**
- Total Supply: 100,000,000 tokens
- Distribution:
  - 40% Play-to-Earn Pool (4 years)
  - 20% Liquidity
  - 15% Team (2-year vesting)
  - 15% Community Rewards
  - 10% Initial Airdrop

## 🔒 Security

- Smart contracts audited by [pending]
- OpenZeppelin standard implementations
- Reentrancy guards on all payable functions
- Chainlink VRF for verifiable randomness
- Rate limiting and anti-bot measures

## 🛣️ Roadmap

- [x] **Phase 1**: HTML/JS prototype
- [x] **Phase 2**: Virtual pet mechanics
- [x] **Phase 3**: Smart contract development
- [x] **Phase 4**: Next.js + Farcaster integration (CURRENT)
- [ ] **Phase 5**: Mainnet launch + liquidity pool
- [ ] **Phase 6**: NFT marketplace
- [ ] **Phase 7**: Multiplayer tournaments
- [ ] **Phase 8**: DAO governance

## 👥 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request

## 📝 License

MIT License - see LICENSE file

## 🔗 Links

- **Live App**: [potatospin.xyz](https://potatospin.xyz)
- **Farcaster**: [@potatospin](https://warpcast.com/potatospin)
- **Twitter**: [@ya3er14](https://twitter.com/ya3er14)
- **GitHub**: [Ya3er02/potatospin](https://github.com/Ya3er02/potatospin)
- **Base Explorer**: [BaseScan](https://sepolia.basescan.org)

---

**Made with 🥔 by [@Ya3er02](https://github.com/Ya3er02)**

*Powered by Base, Farcaster, and Chainlink*