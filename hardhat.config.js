require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("dotenv").config();

function getDeployAccounts(networkName) {
  if (networkName === "base" || networkName === "baseSepolia") {
    const pkRaw = process.env.PRIVATE_KEY || "";
    const pk = pkRaw.trim();
    const valid = /^0x[0-9a-fA-F]{64}$/.test(pk);
    if (!valid) {
      throw new Error(
        `\n❌ PRIVATE_KEY must be set as a valid 0x-prefixed (64 byte) hex string for deployments to ${networkName}.\nPlease configure PRIVATE_KEY in your .env file and never use a public/private test key on live networks.\n`
      );
    }
    return [pk];
  }
  return undefined; // Don't set accounts for local/dev, uses hardhat keys
}

const BASESCAN_API_KEY = process.env.BASESCAN_API_KEY || "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: false,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
      forking: { enabled: false },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    baseSepolia: {
      url: process.env.BASE_SEPOLIA_RPC_URL || "https://sepolia.base.org",
      accounts: getDeployAccounts("baseSepolia"),
      chainId: 84532,
      gasPrice: "auto",
    },
    base: {
      url: process.env.BASE_RPC_URL || "https://mainnet.base.org",
      accounts: getDeployAccounts("base"),
      chainId: 8453,
      gasPrice: "auto",
    },
  },
  etherscan: {
    apiKey: { baseSepolia: BASESCAN_API_KEY, base: BASESCAN_API_KEY },
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
    ],
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true",
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: { timeout: 200000 },
};
