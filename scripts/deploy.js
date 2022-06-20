
const walletAddr = "0x1A0b497A650fE94B72AeC42009F03F074ee6cdce"
const lamboAddr = "0x976cEeE0d525780115E37325FD0CC3b8347b8fF1"
const fs = require("fs")
const path = require("path")
async function main() {
  const Missions = await hre.ethers.getContractFactory("Missions")
  const missions = await (await Missions.deploy(lamboAddr, walletAddr)).deployed()
  fs.writeFileSync(path.join(__dirname, "deployedAddress.json"), JSON.stringify(missions.address))
  console.log(`Deployed at ${missions.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
