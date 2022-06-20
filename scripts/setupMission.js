const contractAddress = require("./deployedAddress")
const name = "HARMOVILLE'S 1ST WENLAMBO CAR SHOW"
const config = {
    minLevels: [{minLevel:{stat:"tires",value: 2}}],
    minCompletions: [],
    nftBalanceRequirements: [],
    prizes: [
        [[],1,"1st Place", 170,[]],
        [[],1,"2nd Place", 80,[]],
        [[],1,"3rd Place", 40,[]]
    ],
    entry: hre.ethers.utils.parseEther("10"),
    duration: 20 ,
    cooldown: 20 ,  
    reward: hre.ethers.utils.parseEther("10"),
    nftRewards: [],
    maxCompletions: 10
}




async function main() {
    const missions = await hre.ethers.getContractAt("Missions", contractAddress)
    await (await missions.setMissionConfig(name, config)).wait()
}
main()