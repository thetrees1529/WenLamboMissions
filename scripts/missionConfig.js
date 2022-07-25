
module.exports = {
    meta: JSON.stringify({
        name: "Transportation",
        missionDetails: " A high profile client has requested a speedy transfer to their private airport. They'd like a smooth ride, so your lambo needs some good shocks.",
        rewardDetails: "this is the reward details",
        bestRewardDetails: "this is the details of the best reward",
        cooldownDetails: "this is the cooldown details",
        subtitle: "this is the subtitle",
        videoLocation: "/example/video/location",
        iconLocation: "/example/icon/location"
    }),
    requirements: [
        //ONLY ONE OF ANY OF THE ITEMS FROM ANY OF TEH ARRAYS FOR EACH OBJECT HAS TO BE MET.
        //FOR EXAMPLE TO ADD A REQUIREMENT FOR JUST TIRES 2,
        //YOU MUST POPULATE A NEW REQUIREMENT OBJECT WITH ALL THE EMPTY ARRAYS ALONGSIDE IT
        {
            minLevels: [
                {
                    stat: "handling",
                    value: 2
                }
            ],
            requiredAttributes: [
                {
                    key: "example metadata attribute",
                    value: "example metadata value"
                }
            ],
            minCompletions: [
                {
                    missionId: 2,
                    numberOf: 1
                }
            ],
            nftBalanceRequirements: [
                {
                    nft: "0x976cEeE0d525780115E37325FD0CC3b8347b8fF1",
                    numberOf: 0
                }
            ],
            requiredGarageLevels: [
                {
                    //0 - pitcrew,
                    //1 - crewChief,
                    //2 - mechanic,
                    //3 - gasman,
                    //4 - tireChanger
                    attr: 3,
                    level: 2
                }
            ]
        }
    ],
    prizes: [
        {
            requirements: [],
            maxHits: ethers.constants.MaxUint256,
            prizeOption: {
                weighting: 1,
                prize: {
                    name: "Great job",
                    items: {
                        prize: ethers.utils.parseEther("200"),
                        nfts: [
                            // {
                            //     nftReward: {
                            //         collection: "nft collection address",
                            //         numberOf: 1
                            //     },
                            //     holder: "address to transfer nft from when won."
                            // }
                        ],
                        pouches: [
                            // {
                            //     pouch: {
                            //         token: "erc20 address",
                            //         value: 2
                            //     },
                            //     holder: "address to transfer tokens from"
                            // }
                        ],
                        toolboxes: 3
                    }
                }
                
            }
        }
    ],
    entry: hre.ethers.utils.parseEther("50"),
    duration: 20 ,
    cooldown: 20,  
    reward: 
        {
            name: "",
            items: {
                prize: 0,
                nfts: [],
                pouches: [],
                toolboxes: 0
            }
        }
    ,
    maxCompletions: 1
}