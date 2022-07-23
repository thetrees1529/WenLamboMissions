
const {walletAddr,lamboAddr,metadataAddr,toolboxes,garageManager} = require("./constants.json")[hre.network.name]
const location = "./outputs/deployedAddresses.json"
const deployedAddresses = require(location)
const fs = require("fs")
const path = require("path")
async function main() {
  const Missions = await hre.ethers.getContractFactory("Missions")
  const missions = await (await Missions.deploy(lamboAddr, walletAddr, metadataAddr, toolboxes, garageManager)).deployed()
  fs.writeFileSync(path.resolve(__dirname,location), JSON.stringify({...deployedAddresses, [hre.network.name]: missions.address}))
  console.log(`Deployed at ${missions.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
