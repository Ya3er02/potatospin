# Potato Spin Deployment Guide

## Prerequisites

1. **Node.js 18+** and npm installed
2. **Wallet with funds** on Base Sepolia (testnet) or Base (mainnet)
3. **Chainlink VRF Subscription** created at [vrf.chain.link](https://vrf.chain.link/)
4. **BaseScan API Key** from [basescan.org](https://basescan.org/)

## Step-by-Step Deployment

### 1. Clone and Install

```bash
git clone https://github.com/Ya3er02/potatospin.git
cd potatospin
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and fill in:
- `PRIVATE_KEY`: Your wallet private key
- `BASESCAN_API_KEY`: Your BaseScan API key
- `CHAINLINK_VRF_SUBSCRIPTION_ID`: Your VRF subscription ID
- `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`: From cloud.walletconnect.com

### 3. Create Chainlink VRF Subscription

1. Go to [vrf.chain.link](https://vrf.chain.link/)
2. Connect wallet
3. Select **Base Sepolia** network
4. Click **Create Subscription**
5. Fund with LINK tokens (minimum 5 LINK)
6. Copy Subscription ID to `.env`

### 4. Compile Contracts

```bash
npm run compile
```

### 5. Run Tests

```bash
npm run test
npm run test:coverage
```

Ensure >90% coverage before deploying.

### 6. Deploy to Testnet

```bash
npm run deploy:testnet
```

This will:
- Deploy all contracts
- Setup roles and permissions
- Fund game contract with tokens
- Save addresses to `deployments/baseSepolia.json`

### 7. Add VRF Consumer

After deployment:
1. Go back to [vrf.chain.link](https://vrf.chain.link/)
2. Open your subscription
3. Click **Add Consumer**
4. Paste **PotatoSpinGame** contract address
5. Confirm transaction

### 8. Verify Contracts

```bash
npm run verify:testnet
```

Or use commands from deployment output.

### 9. Update Frontend Config

Copy contract addresses from `deployments/baseSepolia.env` to your `.env`:

```bash
cat deployments/baseSepolia.env >> .env
```

### 10. Test Game Functions

```bash
# Test spinning
npx hardhat run scripts/test-game.js --network baseSepolia
```

### 11. Deploy Frontend

```bash
npm run build
npm run start
```

Or deploy to Vercel:

```bash
vercel deploy --prod
```

## Mainnet Deployment

**⚠️ WARNING: Triple-check everything before mainnet!**

1. Run security audit on contracts
2. Test extensively on testnet
3. Create new VRF subscription on Base mainnet
4. Update `.env` with mainnet RPC and subscription ID
5. Deploy:

```bash
npm run deploy:mainnet
```

6. Add VRF consumer on mainnet
7. Verify contracts
8. Monitor for 24 hours before announcing

## Post-Deployment Tasks

### Setup Monitoring

- [ ] Add contracts to Tenderly dashboard
- [ ] Setup alerts for failed transactions
- [ ] Monitor VRF subscription balance

### Create Initial Content

- [ ] Upload NFT metadata to IPFS
- [ ] Create initial tasks in PotatoTasks
- [ ] Setup referral codes

### Security

- [ ] Transfer ownership to multi-sig wallet
- [ ] Setup Gnosis Safe for admin operations
- [ ] Document emergency procedures

## Troubleshooting

### VRF Request Fails

- Check subscription has enough LINK
- Verify game contract is added as consumer
- Check gas limit is sufficient (500k recommended)

### Transaction Reverts

- Ensure deployer has enough ETH for gas
- Check network congestion
- Try increasing gas price

### Contract Not Verifying

- Wait 1-2 minutes after deployment
- Check constructor arguments match exactly
- Try manual verification on BaseScan

## Support

- GitHub Issues: [github.com/Ya3er02/potatospin/issues](https://github.com/Ya3er02/potatospin/issues)
- Twitter: [@ya3er14](https://twitter.com/ya3er14)
- Farcaster: @potatospin
