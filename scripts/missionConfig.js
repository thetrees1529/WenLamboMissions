module.exports = {
    meta: JSON.stringify({
        name: "Test Mission - VIP Transport",
        missionDetails: " A high profile client has requested a speedy transfer to their private airport. They'd like a smooth ride, so your lambo needs some good shocks.",
        rewardDetails: "this is the reward details",
        bestPrizeDetails: "this is the details of the best prize",
        cooldownDetails: "this is the cooldown details",
        subtitle: "this is the subtitle",
        videoLocation: "/example/video/location",
        iconLocation: "/example/icon/location",
        tokenEntrySymbol: "JEWEL"
    }),
    requirements: [
        //ONLY ONE OF ANY OF THE ITEMS FROM ANY OF TEH ARRAYS FOR EACH OBJECT HAS TO BE MET.
        //FOR EXAMPLE TO ADD A REQUIREMENT FOR JUST TIRES 2,
        //YOU MUST POPULATE A NEW REQUIREMENT OBJECT WITH ALL THE EMPTY ARRAYS ALONGSIDE IT
        {
            minLevels: [
                {
                    stat: "handling",
                    value: 5
                }
            ],
            requiredAttributes: [
                {
                    key: "License Plate",
                    value: "WenLambo"
                }
            ],
           minCompletions: [
              //{
                  //missionId: 2,
                   //numberOf: 1
               //}
           ],
            nftBalanceRequirements: [
                //{
                    //nft: "0x976cEeE0d525780115E37325FD0CC3b8347b8fF1",
                    //numberOf: 0
                //}
            ],
           requiredGarageLevels: [
               //{
                    //0 - pitcrew,
                    //1 - crewChief,
                    //2 - mechanic,
                    //3 - gasman,
                    //4 - tireChanger
                   // attr: 3,
                    //level: 2
                //}
            ]
        },
        {
            minLevels: [
                {
                    stat: "handling",
                    value: 5
                }
            ],
            requiredAttributes: [
                {
                    key: "License Plate",
                    value: "WenLambo"
                }
            ],
           minCompletions: [
              //{
                  //missionId: 2,
                   //numberOf: 1
               //}
           ],
            nftBalanceRequirements: [
                //{
                    //nft: "0x976cEeE0d525780115E37325FD0CC3b8347b8fF1",
                    //numberOf: 0
                //}
            ],
           requiredGarageLevels: [
               //{
                    //0 - pitcrew,
                    //1 - crewChief,
                    //2 - mechanic,
                    //3 - gasman,
                    //4 - tireChanger
                   // attr: 3,
                    //level: 2
                //}
            ]
        },
    ],
    prizes: [
        {
            requirements: [],
            maxHits: ethers.constants.MaxUint256,
            weighting: 4,
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
                    toolboxes: 0
                }
            }
        },
        {
            requirements: [],
            maxHits: ethers.constants.MaxUint256,
            weighting: 4,
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
                    toolboxes: 0
                }
            }
        }
    ],
    entry: hre.ethers.utils.parseEther("0"),
    erc20Entries: [
        // {
        //     receiver: "0x782345aae234723742347...",
        //     pouch: {
        //         token: "erc20 token address",
        //         value: 69
        //     }
        // }
    ],
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