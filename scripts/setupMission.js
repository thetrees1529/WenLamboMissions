const contractAddress = require("./deployedAddress")
const name = "HARMOVILLE'S 1ST WENLAMBO CAR SHOW"
const config = {
    minLevels: [{minLevel:{stat:"tires",value: 2}}],
    minCompletions: [],
    nftBalanceRequirements: [],
    prizes: [],
    entry: hre.ethers.utils.parseEther("10"),
    duration: 60 * 60,
    cooldown: 60 * 60,
    reward: hre.ethers.utils.parseEther("170"),
    nftRewards: [],
    maxCompletions: 1
}




async function main() {
    const missions = await hre.ethers.getContractAt("Missions", contractAddress)
    await (await missions.setMissionConfig(name, config)).wait()
}
main()