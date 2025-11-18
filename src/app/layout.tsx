import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from '@/components/Providers'
import { FarcasterProvider } from '@/components/FarcasterProvider'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: '🥔 Potato Spin - Farcaster Mini App',
  description: 'Spin, earn, and grow your potato pet on Base blockchain!',
  manifest: '/.well-known/farcaster.json',
  icons: {
    icon: '/icon-192.png',
    apple: '/icon-512.png',
  },
  openGraph: {
    title: 'Potato Spin',
    description: 'Play-to-earn potato spinning game on Base',
    images: ['/og-image.png'],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Potato Spin',
    description: 'Play-to-earn potato spinning game on Base',
    images: ['/og-image.png'],
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <FarcasterProvider>
          <Providers>{children}</Providers>
        </FarcasterProvider>
      </body>
    </html>
  )
}