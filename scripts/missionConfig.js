module.exports = {
    description: JSON.stringify({
        missionDetails: "this is the mission details",
        rewardDetails: "this is the reward details",
        cooldownDetails: "this is the cooldown details",
        subtitle: "this is the subtitle",
        videoLocation: "/example/video/location",
        iconLocation: "/example/icon/location"
    }),
    requirements: [
        {
            minLevels: [
                {
                    minLevel: {
                        stat: "example level",
                        value: 2
                    }
                }
            ],
            requiredAttributes: [
                {
                    requiredAttribute: {
                        key: "example attribute",
                        value: "example value"
                    }
                }
            ],
            minCompletions: [
                {
                    minCompletions: {
                        mission: "example mission",
                        numberOf: 4
                    }
                }
            ],
            nftBalanceRequirements: [
                {
                    nftBalanceRequirement: {
                        nft: hre.ethers.constants.AddressZero,
                        numberOf: 1
                    }
                }
            ],
            requiredGarageLevels: [
                {
                    requiredGarageLevel: {
                        attr: 0,
                        level: 2
                    }
                }
            ]
        }
    ],
    prizes: [
        {
            weighting: 1,
            name: "1st Place",
            prize: hre.ethers.utils.parseEther("170"),
            nfts: [],
            toolboxes: 0,
            requirements: []
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