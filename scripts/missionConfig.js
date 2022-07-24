
module.exports = {
    meta: JSON.stringify({
        name: "Transportation",
        missionDetails: " A high profile client has requested a speedy transfer to their private airport. They'd like a smooth ride, so your lambo needs some good shocks.",
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
                        stat: "Handling",
                        value: 2
                }
            ],
            requiredAttributes: [],
            minCompletions: [],
            nftBalanceRequirements: [],
            requiredGarageLevels: []
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
                        nfts: [],
                        pouches: [],
                        toolboxes: 0
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