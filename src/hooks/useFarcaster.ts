'use client'

import { useEffect, useState } from 'react'
import { sdk } from '@farcaster/miniapp-sdk'
import type { MiniAppContext } from '@farcaster/miniapp-sdk'

export function useFarcaster() {
  const [isSDKLoaded, setIsSDKLoaded] = useState(false)
  const [context, setContext] = useState<MiniAppContext | null>(null)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const load = async () => {
      try {
        // Initialize the SDK
        await sdk.actions.ready()
        setIsSDKLoaded(true)

        // Get Farcaster context
        const farcasterContext = await sdk.context
        setContext(farcasterContext)
      } catch (err) {
        console.error('Failed to load Farcaster SDK:', err)
        setError(err as Error)
      }
    }

    load()
  }, [])

  return {
    isSDKLoaded,
    context,
    error,
    sdk,
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