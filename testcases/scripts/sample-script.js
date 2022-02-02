// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const addresses = [];
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Multisig = await hre.ethers.getContractFactory("Multisig");
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    addresses.push(account.address);
  }
  const ownerAccounts = [addresses[0], addresses[1]];
  const multisig = await Multisig.deploy(ownerAccounts, ownerAccounts.length);
  await multisig.deployed();
  console.log("Multisig contract deployed on address:", multisig.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
