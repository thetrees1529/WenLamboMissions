
const {walletAddr,lamboAddr,metadataAddr,toolboxes,garageManager} = require("./constants.json")[hre.network.name]

const fs = require("fs")
const path = require("path")
async function main() {
  const Missions = await hre.ethers.getContractFactory("Missions")
  const missions = await (await Missions.deploy(lamboAddr, walletAddr, metadataAddr, toolboxes, garageManager)).deployed()
  fs.writeFileSync(path.join(__dirname,"outputs/deployedAddress.json"), JSON.stringify(missions.address))
  console.log(`Deployed at ${missions.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
