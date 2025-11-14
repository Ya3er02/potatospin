# 🥔 Potato Spin - Complete Blockchain Gaming Platform

🎮 **Live Demo**: [https://ya3er02.github.io/potatospin/](https://ya3er02.github.io/potatospin/)

A decentralized spinning wheel game built on Ethereum with provably fair randomness using Chainlink VRF.

## ✨ Features

### 🎮 Game Features
- **Provably Fair Gaming** - Chainlink VRF for verifiable randomness
- **8 Prize Levels** - From Try Again to JACKPOT!
- **Real-time Stats** - Track your spins and wins
- **Beautiful Animations** - Smooth spinning wheel with effects
- **Mobile Responsive** - Play anywhere, anytime

### 💰 Token Economy
- **POTATO Token (ERC-20)** - In-game currency
- **NFT Rewards (ERC-721)** - Legendary potatoes for jackpots
- **Staking System** - Earn 10% APY
- **Leaderboard** - Compete with other players

## 🎯 Prize Distribution

| Prize | Emoji | Probability | Reward |
|-------|-------|-------------|--------|
| JACKPOT | 🎉 | 1% | 1,000 POTATO + NFT |
| Diamond | 💎 | 3% | 500 POTATO |
| Lucky | 🍀 | 5% | 200 POTATO |
| Star | ⭐ | 10% | 100 POTATO |
| Gift | 🎁 | 15% | 50 POTATO |
| Balloon | 🎈 | 20% | 20 POTATO |
| Candy | 🍭 | 21% | 10 POTATO |
| Try Again | 😢 | 25% | 0 POTATO |

## 🚀 Quick Start

### Play Now (No Installation)
1. Visit [https://ya3er02.github.io/potatospin/](https://ya3er02.github.io/potatospin/)
2. Click "SPIN THE POTATO!"
3. Watch the wheel spin!
4. See your prize and stats update

### Local Development

```bash
# Clone repository
git clone https://github.com/Ya3er02/potatospin.git
cd potatospin

# Open index.html in browser
open index.html
```

## 💻 Technology Stack

### Smart Contracts
- **Solidity ^0.8.20** - Contract language
- **OpenZeppelin** - Security standards
- **Chainlink VRF** - Random number generation
- **Hardhat** - Development environment

### Backend
- **Node.js + Express** - API server
- **WebSocket** - Real-time updates
- **MongoDB** - Database
- **Ethers.js** - Blockchain interaction

### Frontend
- **HTML5 Canvas** - Wheel rendering
- **Vanilla JavaScript** - Game logic
- **CSS3 Animations** - Smooth effects
- **Responsive Design** - Mobile-first

## 📁 Project Structure

```
potatospin/
├── contracts/              # Smart Contracts
│   ├── PotatoToken.sol
│   ├── PotatoNFT.sol
│   ├── PotatoSpinGame.sol
│   └── PotatoStaking.sol
├── backend/               # Backend Services
│   ├── server.js
│   └── websocket.js
├── scripts/               # Deployment
│   └── deploy.js
├── docs/                  # Documentation
├── index.html             # Main Game
└── README.md
```

## 🔐 Smart Contracts

### 1. PotatoToken (ERC-20)
- Max Supply: 1 billion tokens
- Mintable & Burnable
- Used for spins and rewards

### 2. PotatoNFT (ERC-721)
- Legendary potato NFTs
- 4 rarity levels
- Awarded for jackpots

### 3. PotatoSpinGame
- Chainlink VRF integration
- Fair prize distribution
- Event tracking

### 4. PotatoStaking
- 10% APY rewards
- No lock-up period
- Claim anytime

## 🚀 Deployment

### GitHub Pages (Current)
```bash
# Already deployed at:
https://ya3er02.github.io/potatospin/
```

### Smart Contracts (Testnet)
```bash
npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia
```

### Backend API
```bash
cd backend
npm install
npm start
```

## 📡 API Documentation

### Game Endpoints
- `GET /api/health` - Health check
- `GET /api/balance/:address` - Token balance
- `GET /api/player/:address/stats` - Player stats
- `GET /api/leaderboard` - Top 100 players

### Staking Endpoints
- `GET /api/staking/:address` - Staking info
- `POST /api/staking/stake` - Stake tokens
- `POST /api/staking/claim` - Claim rewards

## 🧪 Testing

### Smart Contracts
```bash
npx hardhat test
npx hardhat coverage
```

### Backend
```bash
cd backend
npm test
```

## 🔐 Security Features

- ✅ ReentrancyGuard protection
- ✅ Access control (Ownable)
- ✅ Chainlink VRF randomness
- ✅ Input validation
- ✅ Event transparency
- ✅ Audited contracts

## 🗺️ Roadmap

### Phase 1 - Q1 2025 ✅
- [x] Core game development
- [x] Smart contracts
- [x] Frontend UI
- [x] GitHub Pages deployment

### Phase 2 - Q2 2025
- [ ] Testnet deployment
- [ ] Backend API launch
- [ ] Staking mechanism
- [ ] Leaderboard system

### Phase 3 - Q3 2025
- [ ] Mainnet launch
- [ ] Mobile app
- [ ] Tournament mode
- [ ] NFT marketplace

### Phase 4 - Q4 2025
- [ ] Cross-chain support
- [ ] DAO governance
- [ ] VR integration
- [ ] Global expansion

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 📧 Contact

- **GitHub**: [@Ya3er02](https://github.com/Ya3er02)
- **Twitter**: [@ya3er14](https://twitter.com/ya3er14)
- **Email**: support@potatospin.io

## ⭐ Support

If you like this project, please give it a star! ⭐

---

**Made with 🥔 and ❤️ by Yaser**

🎮 [Play Now](https://ya3er02.github.io/potatospin/) | 📚 [Documentation](./docs/) | 🐛 [Report Bug](https://github.com/Ya3er02/potatospin/issues)