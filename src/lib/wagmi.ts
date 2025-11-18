import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { base, baseSepolia } from 'wagmi/chains'

function getWalletConnectProjectId() {
  const id = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID
  if (!id || id === 'YOUR_PROJECT_ID') {
    throw new Error(
      'Fatal: NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID must be set to a valid WalletConnect Cloud project ID (not placeholder). ' +
      'Go to https://cloud.walletconnect.com, create a project, and set this env var before deploying.'
    )
  }
  return id
}

export const config = getDefaultConfig({
  appName: process.env.NEXT_PUBLIC_APP_NAME || 'Potato Spin',
  projectId: getWalletConnectProjectId(),
  chains: [
    process.env.NODE_ENV === 'production' ? base : baseSepolia,
  ],
  ssr: true,
})
