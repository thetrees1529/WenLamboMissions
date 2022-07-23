const contractAddress = require("./outputs/deployedAddress")
const config = require("./missionConfig.js")


async function main() {
    const missions = await hre.ethers.getContractAt("Missions", contractAddress)
    await (await missions.createMission(config)).wait()
}

main()