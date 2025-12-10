const hre = require("hardhat");

async function main() {
  const [owner, nominee] = await hre.ethers.getSigners();

  console.log("Owner:", owner.address);
  console.log("Nominee:", nominee.address);

  // For demo: 120 seconds = 2 minutes heartbeat interval
  const heartbeatInterval = 120;

  const InheritanceVault = await hre.ethers.getContractFactory("InheritanceVault");

  const vault = await InheritanceVault.deploy(
    nominee.address,
    heartbeatInterval,
    { value: hre.ethers.parseEther("1.0") } // deposit 1 test ETH
  );

  await vault.waitForDeployment();

  const addr = await vault.getAddress();
  console.log("InheritanceVault deployed at:", addr);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
