
const walletAddr = "0x3e39AC7418f3eF23dED3Ec42608D6de6750E8245"
const lamboAddr = "0xfC72c4bb047d6Ab9f31e7d66268BCc6a116c11c4"

async function main() {
  const Missions = await hre.ethers.getContractFactory("Missions")
  const missions = await (await Missions.deploy(lamboAddr, walletAddr)).deployed()
  console.log(missions.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
