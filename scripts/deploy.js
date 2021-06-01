const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")
const fs = require("fs-extra")

function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms)
	})
}
async function main() {
	fs.removeSync("cache")
	fs.removeSync("artifacts")
	await hre.run("compile")

	// We get the contract to deploy
	const Factory = await hre.ethers.getContractFactory("ECoinFactory")

	let network = process.env.NETWORK ? process.env.NETWORK : "rinkeby"
	console.log("Deploying Contract >-> Network is set to " + network)

	const [deployer] = await ethers.getSigners()
	const deployerAddress = await deployer.getAddress()
	const account = await web3.utils.toChecksumAddress(deployerAddress)
	const balance = await web3.eth.getBalance(account)

	console.log(deployerAddress + " has: " + web3.utils.fromWei(balance, "ether"), "ETH")

	const deployed = await Factory.deploy() //no constructor args
	let dep = await deployed.deployed()

	console.log("Contract deployed to >-> ", dep.address)

	if (network === "matic" || network === "matic_test") {
		console.log("on matic..verify contracts manually")
		return
	}
	let sleepTime = 600000 //10min sleep
	if (network !== "mainnet") {
		sleepTime = 30000 //30 seconds sleep
	}

	await sleep(sleepTime)
	await hre.run("verify:verify", {
		address: dep.address,
		constructorArguments: [],
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
