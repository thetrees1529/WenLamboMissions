const contractAddress = require("./deployedAddress")
const name = "HARMOVILLE'S 1ST WENLAMBO CAR SHOW"
const config = require("./missionConfig.js")




async function main() {
    const missions = await hre.ethers.getContractAt("Missions", contractAddress)
    await (await missions.setMissionConfig(name, config)).wait()
}
main()