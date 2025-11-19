// scripts/deploy.js
const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🥔 Starting Potato Spin Deployment...\n");
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString(), "\n");

  const deployments = {};
  const network = hre.network.name;

  // ============================================
  // STEP 1: Deploy PotatoToken (ERC20)
  // ============================================
  console.log("📝 Step 1: Deploying PotatoToken...");
  const PotatoToken = await hre.ethers.getContractFactory("PotatoToken");
  const potatoToken = await PotatoToken.deploy();
  await potatoToken.deployed();
  console.log("✅ PotatoToken deployed to:", potatoToken.address);
  deployments.PotatoToken = potatoToken.address;

  // ============================================
  // STEP 2: Deploy PotatoNFT (ERC1155)
  // ============================================
  console.log("\n📝 Step 2: Deploying PotatoNFT...");
  const PotatoNFT = await hre.ethers.getContractFactory("PotatoNFT");
  const potatoNFT = await PotatoNFT.deploy("https://potatospin.xyz/api/nft/{id}.json");
  await potatoNFT.deployed();
  console.log("✅ PotatoNFT deployed to:", potatoNFT.address);
  deployments.PotatoNFT = potatoNFT.address;

  // ============================================
  // STEP 3: Deploy PotatoSpinGame with VRF
  // ============================================
  console.log("\n📝 Step 3: Deploying PotatoSpinGame...");
  
  // VRF Configuration for Base Sepolia
  const VRF_COORDINATOR = process.env.CHAINLINK_VRF_COORDINATOR || "0x2D159aE3BFF84D20a3dC6277126F570224fA9623";
  const VRF_KEY_HASH = process.env.CHAINLINK_VRF_KEY_HASH || "0x7bb3c0c5e2f0e21dc24bc2d0e34fa31f8e77f7bbcf5c4bc8e8d7fc3b3c09d0f3";
  const VRF_SUBSCRIPTION_ID = process.env.CHAINLINK_VRF_SUBSCRIPTION_ID || 0;

  const PotatoSpinGame = await hre.ethers.getContractFactory("PotatoSpinGame");
  const potatoSpinGame = await PotatoSpinGame.deploy(
    potatoToken.address,
    potatoNFT.address,
    VRF_COORDINATOR,
    VRF_KEY_HASH,
    VRF_SUBSCRIPTION_ID
  );
  await potatoSpinGame.deployed();
  console.log("✅ PotatoSpinGame deployed to:", potatoSpinGame.address);
  deployments.PotatoSpinGame = potatoSpinGame.address;

  // ============================================
  // STEP 4: Deploy PotatoTasks
  // ============================================
  console.log("\n📝 Step 4: Deploying PotatoTasks...");
  const PotatoTasks = await hre.ethers.getContractFactory("PotatoTasks");
  const potatoTasks = await PotatoTasks.deploy(potatoToken.address);
  await potatoTasks.deployed();
  console.log("✅ PotatoTasks deployed to:", potatoTasks.address);
  deployments.PotatoTasks = potatoTasks.address;

  // ============================================
  // STEP 5: Deploy PotatoReferral
  // ============================================
  console.log("\n📝 Step 5: Deploying PotatoReferral...");
  const PotatoReferral = await hre.ethers.getContractFactory("PotatoReferral");
  const potatoReferral = await PotatoReferral.deploy(potatoToken.address);
  await potatoReferral.deployed();
  console.log("✅ PotatoReferral deployed to:", potatoReferral.address);
  deployments.PotatoReferral = potatoReferral.address;

  // ============================================
  // STEP 6: Deploy PotatoStaking (if exists)
  // ============================================
  try {
    console.log("\n📝 Step 6: Deploying PotatoStaking...");
    const PotatoStaking = await hre.ethers.getContractFactory("PotatoStaking");
    const potatoStaking = await PotatoStaking.deploy(potatoToken.address);
    await potatoStaking.deployed();
    console.log("✅ PotatoStaking deployed to:", potatoStaking.address);
    deployments.PotatoStaking = potatoStaking.address;
  } catch (error) {
    console.log("⚠️  PotatoStaking contract not found, skipping...");
  }

  // ============================================
  // STEP 7: Setup Connections Between Contracts
  // ============================================
  console.log("\n🔗 Step 7: Setting up contract connections...");

  // Grant minter role to Game contract
  console.log("   • Granting MINTER_ROLE to PotatoSpinGame...");
  const MINTER_ROLE = await potatoToken.MINTER_ROLE();
  await potatoToken.grantRole(MINTER_ROLE, potatoSpinGame.address);
  console.log("   ✅ Minter role granted");

  // Grant minter role to Tasks contract
  console.log("   • Granting MINTER_ROLE to PotatoTasks...");
  await potatoToken.grantRole(MINTER_ROLE, potatoTasks.address);
  console.log("   ✅ Minter role granted");

  // Grant minter role to Referral contract
  console.log("   • Granting MINTER_ROLE to PotatoReferral...");
  await potatoToken.grantRole(MINTER_ROLE, potatoReferral.address);
  console.log("   ✅ Minter role granted");

  // Set NFT minter
  console.log("   • Setting NFT minter to PotatoSpinGame...");
  await potatoNFT.setMinter(potatoSpinGame.address, true);
  console.log("   ✅ NFT minter set");

  // ============================================
  // STEP 8: Mint Initial Token Supply to Game
  // ============================================
  console.log("\n💰 Step 8: Minting initial token supply...");
  const INITIAL_SUPPLY = hre.ethers.utils.parseEther("40000000"); // 40M tokens for play-to-earn pool
  await potatoToken.mint(potatoSpinGame.address, INITIAL_SUPPLY);
  console.log("✅ Minted", hre.ethers.utils.formatEther(INITIAL_SUPPLY), "POTATO to Game contract");

  // Fund tasks contract
  const TASKS_SUPPLY = hre.ethers.utils.parseEther("10000000"); // 10M for tasks
  await potatoToken.mint(potatoTasks.address, TASKS_SUPPLY);
  console.log("✅ Minted", hre.ethers.utils.formatEther(TASKS_SUPPLY), "POTATO to Tasks contract");

  // Fund referral contract
  const REFERRAL_SUPPLY = hre.ethers.utils.parseEther("5000000"); // 5M for referrals
  await potatoToken.mint(potatoReferral.address, REFERRAL_SUPPLY);
  console.log("✅ Minted", hre.ethers.utils.formatEther(REFERRAL_SUPPLY), "POTATO to Referral contract");

  // ============================================
  // Save Deployment Addresses
  // ============================================
  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }

  const deploymentData = {
    network: network,
    chainId: (await hre.ethers.provider.getNetwork()).chainId,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: deployments,
    vrfConfig: {
      coordinator: VRF_COORDINATOR,
      keyHash: VRF_KEY_HASH,
      subscriptionId: VRF_SUBSCRIPTION_ID
    }
  };

  const filename = `${network}-${Date.now()}.json`;
  fs.writeFileSync(
    path.join(deploymentsDir, filename),
    JSON.stringify(deploymentData, null, 2)
  );
  console.log(`\n📄 Deployment data saved to deployments/${filename}`);

  // Save to .env format
  const envContent = `
# Deployment on ${network} at ${new Date().toISOString()}
NEXT_PUBLIC_POTATO_TOKEN_ADDRESS=${potatoToken.address}
NEXT_PUBLIC_GAME_CONTRACT_ADDRESS=${potatoSpinGame.address}
NEXT_PUBLIC_NFT_CONTRACT_ADDRESS=${potatoNFT.address}
NEXT_PUBLIC_TASKS_CONTRACT_ADDRESS=${potatoTasks.address}
NEXT_PUBLIC_REFERRAL_CONTRACT_ADDRESS=${potatoReferral.address}
${deployments.PotatoStaking ? `NEXT_PUBLIC_STAKING_CONTRACT_ADDRESS=${deployments.PotatoStaking}` : ''}
`;

  fs.writeFileSync(
    path.join(deploymentsDir, `${network}.env`),
    envContent
  );
  console.log(`✅ Environment variables saved to deployments/${network}.env`);

  // ============================================
  // Verify Contracts on BaseScan
  // ============================================
  if (network !== "localhost" && network !== "hardhat") {
    console.log("\n🔍 Starting contract verification...");
    console.log("⏳ Waiting 30 seconds for Etherscan to index...");
    await new Promise(resolve => setTimeout(resolve, 30000));

    await verifyContract("PotatoToken", potatoToken.address, []);
    await verifyContract("PotatoNFT", potatoNFT.address, ["https://potatospin.xyz/api/nft/{id}.json"]);
    await verifyContract("PotatoSpinGame", potatoSpinGame.address, [
      potatoToken.address,
      potatoNFT.address,
      VRF_COORDINATOR,
      VRF_KEY_HASH,
      VRF_SUBSCRIPTION_ID
    ]);
    await verifyContract("PotatoTasks", potatoTasks.address, [potatoToken.address]);
    await verifyContract("PotatoReferral", potatoReferral.address, [potatoToken.address]);
    
    if (deployments.PotatoStaking) {
      await verifyContract("PotatoStaking", deployments.PotatoStaking, [potatoToken.address]);
    }
  }

  console.log("\n✨ Deployment Complete! ✨\n");
  console.log("📋 Summary:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  Object.entries(deployments).forEach(([name, address]) => {
    console.log(`${name}: ${address}`);
  });
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  console.log("🔗 Next Steps:");
  console.log("1. Add VRF subscription consumer:", potatoSpinGame.address);
  console.log("2. Update .env file with contract addresses");
  console.log("3. Create initial tasks in PotatoTasks contract");
  console.log("4. Setup The Graph subgraph");
  console.log("5. Test on testnet before mainnet deployment\n");
}

async function verifyContract(name, address, constructorArgs) {
  console.log(`\n   Verifying ${name}...`);
  try {
    await hre.run("verify:verify", {
      address: address,
      constructorArguments: constructorArgs,
    });
    console.log(`   ✅ ${name} verified`);
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log(`   ℹ️  ${name} already verified`);
    } else {
      console.log(`   ❌ ${name} verification failed:`, error.message);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });