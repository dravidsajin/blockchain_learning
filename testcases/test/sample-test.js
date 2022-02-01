const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  // it("Should return the new greeting once it's changed", async function () {
  //   const Greeter = await ethers.getContractFactory("Greeter");
  //   const greeter = await Greeter.deploy("Hello, world!");
  //   await greeter.deployed();
  //   expect(await greeter.greet()).to.equal("Hello, world!");
  //   const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
  //   // wait until the transaction is mined
  //   await setGreetingTx.wait();
  //   expect(await greeter.greet()).to.equal("Hola, mundo!");
  //   // setting string from second account
  //   const [owner, addr1, addr2] = await ethers.getSigners();
  //   const setGreetingTxNew = await greeter
  //     .connect(addr1)
  //     .setGreeting("Dravid, sajin!");
  //   await setGreetingTxNew.wait();
  //   expect(await greeter.greet()).to.equal("Dravid, sajin!");
  //   expect(await greeter.greet()).to.equal("Dravid, sajin!");
  // });
});

describe("Multisig sending transactions", function () {
  it("Should execute the multisig wallet", async function () {
    const accounts = await ethers.getSigners();
    const addresses = [];
    for (const account of accounts) {
      addresses.push(account.address);
    }

    const Multisig = await ethers.getContractFactory("Multisig");
    const multisig = await Multisig.deploy(
      [
        addresses[0] || "0x11B3AEf34A001c57063C150cC452016512f259Cc",
        addresses[1] || "0x5810e7e21ea7d71a5c11e752ff04d73ceA8E2F1a",
      ],
      2
    );
    await multisig.deployed();

    // checking the approver length
    const approvercount = await multisig.getApproversCount();
    expect(approvercount).to.equal(2);

    // submitting the transaction
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
    let submitTransaction = await multisig
      .connect(addr2)
      .submitTransaction(addresses[2], addresses[3], 1);
    submitTransaction = await submitTransaction.wait();
    const emitedArgs = await submitTransaction.events[0].args;
    const transactionid = emitedArgs["transactionid"].toNumber();

    //approving the transaction
    await multisig.connect(owner).approveTransaction(transactionid);
    await multisig.connect(addr1).approveTransaction(transactionid);

    // checking the total approval count
    expect(await multisig.getApprovalCount(transactionid)).to.equals(2);

    // executing the transaction
    let executeTransaction = await multisig
      .connect(addr2)
      .executeTransaction(transactionid, {
        value: ethers.utils.parseEther("1.0"),
      });
    executeTransaction = await executeTransaction.wait();
    expect(executeTransaction.confirmations).to.equal(1);
  });
});
