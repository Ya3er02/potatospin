'use client'

import { useState, useEffect, useMemo } from 'react'
import { useAccount, useWaitForTransactionReceipt, useWriteContract, useWatchContractEvent } from 'wagmi'
import { CONTRACTS, GAME_CONTRACT_ABI } from '@/lib/contracts'
import toast from 'react-hot-toast'
import { motion, AnimatePresence } from 'framer-motion'

const SPIN_OUTCOMES = [
  { label: '🍟 FOOD', color: '#f59719', probability: 33 },
  { label: '🎮 PLAY', color: '#3b82f6', probability: 17 },
  { label: '🚿 BATH', color: '#10b981', probability: 17 },
  { label: '😴 SLEEP', color: '#8b5cf6', probability: 17 },
  { label: '✨ BONUS', color: '#f59e0b', probability: 8 },
  { label: '💔 FAIL', color: '#ef4444', probability: 8 },
]

function getWheelGeometry(outcomes) {
  // Defensive: handle zero/NaN, fallback to equal if all zero
  const total = outcomes.reduce((sum, o) => sum + (isFinite(o.probability) && o.probability > 0 ? o.probability : 0), 0)
  const fallbackAngle = 360 / outcomes.length
  let cumulative = 0
  return outcomes.map((outcome, i) => {
    let prob = isFinite(outcome.probability) && outcome.probability > 0 ? outcome.probability : 0
    let angle = total ? (prob / total) * 360 : fallbackAngle
    const start = cumulative
    const end = start + angle
    cumulative += angle
    return { ...outcome, startAngle: start, endAngle: end, i }
  })
}

function getSliceClipPath(startAngle, endAngle) {
  // Wheel center at (50,50), radius 50
  // Convert angles to radians
  const r = 50
  const startRad = (startAngle - 90) * Math.PI / 180
  const endRad = (endAngle - 90) * Math.PI / 180
  // Points: center, start arc, end arc
  const x1 = 50 + r * Math.cos(startRad)
  const y1 = 50 + r * Math.sin(startRad)
  const x2 = 50 + r * Math.cos(endRad)
  const y2 = 50 + r * Math.sin(endRad)
  // large-arc-flag: more than 180 degrees?
  const largeFlag = endAngle - startAngle > 180 ? 1 : 0
  // Build SVG path: move to center, line to (x1,y1), arc to (x2,y2), close
  return `M50,50 L${x1},${y1} A${r},${r} 0 ${largeFlag} 1 ${x2},${y2} Z`
}

export function SpinWheel() {
  const { address } = useAccount()
  const [isSpinning, setIsSpinning] = useState(false)
  const [result, setResult] = useState<string | null>(null)
  const [rotation, setRotation] = useState(0)
  const [txHash, setTxHash] = useState<string | undefined>()
  const [spinTimeout, setSpinTimeout] = useState<NodeJS.Timeout | null>(null)
  const wheelGeometry = useMemo(() => getWheelGeometry(SPIN_OUTCOMES), [])

  const { writeContract, data: hash } = useWriteContract()
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({ hash })

  useEffect(() => {
    setTxHash(hash)
  }, [hash])

  useWatchContractEvent({
    address: CONTRACTS.GAME_CONTRACT,
    abi: GAME_CONTRACT_ABI,
    eventName: 'SpinCompleted',
    listener(logs) {
      logs.forEach((log) => {
        if (log.args && log.args.player && address && log.args.player.toLowerCase() === address.toLowerCase()) {
          const resultValue = Number(log.args.prize) % SPIN_OUTCOMES.length
          const outcome = SPIN_OUTCOMES[resultValue]
          setResult(outcome.label)
          toast.success(`You got: ${outcome.label}!`)
          setIsSpinning(false)
          if (spinTimeout) {
            clearTimeout(spinTimeout)
          }
        }
      })
    },
  })

  const handleSpin = async () => {
    if (isSpinning || isConfirming) return

    try {
      setIsSpinning(true)
      setResult(null)
      setTxHash(undefined)
      const spins = 5 + Math.random() * 3
      const finalRotation = rotation + spins * 360
      setRotation(finalRotation)

      writeContract({
        address: CONTRACTS.GAME_CONTRACT,
        abi: GAME_CONTRACT_ABI,
        functionName: 'spin',
        args: [], // No args for spin()
      })

      const fallback = setTimeout(() => {
        setIsSpinning(false)
        toast.error('Spin result not received. Please check transaction or try again.')
      }, 9000)
      setSpinTimeout(fallback)
    } catch (error) {
      setIsSpinning(false)
      toast.error('Spin failed! Please try again.')
      console.error(error)
    }
  }

  useEffect(
    () => () => {
      if (spinTimeout) clearTimeout(spinTimeout)
    },
    [spinTimeout]
  )

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl shadow-xl p-8"
    >
      <h2 className="text-3xl font-bold text-center text-gray-800 mb-8">
        🎰 Spin the Wheel!
      </h2>

      {/* Wheel with SVG slices */}
      <div className="relative w-80 h-80 mx-auto mb-8">
        <motion.svg
          viewBox="0 0 100 100"
          width={320}
          height={320}
          animate={{ rotate: rotation }}
          transition={{ duration: 3, ease: 'easeOut' }}
          className="absolute top-0 left-0"
        >
          {wheelGeometry.map((slice, idx) => (
            <path
              key={slice.label}
              d={getSliceClipPath(slice.startAngle, slice.endAngle)}
              fill={slice.color}
              stroke="#fff"
              strokeWidth="2"
            />
          ))}
          {/* Labels at arc midpoint angle */}
          {wheelGeometry.map((slice, idx) => {
            const midAngle = (slice.startAngle + slice.endAngle) / 2
            const rad = (midAngle - 90) * Math.PI / 180
            const rText = 35 // Text radius in SVG units
            const xText = 50 + rText * Math.cos(rad)
            const yText = 50 + rText * Math.sin(rad)
            return (
              <text
                key={slice.label + '-label'}
                x={xText}
                y={yText}
                fontSize="8"
                fontWeight="bold"
                fill="#fff"
                textAnchor="middle"
                alignmentBaseline="middle"
                style={{ userSelect: 'none', pointerEvents: 'none' }}
                transform={`rotate(${midAngle} 50 50)`}
              >
                {slice.label}
              </text>
            )
          })}
        </motion.svg>

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
