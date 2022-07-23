
module.exports = {
    meta: JSON.stringify({
        name: "this is the name of the mission",
        missionDetails: "this is the mission details",
        rewardDetails: "this is the reward details",
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
                        stat: "example level",
                        value: 2
                },
                {
                        stat: "example level",
                        value: 1
                }
            ],
            requiredAttributes: [
                {
                        key: "example attribute",
                        value: "example value"
                    
                }
            ],
            minCompletions: [
                {
                        missionId: 1,
                        numberOf: 0
                    
                }
            ],
            nftBalanceRequirements: [
                {
                        nft: hre.ethers.constants.AddressZero,
                        numberOf: 1
                    
                }
            ],
            requiredGarageLevels: [
                {
                        /*
                            0 - pitcrew
                            1 - crewChief
                            2 - mechanic
                            3 -
                        */
                        attr: 0,
                        level: 2
                }
            ]
        }
    ],
    prizes: [

    ],
    entry: hre.ethers.utils.parseEther("10"),
    duration: 20 ,
    cooldown: 20,  
    reward: 
        {
            name: "default",
            items: {
                prize: hre.ethers.utils.parseEther("10"),
                nfts: [],
                pouches: [],
                toolboxes: 5
            }
        }
    ,
    maxCompletions: 1
}