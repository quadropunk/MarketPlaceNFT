/* eslint-disable no-unused-expressions */
/* eslint-disable camelcase */
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { MyERC1155, MyERC1155__factory } from "../typechain";
import { BigNumber } from "ethers";

describe("ERC1155", function () {
  let ERC1155: MyERC1155;
  const uri = "https://token-cdn-domain/";

  let signers: Array<SignerWithAddress>;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    const ERC1155Factory = (await ethers.getContractFactory(
      "MyERC1155",
      signers[0]
    )) as unknown as MyERC1155__factory;
    ERC1155 = await ERC1155Factory.deploy();
    await ERC1155.deployed();
  });

  describe("Deployment", async function () {
    const id = 1;

    it("Should set right uri", async function () {
      expect(await ERC1155.tokenUri(id)).to.equal(uri.concat(`${id}.json`));
    });

    it("Should set zero balances", async function () {
      expect(await ERC1155.balanceOf(signers[0].address, id)).to.equal(
        BigNumber.from(10)
      );
      signers
        .filter((_, index) => index !== 0)
        .forEach(async (signer) =>
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
    const ids = [1, 2, 3];
    const amounts = [5, 5, 5];

    beforeEach(async function () {
      await ERC1155.mintBatch(
        signers[0].address,
        ids,
        amounts,
        ethers.constants.AddressZero
      );
    });

    it("Should transfer tokens", async function () {
      await ERC1155.setApprovalForAll(signers[1].address, true);
      expect(
        await ERC1155.safeTransferFrom(
          signers[0].address,
          signers[1].address,
          ids[0],
          amounts[0],
          ethers.constants.AddressZero
        )
      ).to.emit("ERC1155", "TransferSingle");
      expect(await ERC1155.balanceOf(signers[1].address, ids[0])).to.equal(
        amounts[0]
      );
    });

    it("Should transfer multiple tokens", async function () {
      await ERC1155.setApprovalForAll(signers[1].address, true);
      expect(
        await ERC1155.safeBatchTransferFrom(
          signers[0].address,
          signers[1].address,
          ids,
          amounts,
          ethers.constants.AddressZero
        )
      ).to.emit("ERC155", "TransferBatch");
      ids.forEach(async (id, i) =>
        expect(await ERC1155.balanceOf(signers[1].address, id)).to.equal(
          amounts[i]
        )
      );
    });
  });
});
