import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { BigNumber, Contract } from "ethers";
import "dotenv/config";
import { EPERM } from "constants";

describe("Marketplace", function () {
  let marketplace: Contract;
  let erc20: Contract, erc721: Contract, erc1155: Contract;
  let signers: Array<SignerWithAddress>;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    const METADATA_LINK = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;

    const ERC20 = await ethers.getContractFactory("MyERC20");
    erc20 = await ERC20.deploy("MyToken20", "MTN20");

    const ERC721 = await ethers.getContractFactory("MyERC721");
    erc721 = await ERC721.deploy("MyToken721", "MTN721", METADATA_LINK);

    const ERC1155 = await ethers.getContractFactory("MyERC1155");
    erc1155 = await ERC1155.deploy(METADATA_LINK);

    const MARKET_PLACE = await ethers.getContractFactory("Marketplace");
    marketplace = await MARKET_PLACE.deploy(
      erc20.address,
      erc721.address,
      erc1155.address
    );

    await erc20.deployed();
    await erc721.deployed();
    await erc1155.deployed();
    await marketplace.deployed();
  });

  describe("Deployment", function () {
    it("Should set empty sellingOrder structures (at least first one)", async function () {
      const tokenInfo = await marketplace.tokensInfo(1);
      expect(tokenInfo.owner).to.equal(ethers.constants.AddressZero);
      expect(tokenInfo.price).to.equal(0);
    });

    it("Should set right erc token's addresses", async function () {
      expect(await marketplace.erc20()).to.equal(erc20.address);
      expect(await marketplace.erc721()).to.equal(erc721.address);
      expect(await marketplace.erc1155()).to.equal(erc1155.address);
    });
  });

  describe("ERC721 Functions", function () {
    const id = 1;
    const price = 10;

    beforeEach(async function () {
      await marketplace["createItem(uint256)"](id);
    });

    it("Should create item", async function () {
      expect(await erc721.ownerOf(id)).to.equal(signers[0].address);
      const tokenInfo = await marketplace.tokensInfo(id);

      expect(tokenInfo.owner).to.equal(signers[0].address);
      expect(tokenInfo.price).to.equal(0);
    });

    it("Should revert if token id already created", async function () {
      await expect(marketplace["createItem(uint256)"](id)).to.be.revertedWith(
        "Token with such id exists"
      );
    });

    it("Should list item", async function () {
      await erc721.approve(marketplace.address, id);
      await marketplace["listItem(uint256,uint256)"](id, price);

      const tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.price).to.equal(price);
    });

    it("Should revert if item is already listed", async function () {
      await erc721.approve(marketplace.address, id);
      await marketplace["listItem(uint256,uint256)"](id, price);

      await expect(
        marketplace["listItem(uint256,uint256)"](id, price)
      ).to.be.revertedWith("This item is already listed");
    });

    it("Should buy item", async function () {
      await erc721.approve(marketplace.address, id);
      await marketplace["listItem(uint256,uint256)"](id, price);

      let tokenInfo = await marketplace.tokensInfo(id);
      const tokenOwner = tokenInfo.owner;
      const prevBalance = await erc20.balanceOf(tokenOwner);

      await erc20.mint(signers[1].address, price);
      await erc20.connect(signers[1]).approveTokens(tokenOwner, price);
      await marketplace.connect(signers[1])["buyItem(uint256)"](id);

      tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.owner).to.equal(signers[1].address);
      expect(tokenInfo.price).to.equal(0);
      expect(await erc20.balanceOf(tokenOwner)).to.equal(prevBalance + price);
    });

    it("Should cancel sale", async function () {
      await erc721.approve(marketplace.address, id);
      await marketplace["listItem(uint256,uint256)"](id, price);

      await marketplace.cancel(id);
      const tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.price).to.equal(0);
    });
  });

  describe("ERC1155 Functions", function () {
    const id = 1;
    const amount = 5;
    const price = 10;

    beforeEach(async function () {
      await marketplace["createItem(uint256,uint256)"](amount, id);
      await erc1155.approve(marketplace.address, id, amount);
    });

    it("Should create item", async function () {
      expect(await erc1155.balanceOf(signers[0].address, id)).to.equal(amount);

      const tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.owner).to.equal(signers[0].address);
      expect(tokenInfo.price).to.equal(0);
    });

    it("Should revert if token is already created", async function () {
      await expect(
        marketplace["createItem(uint256,uint256)"](amount, id)
      ).to.be.revertedWith("Token with such id exists");
    });

    it("Should list item", async function () {
      await marketplace["listItem(uint256,uint256,uint256)"](id, price, amount);

      const tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.price).to.equal(price);
    });

    it("Should revert if item is already listed", async function () {
      await marketplace["listItem(uint256,uint256,uint256)"](id, price, amount);
      await expect(
        marketplace["listItem(uint256,uint256,uint256)"](id, price, amount)
      ).to.be.revertedWith("This item is already listed");
    });

    it("Should buy item", async function () {
      await erc1155.approve(marketplace.address, id, amount);
      await marketplace["listItem(uint256,uint256,uint256)"](id, price, amount);

      let tokenInfo = await marketplace.tokensInfo(id);
      const tokenOwner = tokenInfo.owner;
      const prevBalance = await erc20.balanceOf(tokenOwner);

      const totalPrice = BigNumber.from(price).mul(amount);

      await erc20.mint(signers[1].address, totalPrice);
      await erc20
        .connect(signers[1])
        .approveTokens(tokenOwner, BigNumber.from(price).mul(amount));

      await erc1155.approve(signers[1].address, id, amount);
      await marketplace
        .connect(signers[1])
        ["buyItem(uint256,uint256)"](id, amount);

      tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.owner).to.equal(signers[1].address);
      expect(tokenInfo.price).to.equal(0);
      expect(await erc20.balanceOf(tokenOwner)).to.equal(
        BigNumber.from(prevBalance).add(totalPrice)
      );
    });

    it("Should cancel sale", async function () {
      await marketplace["listItem(uint256,uint256,uint256)"](id, price, amount);
      await marketplace.cancel(id);
      const tokenInfo = await marketplace.tokensInfo(id);
      expect(tokenInfo.price).to.equal(0);
    });
  });
});
