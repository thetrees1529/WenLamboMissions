const config = {
    minLevels: [{minLevel:{stat:"tires",value: 2}}],
    description: JSON.stringify({
        missionDetails: "this is the mission details",
        rewardDetails: "this is the reward details",
        cooldownDetails: "this is the cooldown details",
        subtitle: "this is the subtitle",
        videoLocation: "/example/video/location",
        iconLocation: "/example/icon/location"
    }),
    requiredAttributes: [
        // {
        //     requiredAttribute: {
        //         key: "Charm",
        //         value: "Engine"
        //     }
        // }
    ],
    minCompletions: [
        // {
        //     minCompletions: {
        //         mission: "nonexistent mission",
        //         numberOf: 0
        //     }
        // }
    ],
    nftBalanceRequirements: [
        // {
        //     nftBalanceRequirement: {
        //         nft: hre.ethers.constants.AddressZero,
        //         numberOf: 0
        //     }
        // }
    ],
    prizes: [
        {
            unlockLevels: [],
            weighting: 1,
            name: "1st Place",
            prize: hre.ethers.utils.parseEther("170"),
            nfts: [],
            toolboxes: 0,
            requiredAttributes: [
                // {
                //     requiredAttribute: {
                //         key: "Charm",
                //         value: "Engine"
                //     }
                // }
            ]
        },
        {
            unlockLevels: [],
            weighting: 1,
            name: "2nd Place",
            prize: hre.ethers.utils.parseEther("80"),
            nfts: [],
            toolboxes: 0,
            requiredAttributes: [
                // {
                //     requiredAttribute: {
                //         key: "Charm",
                //         value: "Engine"
                //     }
                // }
            ]
        },
        {
            unlockLevels: [],
            weighting: 1,
            name: "3rd Place",
            prize: hre.ethers.utils.parseEther("40"),
            nfts: [],
            toolboxes: 0,
            requiredAttributes: [
                // {
                //     requiredAttribute: {
                //         key: "Charm",
                //         value: "Engine"
                //     }
                // }
            ]
        }
    ],
    entry: hre.ethers.utils.parseEther("10"),
    duration: 20 ,
    cooldown: 20 ,  
    reward: hre.ethers.utils.parseEther("10"),
    nftRewards: [],
    toolboxRewards: 1,
    maxCompletions: 10
}

console.log(JSON.stringify(config))