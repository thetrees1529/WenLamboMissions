

//DEPRECATED





// const chai = require("chai")
// const chaiAsPromised = require("chai-as-promised")
// chai.use(chaiAsPromised)
// const { assert } = chai
// const hre = require("hardhat")

// describe("Missions tests", () => {

//     const testLambo = 1

//     const testMission = {
//         name: "test",
//         config: {
//             dependentMissions: [],
//             requirements: [],
//             nftRequirements: [],
//             entryPrice: 0,
//             maxLifetime: 2,
//             cooldown: 10,
//             fixedPrize: 100,
//             prizeChart: ["", []],
//             length: 10,
//             fixedNftReward: hre.ethers.constants.AddressZero
//         }
//     }

//     let lambos
//     let hville
//     let missions
//     let signer
//     let address
    
//     before(async () => {

//         signer = await hre.ethers.getSigner()
//         address = await signer.getAddress()

//         const Hville = await hre.ethers.getContractFactory("FakeHarmonyville")
//         hville = await (await Hville.deploy()).deployed()

//         const Lambos = await hre.ethers.getContractFactory("FakeLambos")
//         lambos = await (await Lambos.deploy()).deployed()

//         const Missions = await hre.ethers.getContractFactory("Missions")
//         missions = await (await Missions.deploy(lambos.address, hville.address)).deployed()

//         await (await missions.setMissionConfig(testMission.name, testMission.config)).wait()
        
//     })

//     it("shouldn't be possible to join a mission while it is in progress", async () => {

//         await (await missions.enterMission(testLambo,testMission.name)).wait()
//         await assert.isRejected(missions.enterMission(testLambo, testMission.name))

//     })

//     it("shouldn't be possible to end a mission while it is in progress", async () => {

//         await assert.isRejected(missions.endMission(testLambo))

//     })

//     it("should set the current mission to the one entered", async () =>{

//         assert.equal(await missions.getCurrentMission(testLambo), testMission.name)

//     })


//     let balanceBefore

//     it("should be possible to end mission after it is over", async() => {

//         balanceBefore = await hville.balanceOf(address)
//         const end = await missions.getCurrentMissionEnd(testLambo)
//         await signer.provider.send("evm_mine", [end.toNumber()])
//         await (await missions.endMission(testLambo)).wait()

//     })

//     it("should transfer the correct amount to the player", async () => {
//         const balanceAfter = await hville.balanceOf(address)
//         assert.equal(balanceAfter, balanceBefore.toNumber() + testMission.config.fixedPrize)
//     })

//     it("shouldn't be possible to join a mission while there is a cooldown", async () => {

//         await assert.isRejected(missions.enterMission(testLambo, testMission.name))

//     })

//     it("shouldn't be possible to end a mission while there is a cooldown", async () => {

//         await assert.isRejected(missions.endMission(testLambo))

//     })

//     it("should be possible to join another mission after the cooldown is over", async() => {

//         const cooldownEnd = await missions.getCooldownEnd(testLambo)
//         await signer.provider.send("evm_mine", [cooldownEnd.toNumber()])
//         await assert.isFulfilled(missions.enterMission(testLambo, testMission.name))
//         const missionEnd = await missions.getCurrentMissionEnd(testLambo)
//         await signer.provider.send("evm_mine", [missionEnd.toNumber()])
//         await (await missions.endMission(testLambo)).wait()

//     })

//     it("shouldn't be possible to join a mission more times than the maximum", async () => {

//         const numberOfCompletions = await missions.getMissionHistoryLength(testLambo, testMission.name)
//         assert.equal(numberOfCompletions, testMission.config.maxLifetime, "Make sure I have entered enough missions to test this")
//         await assert.isRejected(missions.enterMission(testLambo,testMission.name))

//     })

// })