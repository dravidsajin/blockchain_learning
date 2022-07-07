const { expect } = require("chai");
const hre = require("hardhat");

let deployer;
let seconduser;
let nftContract1;
let nftContract2;
let marketContract;
let NFT1ID;
let NFT2ID;

describe("Testing Contracts", function () {
  describe("Setup ", async function () {
    it("contracts and addresses", async function () {
      const users = await hre.ethers.getSigners();
      [deployer, seconduser] = users;

      /* deploying the contract */
      const nft = await hre.ethers.getContractFactory("NFT");
      nftContract1 = await nft.connect(deployer).deploy();
      nftContract1 = await nftContract1.deployed();

      /* deploying the contract */
      const nft2 = await hre.ethers.getContractFactory("NFT2");
      nftContract2 = await nft2.connect(seconduser).deploy();
      nftContract2 = await nftContract2.deployed();

      /* deploying the market contract */
      const market = await hre.ethers.getContractFactory("Markets");
      marketContract = await market.deploy();
      marketContract = await marketContract.deployed();
    });
  });

  describe("NFT", async function () {
    it("It will mint the tokens to nft1 contract", async function () {
      /* checking the name */
      const name = await nftContract1.name();
      expect(name).to.equal("BoogaBooga");

      /* minting the data */
      const mint = await nftContract1.mint(
        deployer.address,
        "https://game.example/item-id-8u5h2m.png"
      );
      const txn = await mint.wait();

      /* fetching the token id */
      const tokenID = await nftContract1.getID();
      NFT1ID = tokenID.toString();
      expect(NFT1ID).eq("1");
    });

    it("It will mint the tokens to nft2 contract", async function () {
      /* checking the name */
      const name = await nftContract2.name();
      expect(name).to.equal("NonSense");

      /* minting the data */
      const mint = await nftContract2.mint(
        seconduser.address,
        "https://game.example/item-id-8u5h2m.png"
      );
      const txn = await mint.wait();

      /* fetching the token id */
      const tokenID = await nftContract2.getID();
      NFT2ID = tokenID.toString();
      expect(NFT2ID).eq("1");
    });

    it("It is used to listing the token", async function () {
      /* Approving the market contract */
      const approve = await nftContract1
        .connect(deployer)
        .approve(marketContract.address, NFT1ID);
      await approve.wait();

      /* listing the tokens 1 */
      const listingFirstNft = await marketContract
        .connect(deployer)
        .listTokens(nftContract1.address, NFT1ID, "1000000000000000000");
      await listingFirstNft.wait();

      /* checking the owner address */
      expect(await nftContract1.ownerOf(NFT1ID)).eq(marketContract.address);

      /* fetching the data */
      const tokenData = await marketContract.getTokensList(1);
      expect(tokenData.tokenID).eq("1");
    });

    it("It is used to buying the token", async function () {
      /* buying the token */
      const buyToken = await marketContract
        .connect(seconduser)
        .buyToken(1, { value: ethers.utils.parseEther("1.0") });
      const txn = await buyToken.wait();

      /* fetching the data */
      const tokenData = await marketContract.getTokensList(1);
      expect(tokenData.tokenID).eq("1");
      expect(tokenData.owner).eq(seconduser.address);
    });

    it("It is used to change the status of the token", async function () {
      /* updating the status */
      const transaction = await marketContract
        .connect(seconduser)
        .cancelSell(1);
      await transaction.wait();

      /* fetching the data */
      const tokenData = await marketContract.getTokensList(1);
      expect(tokenData.status).eq("2");
    });

    it("It is used to change the status to active of the token", async function () {
      /* updating the status */
      const transaction = await marketContract
        .connect(seconduser)
        .makeActive(1);
      await transaction.wait();

      /* fetching the data */
      const tokenData = await marketContract.getTokensList(1);
      expect(tokenData.status).eq("0");
    });
  });
});
