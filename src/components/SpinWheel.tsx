'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { CONTRACTS, GAME_CONTRACT_ABI } from '@/lib/contracts'
import toast from 'react-hot-toast'

const SPIN_OUTCOMES = [
  { label: '🍟 FOOD', color: '#f59719', probability: 33 },
  { label: '🎮 PLAY', color: '#3b82f6', probability: 17 },
  { label: '🚿 BATH', color: '#10b981', probability: 17 },
  { label: '😴 SLEEP', color: '#8b5cf6', probability: 17 },
  { label: '✨ BONUS', color: '#f59e0b', probability: 8 },
  { label: '💔 FAIL', color: '#ef4444', probability: 8 },
]

export function SpinWheel() {
  const [isSpinning, setIsSpinning] = useState(false)
  const [result, setResult] = useState<string | null>(null)
  const [rotation, setRotation] = useState(0)

  const { writeContract, data: hash } = useWriteContract()
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({ hash })

  const handleSpin = async () => {
    if (isSpinning || isConfirming) return

    try {
      setIsSpinning(true)
      setResult(null)

      // Trigger blockchain transaction
      writeContract({
        address: CONTRACTS.GAME_CONTRACT,
        abi: GAME_CONTRACT_ABI,
        functionName: 'spin',
        args: [1], // 1 spin
      })

      // Simulate wheel spin animation
      const randomOutcome = SPIN_OUTCOMES[Math.floor(Math.random() * SPIN_OUTCOMES.length)]
      const spins = 5 + Math.random() * 3
      const finalRotation = rotation + spins * 360 + Math.random() * 360
      
      setRotation(finalRotation)

      setTimeout(() => {
        setIsSpinning(false)
        setResult(randomOutcome.label)
        toast.success(`You got: ${randomOutcome.label}!`)
      }, 3000)

    } catch (error) {
      setIsSpinning(false)
      toast.error('Spin failed! Please try again.')
      console.error(error)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl shadow-xl p-8"
    >
      <h2 className="text-3xl font-bold text-center text-gray-800 mb-8">
        🎰 Spin the Wheel!
      </h2>

      {/* Wheel */}
      <div className="relative w-80 h-80 mx-auto mb-8">
        <motion.div
          className="w-full h-full rounded-full border-8 border-potato-500 shadow-2xl overflow-hidden relative"
          animate={{ rotate: rotation }}
          transition={{ duration: 3, ease: 'easeOut' }}
        >
          {SPIN_OUTCOMES.map((outcome, index) => (
            <div
              key={index}
              className="absolute w-full h-full flex items-center justify-center text-white font-bold text-lg"
              style={{
                background: outcome.color,
                clipPath: `polygon(50% 50%, ${50 + 50 * Math.cos((index * 60 - 90) * Math.PI / 180)}% ${50 + 50 * Math.sin((index * 60 - 90) * Math.PI / 180)}%, ${50 + 50 * Math.cos(((index + 1) * 60 - 90) * Math.PI / 180)}% ${50 + 50 * Math.sin(((index + 1) * 60 - 90) * Math.PI / 180)}%)`,
              }}
            >
              <span className="absolute" style={{ 
                transform: `rotate(${index * 60}deg) translateY(-100px)`,
              }}>
                {outcome.label}
              </span>
            </div>
          ))}
        </motion.div>

        {/* Pointer */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-4 w-0 h-0 border-l-[20px] border-l-transparent border-r-[20px] border-r-transparent border-t-[40px] border-t-red-500 z-10" />

        {/* Center button */}
        <motion.button
          onClick={handleSpin}
          disabled={isSpinning || isConfirming}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 bg-potato-500 rounded-full shadow-xl flex items-center justify-center text-white font-bold text-2xl border-4 border-white z-20 disabled:opacity-50 disabled:cursor-not-allowed"
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          {isSpinning ? '🔄' : '🎲'}
        </motion.button>
      </div>

      {/* Result Display */}
      <AnimatePresence>
        {result && (
          <motion.div
            initial={{ opacity: 0, scale: 0.5 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.5 }}
            className="text-center mb-6"
          >
            <h3 className="text-4xl font-bold text-potato-600 animate-pulse-glow">
              {result}
            </h3>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Spin Button */}
      <motion.button
        onClick={handleSpin}
        disabled={isSpinning || isConfirming}
        className="w-full bg-gradient-to-r from-potato-500 to-orange-500 text-white font-bold py-4 px-8 rounded-full shadow-lg disabled:opacity-50 disabled:cursor-not-allowed glow-potato"
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        {isSpinning ? 'Spinning...' : isConfirming ? 'Confirming...' : '🎰 SPIN NOW! (1 Energy)'}
      </motion.button>

      {/* Info */}
      <p className="text-center text-gray-500 text-sm mt-4">
        Each spin costs 1 energy. Win $POTATO tokens and rewards!
      </p>
    </motion.div>
  )
}