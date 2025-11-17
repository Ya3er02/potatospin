# 🥔 Potato Spin - Complete Blockchain Gaming Platform

**🎮 Live Demo**: https://rawcdn.githack.com/Ya3er02/potatospin/main/index.html

A decentralized spinning wheel game built on Ethereum with provably fair randomness using Chainlink VRF.

## ✨ Features

### 🎮 Game Features
- **Provably Fair Gaming** - Chainlink VRF for verifiable randomness
- **8 Prize Levels** - From Try Again to JACKPOT!
- **Real-time Stats** - Track your spins and wins
- **Beautiful Animations** - Smooth spinning wheel with effects
- **Mobile Responsive** - Play anywhere, anytime
- **Data Persistence** - localStorage for stats tracking

### 🍕 Token Economy
- **POTATO Token (ERC-20)** - In-game currency with 1 billion max supply
- **NFT Rewards (ERC-721)** - Legendary potatoes for jackpot winners
- **Staking System** - Earn 10% APY on staked tokens
- **Leaderboard** - Compete with other players globally

### 💎 Prize Distribution
| Prize | Emoji | Probability | Reward | ROI |
|-------|-------|-------------|--------|-----|
| JACKPOT | 🎉 | 1% | 1,000 POTATO | 100x |
| Diamond | 💎 | 3% | 500 POTATO | 50x |
| Lucky | 🍀 | 5% | 200 POTATO | 20x |
| Star | ⭐ | 10% | 100 POTATO | 10x |
| Gift | 🎁 | 15% | 50 POTATO | 5x |
| Balloon | 🎈 | 20% | 20 POTATO | 2x |
| Candy | 🍭 | 21% | 10 POTATO | 1x |
| Try Again | 😢 | 25% | 0 POTATO | 0x |

## 🏗️ Project Structure

### Smart Contracts (4/4 Complete)
```
contracts/
├── PotatoToken.sol         ✅ ERC-20 token with burn functionality
├── PotatoNFT.sol          ✅ ERC-721 NFTs with rarity tiers
├── PotatoSpinGame.sol     ✅ Main game logic with Chainlink VRF
└── PotatoStaking.sol      ✅ Staking contract with 10% APY
```

### Frontend (Complete)
```
├── index.html              ✅ Main game interface
│   - Fixed wheel calculation bug
│   - Added localStorage persistence
│   - Improved accessibility (ARIA labels)
│   - Responsive design for mobile
│   - Proper error handling
```

### Configuration (Complete)
```
├── hardhat.config.js       ✅ Development environment setup
├── .env.example           ✅ Environment variables template
└── package.json           ✅ Dependencies and scripts
```

## 🚀 Quick Start

### Prerequisites
- Node.js v16+
- Hardhat
- MetaMask or compatible Web3 wallet

### Installation

```bash
# Clone the repository
git clone https://github.com/Ya3er02/potatospin.git
cd potatospin

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Fill in your API keys and private key in .env
nano .env

# Compile smart contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to Sepolia testnet
npx hardhat run scripts/deploy.js --network sepolia

# Deploy to mainnet (be careful!)
npx hardhat run scripts/deploy.js --network mainnet
```

## 🎲 How to Play

1. **Connect Your Wallet** - Click "Connect Wallet" to link MetaMask
2. **Check Balance** - Ensure you have POTATO tokens (10 per spin)
3. **Spin the Wheel** - Click "SPIN THE POTATO!" button
4. **Win Prizes** - Get random prizes from 0 to 1,000 POTATO
5. **Jackpot Winners** - Win exclusive NFTs for JACKPOT prize

## 📊 Token Specifications

### POTATO Token (ERC-20)
- **Name**: Potato Token
- **Symbol**: POTATO
- **Decimals**: 18
- **Max Supply**: 1,000,000,000 POTATO
- **Initial Supply**: 100,000,000 POTATO

### Staking
- **APY**: 10%
- **Lock-up Period**: None - withdraw anytime
- **Min Stake**: 0.000001 POTATO

## 🔐 Security Features

- **Chainlink VRF** - Verifiable randomness for fair gameplay
- **ReentrancyGuard** - Protection against reentrancy attacks
- **Input Validation** - All external function inputs validated
- **Event Logging** - All state changes emit events
- **Owner Controls** - Multi-sig admin capabilities

## 🛠️ Recent Improvements (Current Session)

### Frontend Fixes
- ✅ Fixed wheel angle calculation bug (critical)
- ✅ Added input validation throughout
- ✅ Implemented comprehensive error handling
- ✅ Added data persistence with localStorage
- ✅ Enhanced accessibility with ARIA labels
- ✅ Improved responsive design for mobile
- ✅ Fixed timing synchronization issues
- ✅ Added protection against multiple clicks

### Smart Contracts
- ✅ Added zero address validation to PotatoToken
- ✅ Added positive amount validation
- ✅ Enhanced event emission for transparency
- ✅ Implemented burn functions for token control
- ✅ Improved NatSpec documentation

### New Smart Contracts
- ✅ PotatoNFT.sol - ERC-721 contract for jackpot NFTs
- ✅ PotatoSpinGame.sol - Main game with Chainlink VRF
- ✅ PotatoStaking.sol - Staking with 10% APY

### Configuration
- ✅ hardhat.config.js - Complete Hardhat setup
- ✅ .env.example - All required environment variables

## 📈 Roadmap

### Phase 1: Core Game (In Progress ✅)
- [x] Frontend game interface
- [x] Smart contracts (all 4)
- [x] Configuration files
- [x] Bug fixes and improvements

### Phase 2: Backend & Infrastructure
- [ ] Node.js API server
- [ ] WebSocket for real-time updates
- [ ] Database integration
- [ ] Deployment scripts

### Phase 3: Advanced Features
- [ ] Leaderboard system
- [ ] Social features
- [ ] Multi-chain support
- [ ] Mobile app

### Phase 4: Mainnet Launch
- [ ] Security audit
- [ ] Testnet deployment
- [ ] Beta testing
- [ ] Mainnet launch

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For questions or suggestions, please reach out to:
- GitHub: [@Ya3er02](https://github.com/Ya3er02)
- Email: [your-email@example.com](mailto:your-email@example.com)

## 🙏 Acknowledgments

- **Chainlink** - For VRF randomness
- **OpenZeppelin** - For secure smart contract libraries
- **Hardhat** - For development framework
- **Ethereum Community** - For inspiration and support

---

**Made with 🥔 by Ya3er02**
