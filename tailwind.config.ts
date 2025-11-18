import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        potato: {
          50: '#fef9ee',
          100: '#fef3d6',
          200: '#fce5ad',
          300: '#fad079',
          400: '#f7b143',
          500: '#f59719',
          600: '#e67d0f',
          700: '#bf5f0f',
          800: '#984c13',
          900: '#7c3f13',
        },
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'bounce-slow': 'bounce 2s infinite',
        'pulse-glow': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
    },
  },
  plugins: [],
}
export default config