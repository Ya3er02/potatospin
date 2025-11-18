'use client'

import { ReactNode, createContext, useContext, useEffect, useState } from 'react'
import { sdk } from '@farcaster/miniapp-sdk'
import type { MiniAppContext } from '@farcaster/miniapp-sdk'

interface FarcasterContextType {
  isLoaded: boolean
  context: MiniAppContext | null
  error: Error | null
}

const FarcasterContext = createContext<FarcasterContextType>({
  isLoaded: false,
  context: null,
  error: null,
})

export function FarcasterProvider({ children }: { children: ReactNode }) {
  const [isLoaded, setIsLoaded] = useState(false)
  const [context, setContext] = useState<MiniAppContext | null>(null)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const initializeFarcaster = async () => {
      try {
        // Tell Farcaster that the app is ready
        await sdk.actions.ready()
        
        // Get the Farcaster context
        const farcasterContext = await sdk.context
        
        setContext(farcasterContext)
        setIsLoaded(true)
      } catch (err) {
        console.error('Error initializing Farcaster SDK:', err)
        setError(err as Error)
        setIsLoaded(true) // Still set loaded even on error
      }
    }

    initializeFarcaster()
  }, [])

  return (
    <FarcasterContext.Provider value={{ isLoaded, context, error }}>
      {children}
    </FarcasterContext.Provider>
  )
}

export function useFarcasterContext() {
  const context = useContext(FarcasterContext)
  if (context === undefined) {
    throw new Error('useFarcasterContext must be used within a FarcasterProvider')
  }
  return context
}