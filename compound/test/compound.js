const { eth } = require("@compound-finance/compound-js");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { DAI, cDAI } = require("./abi/dai.json").Abi;

describe("Compound protocol deployment", function () {
  const daiToken = "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa";
  const cDaiToken = "0x6D7F0754FFeb405d23C51CE938289d4835bE3b14";
  const batToken = "0xbF7A7169562078c96f0eC1A8aFD6aE50f12e5A99";
  const cBatToken = "0xEBf1A11532b93a529b5bC942B4bAA98647913002";
  const comptroller = "0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb";

  it("deploying the compound contract", async function () {
    /* fetching the owner address */
    const [ownerInst] = await ethers.getSigners();
    const ownerAddress = ownerInst.address;

    /* creating token instance */
    const daiInstance = await new web3.eth.Contract(DAI, daiToken);
    const daiDecimals = await daiInstance.methods.decimals().call(); // fetching decimals
    const cDaiInstance = await new web3.eth.Contract(cDAI, cDaiToken);
    const supplyAmount = 1 * Math.pow(10, daiDecimals);
    const supplyAmountInHex = await web3.utils.toHex(supplyAmount); // calculating amount to transfer
    /* deploying the contract */
    const Compound = await ethers.getContractFactory("compound");
    const dCompound = await Compound.deploy(
      daiToken,
      cDaiToken,
      batToken,
      cBatToken,
      comptroller
    );
    await dCompound.deployed();
    const compoundAddress = dCompound.address;
    console.log("===compound protocol deployed on===", compoundAddress);

    /* transferring amount from user account to contract */
    const transferData = await daiInstance.methods
      .transfer(compoundAddress, supplyAmountInHex)
      .send({
        from: ownerAddress,
        gasLimit: web3.utils.toHex(500000),
      });
    console.log("===transferdata===", transferData);
    console.log(
      `transferred ${supplyAmountInHex} of Dai to ${compoundAddress}`
    );

    /* investing amount to compound protocol */
    const invest = await dCompound.invest(supplyAmountInHex, {
      from: ownerAddress,
      gasLimit: 1000000,
    });
    await invest.wait();

    /* fetching the ctoken balance */
    let balance = await dCompound.getBalance();
    console.log("==balance==", balance);

    /* fetching the underlying balance */
    // const underlyingbalance = await dCompound.fetchUnderlying();
    const underlyingbalance = await cDaiInstance.methods
      .balanceOfUnderlying(compoundAddress)
      .call();
    console.log(
      "===underlying balance is ======",
      underlyingbalance / supplyAmount
    );

    /* redeeming the amount */
    const redeemData = await dCompound.redeemToken(ownerAddress, {
      from: ownerAddress,
      gasLimit: 1000000,
    });
    console.log("====redeem data====", redeemData);

    /* checking the balance again */
    balance = await dCompound.getBalance();
    console.log("==balance==", balance);
  });
});
