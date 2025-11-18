# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-11-18

### Added
- Complete Farcaster Mini App implementation
- Next.js 14 with App Router and TypeScript
- Wagmi v2 + Viem blockchain integration
- RainbowKit wallet connection UI
- Farcaster SDK integration with proper hooks
- Custom components: GameDashboard, SpinWheel, FarcasterUserCard
- Tailwind CSS with custom potato theme
- Smart contract ABIs and configuration
- Environment variable templates
- Comprehensive documentation
- ESLint configuration with TypeScript support
- TypeScript ESLint parser and plugin (v7.2.0+)

### Fixed
- ✅ **CRITICAL**: Replaced invalid `@farcaster/minikit` package with correct `@farcaster/miniapp-sdk` (v0.1.10)
- ✅ Created proper Farcaster SDK hooks and context providers
- ✅ Added FarcasterProvider for app-wide SDK access
- ✅ Implemented useFarcaster and useFarcasterContext hooks
- ✅ Updated all imports to use `@farcaster/miniapp-sdk`
- ✅ Added `.eslintrc.json` extending next/core-web-vitals
- ✅ Added TypeScript ESLint packages for TS 5.4 compatibility

### Changed
- Migrated from HTML/JS to Next.js 14 + TypeScript
- Replaced centralized backend with Base blockchain
- Changed from local storage to on-chain smart contracts
- Updated authentication from simple local to Farcaster + Wallet Connect
- **✅ MAJOR**: Upgraded Chainlink VRF v2 to VRF v2.5

### Chainlink VRF v2.5 Migration

#### Breaking Changes
⚠️ **Requires redeployment** - v2 contracts cannot be upgraded in-place to v2.5

#### Contract Changes

1. **Updated Imports**
   ```solidity
   // OLD v2:
   import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
   import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
   
   // NEW v2.5:
   import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
   import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
   import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
   ```

2. **Subscription ID Type**
   - Changed from `uint64` to `uint256`
   - More future-proof and consistent across networks

3. **Native Payment Support**
   - Added `bool nativePayment` parameter
   - Can now pay with ETH/MATIC instead of only LINK

4. **Request Function with extraArgs**
   ```solidity
   // v2.5 requires extraArgs parameter:
   requestId = i_vrfCoordinator.requestRandomWords(
       VRFV2PlusClient.RandomWordsRequest({
           keyHash: i_gasLane,
           subId: i_subscriptionId,
           requestConfirmations: REQUEST_CONFIRMATIONS,
           callbackGasLimit: i_callbackGasLimit,
           numWords: NUM_WORDS,
           extraArgs: VRFV2PlusClient._argsToBytes(
               VRFV2PlusClient.ExtraArgsV1({nativePayment: i_nativePayment})
           )
       })
   );
   ```

5. **Callback Optimization**
   - Changed `fulfillRandomWords` parameter from `memory` to `calldata`
   - Improves gas efficiency

#### Benefits

| Feature | VRF v2 | VRF v2.5 |
|---------|--------|----------|
| Payment Options | LINK only | LINK + native tokens |
| Subscription ID | uint64 | uint256 |
| Gas Efficiency | Standard | Optimized (calldata) |
| Configuration | Constructor only | Per-request (extraArgs) |
| Network Support | Limited | Unified coordinators |

#### Migration Guide

1. Create new v2.5 subscription on [vrf.chain.link](https://vrf.chain.link)
2. Note the `uint256` subscription ID
3. Deploy new PotatoSpinGame contract with v2.5 parameters:
   ```solidity
   constructor(
       address vrfCoordinator,
       bytes32 gasLane,
       uint256 subscriptionId,  // uint256 instead of uint64
       uint32 callbackGasLimit,
       bool nativePayment,      // NEW parameter
       address _potatoToken,
       address _potatoNFT
   )
   ```
4. Add contract as consumer to subscription
5. Fund with LINK (or native if nativePayment=true)
6. Test randomness requests

#### Base Sepolia Configuration

```solidity
address vrfCoordinator = 0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE;
bytes32 keyHash = 0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8;
uint256 subscriptionId = YOUR_SUBSCRIPTION_ID;
uint32 callbackGasLimit = 100000;
bool nativePayment = false; // true to pay with ETH
```

### Technical Details

#### Package Fix
The initial implementation incorrectly used `@farcaster/minikit` which is not published to npm. This has been corrected to use the official package:

```json
"@farcaster/miniapp-sdk": "^0.1.10"
```

#### Proper Implementation
Created the following files for correct Farcaster integration:
- `src/hooks/useFarcaster.ts` - React hooks for SDK
- `src/components/FarcasterProvider.tsx` - Context provider
- `src/components/FarcasterUserCard.tsx` - User profile display

#### Import Pattern
```typescript
import { sdk } from '@farcaster/miniapp-sdk'
import type { MiniAppContext } from '@farcaster/miniapp-sdk'
```

#### ESLint Configuration
Added `.eslintrc.json` with:
- Extends `next/core-web-vitals`
- TypeScript ESLint parser and plugin
- Proper rules for TypeScript 5.4

### Dependencies

Core packages:
- `@farcaster/miniapp-sdk`: ^0.1.10 (official Farcaster SDK)
- `next`: ^14.2.0
- `wagmi`: ^2.5.0
- `viem`: ^2.9.0
- `@rainbow-me/rainbowkit`: ^2.0.0
- `@coinbase/onchainkit`: ^0.15.0
- `@typescript-eslint/parser`: ^7.2.0
- `@typescript-eslint/eslint-plugin`: ^7.2.0

### Installation

```bash
npm install
```

This will now install all dependencies without errors.

### Verification

To verify packages are correctly installed:

```bash
npm list @farcaster/miniapp-sdk
# Should show: @farcaster/miniapp-sdk@0.1.10

npm list @typescript-eslint/parser
# Should show: @typescript-eslint/parser@7.2.0

npx hardhat compile
# Should compile VRF v2.5 contracts without errors
```

### References

- [Chainlink VRF v2.5 Documentation](https://docs.chain.link/vrf/v2-5/overview)
- [VRF v2 to v2.5 Migration Guide](https://docs.chain.link/vrf/v2-5/migration-from-v2)
- [Farcaster Mini App SDK](https://github.com/farcasterxyz/miniapp-sdk)
- [Base Network VRF Config](https://docs.chain.link/vrf/v2-5/supported-networks#base-sepolia-testnet)

---

## [1.0.0] - 2025-11-14

### Initial Release
- Basic HTML/JS spinning wheel game
- Virtual pet mechanics
- Local storage persistence
- Simple Solidity contracts with VRF v2
