const hville = "0xF0c092c4b9FeD9c8A697f9fC8379B7b1CC76BEf6"


const fs = require("fs")
const path = require("path")
const {ethers} = hre
async function main() {
    const TempVault = await ethers.getContractFactory("TempVault")
    const tempVault = await (await TempVault.deploy(hville)).deployed()
    fs.writeFileSync(path.join(__dirname, "deployedTempVaultAddress.json"), JSON.stringify(tempVault.address))
    console.log(`Deployed at ${tempVault.address}`)
}
main()