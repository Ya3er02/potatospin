const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("PotatoToken", function () {
  async function deployTokenFixture() {
    const [owner, addr1, addr2, minter, burner] = await ethers.getSigners();

    const PotatoToken = await ethers.getContractFactory("PotatoToken");
    const token = await PotatoToken.deploy();

    const MINTER_ROLE = await token.MINTER_ROLE();
    const BURNER_ROLE = await token.BURNER_ROLE();
    const PAUSER_ROLE = await token.PAUSER_ROLE();

    return { token, owner, addr1, addr2, minter, burner, MINTER_ROLE, BURNER_ROLE, PAUSER_ROLE };
  }

  describe("Deployment", function () {
    it("Should set the right name and symbol", async function () {
      const { token } = await loadFixture(deployTokenFixture);
      expect(await token.name()).to.equal("Potato Token");
      expect(await token.symbol()).to.equal("POTATO");
    });

    it("Should mint initial supply to owner", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);
      const initialSupply = ethers.parseEther("100000000"); // 100M
      expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
    });

    it("Should grant DEFAULT_ADMIN_ROLE to owner", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);
      const DEFAULT_ADMIN_ROLE = await token.DEFAULT_ADMIN_ROLE();
      expect(await token.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.be.true;
    });
  });

  describe("Minting", function () {
    it("Should allow MINTER_ROLE to mint tokens", async function () {
      const { token, owner, addr1 } = await loadFixture(deployTokenFixture);
      const amount = ethers.parseEther("1000");
      
      await expect(token.mint(addr1.address, amount))
        .to.emit(token, "TokensMinted")
        .withArgs(addr1.address, amount, owner.address);
        
      expect(await token.balanceOf(addr1.address)).to.equal(amount);
    });

    it("Should reject minting to zero address", async function () {
      const { token } = await loadFixture(deployTokenFixture);
      const amount = ethers.parseEther("1000");
      
      await expect(token.mint(ethers.ZeroAddress, amount))
        .to.be.revertedWith("PotatoToken: Cannot mint to zero address");
    });

    it("Should reject minting above MAX_SUPPLY", async function () {
      const { token, addr1 } = await loadFixture(deployTokenFixture);
      const maxSupply = ethers.parseEther("1000000000"); // 1B
      const currentSupply = await token.totalSupply();
      const excessAmount = maxSupply - currentSupply + ethers.parseEther("1");
      
      await expect(token.mint(addr1.address, excessAmount))
        .to.be.revertedWith("PotatoToken: Exceeds max supply");
    });

    it("Should reject non-MINTER_ROLE from minting", async function () {
      const { token, addr1, addr2 } = await loadFixture(deployTokenFixture);
      const amount = ethers.parseEther("1000");
      
      await expect(token.connect(addr1).mint(addr2.address, amount))
        .to.be.reverted;
    });
  });

  describe("Burning", function () {
    it("Should allow users to burn their own tokens", async function () {
      const { token, owner, addr1 } = await loadFixture(deployTokenFixture);
      const mintAmount = ethers.parseEther("1000");
      const burnAmount = ethers.parseEther("500");
      
      await token.mint(addr1.address, mintAmount);
      await expect(token.connect(addr1).burn(burnAmount))
        .to.emit(token, "TokensBurned")
        .withArgs(addr1.address, burnAmount, addr1.address);
        
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount - burnAmount);
    });

    it("Should allow BURNER_ROLE to burn from any address", async function () {
      const { token, owner, addr1, BURNER_ROLE } = await loadFixture(deployTokenFixture);
      const mintAmount = ethers.parseEther("1000");
      const burnAmount = ethers.parseEther("500");
      
      await token.mint(addr1.address, mintAmount);
      await token.grantRole(BURNER_ROLE, owner.address);
      
      // Approve burner
      await token.connect(addr1).approve(owner.address, burnAmount);
      
      await expect(token.burnFrom(addr1.address, burnAmount))
        .to.emit(token, "TokensBurned");
        
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount - burnAmount);
    });

    it("Should reject burning zero amount", async function () {
      const { token, addr1 } = await loadFixture(deployTokenFixture);
      
      await expect(token.connect(addr1).burn(0))
        .to.be.revertedWith("PotatoToken: Amount must be greater than zero");
    });
  });

  describe("Pausable", function () {
    it("Should pause and unpause transfers", async function () {
      const { token, owner, addr1 } = await loadFixture(deployTokenFixture);
      const amount = ethers.parseEther("100");
      
      await token.pause();
      
      await expect(token.transfer(addr1.address, amount))
        .to.be.reverted;
        
      await token.unpause();
      
      await expect(token.transfer(addr1.address, amount))
        .to.not.be.reverted;
    });

    it("Should emit events on pause/unpause", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);
      
      await expect(token.pause())
        .to.emit(token, "EmergencyPaused")
        .withArgs(owner.address);
        
      await expect(token.unpause())
        .to.emit(token, "EmergencyUnpaused")
        .withArgs(owner.address);
    });
  });

  describe("Access Control", function () {
    it("Should allow admin to grant roles", async function () {
      const { token, owner, minter, MINTER_ROLE } = await loadFixture(deployTokenFixture);
      
      await token.grantRole(MINTER_ROLE, minter.address);
      expect(await token.hasRole(MINTER_ROLE, minter.address)).to.be.true;
    });

    it("Should allow role holders to perform their functions", async function () {
      const { token, minter, addr1, MINTER_ROLE } = await loadFixture(deployTokenFixture);
      
      await token.grantRole(MINTER_ROLE, minter.address);
      
      const amount = ethers.parseEther("1000");
      await expect(token.connect(minter).mint(addr1.address, amount))
        .to.not.be.reverted;
    });
  });
});
