/* eslint-disable no-unused-expressions */
/* eslint-disable camelcase */
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { MyERC1155, MyERC1155__factory } from "../typechain";
import { BigNumber } from "ethers";
import "dotenv/config";

describe("ERC1155", function () {
  let ERC1155: MyERC1155;
  const uri = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;
  const name = "ERC1155";
  const symbol = "ERC1155";

  let signers: Array<SignerWithAddress>;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    const ERC1155Factory = (await ethers.getContractFactory(
      "MyERC1155",
      signers[0]
    )) as unknown as MyERC1155__factory;
    ERC1155 = await ERC1155Factory.deploy(name, symbol, uri);
    await ERC1155.deployed();
  });

  describe("Deployment", async function () {
    const id = 1;

    it("Should set right name", async function () {
      expect(await ERC1155.name()).to.equal(name);
    });

    it("Should set right symbol", async function () {
      expect(await ERC1155.symbol()).to.equal(symbol);
    });

    it("Should set right uri", async function () {
      expect(await ERC1155.uri(id)).to.equal(uri.concat(id.toString()));
    });

    it("Should set zero balances", async function () {
      signers.forEach(async (signer) =>
        expect(await ERC1155.balanceOf(signer.address, id)).to.equal(
          BigNumber.from(0)
        )
      );
    });
  });

  describe("Approvals", function () {
    it("Should approve transaction", async function () {
      expect(await ERC1155.setApprovalForAll(signers[1].address, true)).to.emit(
        "ERC1155",
        "ApprovalForAll"
      );
      expect(
        await ERC1155.isApprovedForAll(signers[0].address, signers[1].address)
      ).to.be.true;
    });

    it("Should revert when approving to yourself", async function () {
      await expect(
        ERC1155.setApprovalForAll(signers[0].address, true)
      ).to.be.revertedWith("ERC1155: setting approval status for self");
    });
  });

  describe("Transactions", function () {
    const id = 1;
    const amount = 5;

    beforeEach(async function () {
      await ERC1155.mintTo(signers[0].address, amount, id);
    });

    it("Should transfer tokens", async function () {
      await ERC1155.setApprovalForAll(signers[1].address, true);
      expect(
        await ERC1155.safeTransferFrom(
          signers[0].address,
          signers[1].address,
          id,
          amount,
          ethers.constants.AddressZero
        )
      ).to.emit("ERC1155", "TransferSingle");
      expect(await ERC1155.balanceOf(signers[1].address, id)).to.equal(amount);
    });
  });
});
