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

### Fixed
- ✅ **CRITICAL**: Replaced invalid `@farcaster/minikit` package with correct `@farcaster/miniapp-sdk` (v0.1.10)
- ✅ Created proper Farcaster SDK hooks and context providers
- ✅ Added FarcasterProvider for app-wide SDK access
- ✅ Implemented useFarcaster and useFarcasterContext hooks
- ✅ Updated all imports to use `@farcaster/miniapp-sdk`

### Changed
- Migrated from HTML/JS to Next.js 14 + TypeScript
- Replaced centralized backend with Base blockchain
- Changed from local storage to on-chain smart contracts
- Updated authentication from simple local to Farcaster + Wallet Connect

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

### Dependencies

Core packages:
- `@farcaster/miniapp-sdk`: ^0.1.10 (official Farcaster SDK)
- `next`: ^14.2.0
- `wagmi`: ^2.5.0
- `viem`: ^2.9.0
- `@rainbow-me/rainbowkit`: ^2.0.0
- `@coinbase/onchainkit`: ^0.15.0

### Installation

```bash
npm install
```

This will now install all dependencies without errors.

### Verification

To verify the package is correctly installed:

```bash
npm list @farcaster/miniapp-sdk
# Should show: @farcaster/miniapp-sdk@0.1.10
```

---

## [1.0.0] - 2025-11-14

### Initial Release
- Basic HTML/JS spinning wheel game
- Virtual pet mechanics
- Local storage persistence
- Simple Solidity contracts