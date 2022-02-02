const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Multisig sending transactions", function () {
  it("Should execute the multisig wallet", async function () {
    const accounts = await ethers.getSigners();
    const addresses = [];
    for (const account of accounts) {
      addresses.push(account.address);
    }

    const Multisig = await ethers.getContractFactory("Multisig");
    const multisig = await Multisig.deploy([addresses[0], addresses[1]], 2);
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
    const transactionid = await emitedArgs.transactionid.toNumber();
    //approving the transaction
    const firstApproval = await multisig
      .connect(owner)
      .approveTransaction(transactionid);
    await firstApproval.wait();

    const secondApproval = await multisig
      .connect(addr1)
      .approveTransaction(transactionid);
    await secondApproval.wait();

    // checking the total approval count
    expect(await multisig.getApprovalCount(transactionid)).to.equals(2);

    // executing the transaction
    let executeTransaction = await multisig
      .connect(addr2)
      .executeTransaction(transactionid, {
        value: ethers.utils.parseEther("1.0"),
      });
    executeTransaction = await executeTransaction.wait();
    expect(executeTransaction.status).to.equal(1);
  });
});
