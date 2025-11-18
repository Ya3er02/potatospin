'use client'

import { motion } from 'framer-motion'
import { useFarcasterContext } from './FarcasterProvider'

export function FarcasterUserCard() {
  const { isLoaded, context, error } = useFarcasterContext()

  if (!isLoaded) {
    return (
      <div className="bg-white rounded-2xl shadow-xl p-6 animate-pulse">
        <div className="h-20 bg-gray-200 rounded" />
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-red-50 rounded-2xl shadow-xl p-6 border-2 border-red-200">
        <p className="text-red-600 text-sm">
          ⚠️ Running outside Farcaster. Some features may be limited.
        </p>
      </div>
    )
  }

  const user = context?.user

  if (!user) {
    return (
      <div className="bg-yellow-50 rounded-2xl shadow-xl p-6 border-2 border-yellow-200">
        <p className="text-yellow-700 text-sm">
          👤 No Farcaster user found. Please open in Warpcast.
        </p>
      </div>
    )
  }

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      className="bg-gradient-to-br from-purple-50 to-blue-50 rounded-2xl shadow-xl p-6 border-2 border-purple-200"
    >
      <div className="flex items-center gap-4">
        {/* Profile Picture */}
        {user.pfpUrl && (
          <motion.img
            src={user.pfpUrl}
            alt={user.displayName || user.username || 'User'}
            className="w-16 h-16 rounded-full border-4 border-white shadow-lg"
            whileHover={{ scale: 1.1 }}
          />
        )}

        {/* User Info */}
        <div className="flex-1">
          <h3 className="text-lg font-bold text-gray-800">
            {user.displayName || user.username || 'Anonymous'}
          </h3>
          {user.username && (
            <p className="text-sm text-gray-600">@{user.username}</p>
          )}
          <p className="text-xs text-purple-600 font-mono mt-1">
            FID: {user.fid}
          </p>
        </div>

        {/* Farcaster Badge */}
        <div className="text-3xl">🐝</div>
      </div>

      {/* Additional Info */}
      {user.custodyAddress && (
        <div className="mt-4 pt-4 border-t border-purple-200">
          <p className="text-xs text-gray-500">Custody Address:</p>
          <p className="text-xs font-mono text-gray-700 truncate">
            {user.custodyAddress}
          </p>
        </div>
      )}
    </motion.div>
  )
}