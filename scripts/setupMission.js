const contractAddress = require("./deployedAddress")
const name = "HARMOVILLE'S 1ST WENLAMBO CAR SHOW"
const config = {
minLevels: [{minLevel:{stat:"tires",value: 2}}],
    description: JSON.stringify({
        missionDetails: "this is the mission details",
        rewardDetails: "this is the reward details",
        cooldownDetails: "this is the cooldown details",
        subtitle: "this is the subtitle"
    }),
    minCompletions: [],
    nftBalanceRequirements: [],
    prizes: [
        {
            unlockLevels: [],
            weighting: 1,
            name: "1st Place",
            prize: hre.ethers.utils.parseEther("170"),
            nfts: []
        },
        {
            unlockLevels: [],
            weighting: 1,
            name: "2nd Place",
            prize: hre.ethers.utils.parseEther("80"),
            nfts: []
        },
        {
            unlockLevels: [],
            weighting: 1,
            name: "3rd Place",
            prize: hre.ethers.utils.parseEther("40"),
            nfts: []
        }
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