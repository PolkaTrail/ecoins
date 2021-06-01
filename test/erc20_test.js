const { expect } = require("chai")
const { ethers } = require("hardhat")
const { time, balance } = require("@openzeppelin/test-helpers")

let trail
let owner, acc1, acc2

describe("Deploy TheToken", function () {
	beforeEach(async function () {
		let TrailContract = await ethers.getContractFactory("TheToken")

		signers = await ethers.getSigners()
		owner = signers[0]
		acc1 = signers[1]
		acc2 = signers[2]
		trail = await TrailContract.deploy()
		await trail.deployed()
	})

	it("Deployment should assign the total supply of tokens to the owner", async function () {
		const ownerBalance = await trail.balanceOf(owner.address)
		expect(await trail.totalSupply()).to.equal(ownerBalance)
	})

	it("Should transfer tokens between accounts", async function () {
		// Transfer 50 tokens from owner to addr1
		await trail.transfer(acc1.address, 50)
		expect(await trail.balanceOf(acc1.address)).to.equal(50)

		// Transfer 50 tokens from addr1 to addr2
		await trail.connect(acc1).transfer(acc2.address, 50)
		expect(await trail.balanceOf(acc2.address)).to.equal(50)
	})

	it("Should transfer accidentally sent ERC20 tokens to this contract", async function () {
		//deploy an erc20 token for
		let ERC20MockContract = await ethers.getContractFactory("ERC20Mock")
		erc20 = await ERC20MockContract.connect(acc1).deploy("ERCToken", "ERC", "10000")
		await erc20.deployed()

		// Transfer some tokens to this contract
		await erc20.connect(acc1).transfer(trail.address, 100)
		expect(await erc20.balanceOf(trail.address)).to.equal(100)
		expect(await erc20.balanceOf(owner.address)).to.equal(0)

		// get them
		await trail.reclaimToken(erc20.address)
		expect(await erc20.balanceOf(owner.address)).to.equal(100)
	})
})
