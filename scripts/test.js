const contractAddress = require("./outputs/deployedAddresses")[hre.network.name]
const {ethers} = hre
const tokenId = 17
const multicallAddr = "0x7093275e4CF772977e3bAd5614dBb9361c39c5B2"
const abi = ["function aggregate(tuple(address target, bytes callData)[] memory calls) external view returns (uint256 blockNumber, bytes[] memory returnData)"]

async function main() {
    const missions = await ethers.getContractAt("Missions", contractAddress)
    const multicall = await ethers.getContractAt(abi, multicallAddr)
    const entriesLength = await missions.getLamboEntriesLength(tokenId)
    const decodedInputs = Array.from(Array(Number(entriesLength)).keys())
    const inputs = decodedInputs.map(input => ({
        target: missions.address,
        callData: missions.interface.encodeFunctionData("getLamboEntry", [tokenId, input])
    }))
    const encodedResponses = (await multicall.aggregate(inputs)).returnData
    const decodedResponses = encodedResponses.map(res => missions.interface.decodeFunctionResult("getLamboEntry", res))
    console.log(JSON.stringify(decodedResponses))
}
main()

