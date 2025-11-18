'use client'

import { motion } from 'framer-motion'
import { useBalance, useReadContract } from 'wagmi'
import { CONTRACTS, POTATO_TOKEN_ABI, GAME_CONTRACT_ABI } from '@/lib/contracts'
import { formatEther } from 'viem'

interface GameDashboardProps {
  address: `0x${string}`
}

export function GameDashboard({ address }: GameDashboardProps) {
  // Fetch ETH balance
  const { data: ethBalance } = useBalance({ address })
  
  // Fetch POTATO token balance
  const { data: potatoBalance } = useReadContract({
    address: CONTRACTS.POTATO_TOKEN,
    abi: POTATO_TOKEN_ABI,
    functionName: 'balanceOf',
    args: [address],
  })

  // Fetch user energy
  const { data: userEnergy } = useReadContract({
    address: CONTRACTS.GAME_CONTRACT,
    abi: GAME_CONTRACT_ABI,
    functionName: 'getUserEnergy',
    args: [address],
  })

  // Fetch user level
  const { data: userLevel } = useReadContract({
    address: CONTRACTS.GAME_CONTRACT,
    abi: GAME_CONTRACT_ABI,
    functionName: 'getUserLevel',
    args: [address],
  })

  const stats = [
    {
      label: '🥔 $POTATO',
      value: potatoBalance ? formatEther(potatoBalance as bigint) : '0.00',
      color: 'bg-potato-500',
    },
    {
      label: '⚡ Energy',
      value: userEnergy?.toString() || '0',
      color: 'bg-blue-500',
    },
    {
      label: '🎯 Level',
      value: userLevel?.toString() || '1',
      color: 'bg-green-500',
    },
    {
      label: '💰 ETH',
      value: ethBalance ? parseFloat(formatEther(ethBalance.value)).toFixed(4) : '0.0000',
      color: 'bg-purple-500',
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      className="bg-white rounded-2xl shadow-xl p-6 space-y-4"
    >
      <h2 className="text-2xl font-bold text-gray-800 mb-6">
        📊 Your Stats
      </h2>

      {stats.map((stat, index) => (
        <motion.div
          key={stat.label}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: index * 0.1 }}
          className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-4"
        >
          <div className="flex justify-between items-center">
            <span className="text-gray-600 font-medium">{stat.label}</span>
            <span className={`text-2xl font-bold ${stat.color.replace('bg-', 'text-')}`}>
              {stat.value}
            </span>
          </div>
          <div className="mt-2 h-2 bg-gray-200 rounded-full overflow-hidden">
            <motion.div
              className={`h-full ${stat.color}`}
              initial={{ width: 0 }}
              animate={{ width: '75%' }}
              transition={{ delay: index * 0.1 + 0.2, duration: 0.5 }}
            />
          </div>
        </motion.div>
      ))}

      {/* Pet Status */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.5 }}
        className="mt-6 p-6 bg-gradient-to-br from-potato-100 to-orange-100 rounded-2xl text-center"
      >
        <div className="text-6xl mb-3 animate-bounce-slow">🥔</div>
        <h3 className="text-xl font-bold text-potato-700">Your Potato Pet</h3>
        <p className="text-sm text-gray-600 mt-2">Level {userLevel?.toString() || '1'} Spud</p>
      </motion.div>

      {/* Quick Actions */}
      <div className="space-y-2 mt-6">
        <button className="w-full bg-gradient-to-r from-green-500 to-green-600 text-white font-bold py-3 rounded-lg hover:shadow-lg transition-all">
          🎯 Tasks
        </button>
        <button className="w-full bg-gradient-to-r from-purple-500 to-purple-600 text-white font-bold py-3 rounded-lg hover:shadow-lg transition-all">
          🏆 Leaderboard
        </button>
      </div>
    </motion.div>
  )
}