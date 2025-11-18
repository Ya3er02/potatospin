'use client'

import { useFarcasterContext } from '@/components/FarcasterProvider'

/**
 * useFarcaster hook - consumer of global FarcasterProvider context.
 * Ensures only a single MiniAppContext/SDK load.
 * Loading completes even if Farcaster init errors, and error is handled by context.
 */
export function useFarcaster() {
  const { isLoaded, context, error } = useFarcasterContext()
  return {
    isSDKLoaded: isLoaded,
    context,
    error,
  }
}

export function useFarcasterUser() {
  const { context } = useFarcaster()

  return {
    fid: context?.user?.fid,
    username: context?.user?.username,
    displayName: context?.user?.displayName,
    pfpUrl: context?.user?.pfpUrl,
    custodyAddress: context?.user?.custodyAddress,
  }
}
