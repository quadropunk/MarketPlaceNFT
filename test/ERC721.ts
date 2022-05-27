/* eslint-disable no-unused-expressions */
/* eslint-disable camelcase */
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { MyERC721__factory, MyERC721 } from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import "dotenv/config";

describe("ERC721", function () {
  let ERC721: MyERC721;
  const uri = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;

  let signers: Array<SignerWithAddress>;

  const name = "ERC721";
  const symbol = "ERC721";

  beforeEach(async function () {
    signers = await ethers.getSigners();
    const ERC721Factory = (await ethers.getContractFactory(
      "MyERC721",
      signers[0]
    )) as unknown as MyERC721__factory;
    ERC721 = await ERC721Factory.deploy(name, symbol);
    await ERC721.deployed();
  });

  describe("Deployment", function () {
    it("Should set right name", async function () {
      expect(await ERC721.name()).to.equal(name);
    });

    it("Should set right symbol", async function () {
      expect(await ERC721.symbol()).to.equal(symbol);
    });

    it("Should set right balances", async function () {
      signers.forEach(async (signer) =>
        expect(await ERC721.balanceOf(signer.address)).to.equal(0)
      );
    });

    it("Should set right url", async function () {
      await ERC721.mintTo(signers[0].address);
      expect(await ERC721.tokenURI(1)).to.equal(uri.concat("1"));
    });
  });

  describe("Approvals", async function () {
    const id = 1;

    beforeEach(async function () {
      await ERC721.mintTo(signers[0].address);
    });

    it("Should approve user to send token", async function () {
      expect(await ERC721.approve(signers[1].address, id)).to.emit(
        "ERC721",
        "Approval"
      );
      expect(await ERC721.getApproved(id)).to.equal(signers[1].address);
    });

    it("Should revert `msg.sender`-s approve to themselves", async function () {
      await expect(ERC721.approve(signers[0].address, id)).to.be.revertedWith(
        "ERC721: approval to current owner"
      );
    });

    it("Should approve for all tokens", async function () {
      expect(await ERC721.setApprovalForAll(signers[1].address, true)).to.emit(
        "ERC721",
        "Approval"
      );
      expect(
        await ERC721.isApprovedForAll(signers[0].address, signers[1].address)
      ).to.be.true;
    });
  });

  describe("Transactions", async function () {
    const id = 1;

    beforeEach(async function () {
      await ERC721.mintTo(signers[0].address);
    });

    describe("transferFrom method", async function () {
      it("Should transfer nft", async function () {
        await ERC721.approve(signers[1].address, id);
        expect(
          await ERC721.transferFrom(signers[0].address, signers[1].address, id)
        ).to.emit("MyERC721", "Transfer");
        expect(await ERC721.balanceOf(signers[1].address)).to.equal(1);
        expect(await ERC721.ownerOf(id)).to.equal(signers[1].address);
      });

      it("Should revert if `msg.sender` is not the current token owner.", async function () {
        await ERC721.approve(signers[1].address, id);
        await ERC721.approve(signers[2].address, id);
        await ERC721.transferFrom(signers[0].address, signers[1].address, id);
        await expect(
          ERC721.transferFrom(signers[0].address, signers[2].address, id)
        ).to.be.revertedWith(
          "ERC721: transfer caller is not owner nor approved"
        );
      });

      it("Should revert if receiver is zero address", async function () {
        await expect(
          ERC721.transferFrom(
            signers[0].address,
            ethers.constants.AddressZero,
            id
          )
        ).to.be.revertedWith("ERC721: transfer to the zero address");
      });
    });

    describe("safeTransferFrom method", async function () {
      it("Should transfer nft", async function () {
        await ERC721.approve(signers[1].address, id);
        expect(
          await ERC721["safeTransferFrom(address,address,uint256)"](
            signers[0].address,
            signers[1].address,
            id
          )
        ).to.emit("ERC721", "Transfer");
        expect(await ERC721.ownerOf(id)).to.equal(signers[1].address);
        expect(await ERC721.balanceOf(signers[1].address)).to.equal(1);
      });

      it("Should rever if `msg.sender` is not current owner", async function () {
        await ERC721.approve(signers[1].address, id);
        await ERC721.approve(signers[2].address, id);
        await ERC721["safeTransferFrom(address,address,uint256)"](
          signers[0].address,
          signers[1].address,
          id
        );
        await expect(
          ERC721["safeTransferFrom(address,address,uint256)"](
            signers[0].address,
            signers[2].address,
            id
          )
        ).to.be.revertedWith(
          "ERC721: transfer caller is not owner nor approved"
        );
      });

      it("Should revert if receiver is zero address", async function () {
        await expect(
          ERC721["safeTransferFrom(address,address,uint256)"](
            signers[0].address,
            ethers.constants.AddressZero,
            id
          )
        ).to.be.revertedWith("ERC721: transfer to the zero address");
      });
    });
  });
});
