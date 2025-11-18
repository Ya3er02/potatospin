'use client'

import { useState, useEffect } from 'react'
import { useAccount } from 'wagmi'
import { ConnectButton } from '@/components/ConnectButton'
import { GameDashboard } from '@/components/GameDashboard'
import { SpinWheel } from '@/components/SpinWheel'
import { motion } from 'framer-motion'

export default function Home() {
  const { address, isConnected } = useAccount()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <main className="min-h-screen p-4">
      {/* Header */}
      <header className="max-w-6xl mx-auto mb-8">
        <div className="flex justify-between items-center">
          <motion.h1 
            className="text-4xl font-bold text-potato-600"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            🥔 Potato Spin
          </motion.h1>
          <ConnectButton />
        </div>
      </header>

      {/* Main Content */}
      <div className="max-w-6xl mx-auto">
        {!isConnected ? (
          <motion.div 
            className="text-center py-20"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
          >
            <div className="text-8xl mb-8 animate-float">🥔</div>
            <h2 className="text-3xl font-bold mb-4 text-potato-700">
              Welcome to Potato Spin!
            </h2>
            <p className="text-gray-600 mb-8 max-w-md mx-auto">
              Connect your wallet to start playing and earning $POTATO tokens on Base blockchain
            </p>
            <ConnectButton />
          </motion.div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Left: Dashboard Stats */}
            <div className="lg:col-span-1">
              <GameDashboard address={address!} />
            </div>
            
            {/* Center: Spin Wheel */}
            <div className="lg:col-span-2">
              <SpinWheel />
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <footer className="max-w-6xl mx-auto mt-16 text-center text-gray-500 text-sm">
        <p>Built with 🥔 on Base blockchain | Powered by Farcaster</p>
      </footer>
    </main>
  )
}