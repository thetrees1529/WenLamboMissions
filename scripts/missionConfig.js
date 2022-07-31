module.exports = {
    meta: JSON.stringify({
        name: "VIP Transport",
        missionDetails: " A high profile client has requested a speedy transfer to their private airport. They'd like a smooth ride, so your lambo needs some good shocks.",
        rewardDetails: "Tips will be given for those good drivers. Get your VIP to the airport smooth and safe. He will tip you with a reward.",
        bestPrizeDetails: "Top Tip 200 HVILLE for this mission",
        cooldownDetails: "Your Lambo will be required to cool down for 2 hours before trying this mission again.",
        subtitle: "Get the VIP to the airport on time and get a big tip.",
        videoLocation: { type: "video", path: "https://storageapi.fleek.co/c607c1dc-cdb6-453f-ab3e-9e0b1c8a1cd9-bucket/videos/03-cutscene-vip.mp4" },
        iconLocation: "https://storageapi.fleek.co/c607c1dc-cdb6-453f-ab3e-9e0b1c8a1cd9-bucket/icons/03-icon-vip.png",
        tokenEntrySymbol: "HVILLE"
    }),
    requirements: [
        //ONLY ONE OF ANY OF THE ITEMS FROM ANY OF TEH ARRAYS FOR EACH OBJECT HAS TO BE MET.
        //FOR EXAMPLE TO ADD A REQUIREMENT FOR JUST TIRES 2,
        //YOU MUST POPULATE A NEW REQUIREMENT OBJECT WITH ALL THE EMPTY ARRAYS ALONGSIDE IT
        {
            minLevels: [
                {
                    stat: "handling",
                    value: 4
                }
            ],
            requiredAttributes: [
                //{
                    //key: "License Plate",
                    //value: "WenLambo"
                //}
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
                //{
                    //stat: "handling",
                    //value: 5
                //}
            ],
            requiredAttributes: [
                //{
                    //key: "License Plate",
                    //value: "WenLambo"
                //}
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
            weighting: 5,
            prize: {
                name: "Great job! Big Tip!",
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
            weighting: 15,
            prize: {
                name: "3 Stars, Better luck next time",
                items: {
                    prize: ethers.utils.parseEther("75"),
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
            weighting: 15,
            prize: {
                name: "Not Hiring you again",
                items: {
                    prize: ethers.utils.parseEther("25"),
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
            weighting: 17,
            prize: {
                name: "Take your money back!",
                items: {
                    prize: ethers.utils.parseEther("50"),
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
    entry: hre.ethers.utils.parseEther("50"),
    erc20Entries: [
        // {
        //     receiver: "0x782345aae234723742347...",
        //     pouch: {
        //         token: "erc20 token address",
        //         value: 69
        //     }
        // }
    ],
    duration: 14400 ,
    cooldown: 7200,
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
    maxCompletions: 10
}