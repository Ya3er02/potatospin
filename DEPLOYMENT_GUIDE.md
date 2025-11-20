# Potato Spin Deployment Guide

## ...snip...

### 10. Test Game Functions

Instead of a test-game.js script, you can re-run the deploy script to verify successful deployment:

```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

This ensures all contracts deploy, connect, and roles are set up on the chosen network. For specific contract function tests, use Hardhat or Foundry unit tests in the /test folder.

### 11. Deploy Frontend

...rest unchanged...
