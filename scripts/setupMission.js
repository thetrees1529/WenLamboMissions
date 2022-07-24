const contractAddress = require("./outputs/deployedAddresses")[hre.network.name]
const config = require("./missionConfig.js")


async function main() {
    const missions = await hre.ethers.getContractAt("Missions", contractAddress)
    await (await missions.createMission(config)).wait()
}

main()