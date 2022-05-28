import { ethers } from "hardhat";
import "dotenv/config";

async function main() {
  const METADATA_LINK = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;

  const ERC721 = await ethers.getContractFactory("MyERC721");
  const erc721 = await ERC721.deploy("MyToken721", "MTN721", METADATA_LINK);

  const ERC1155 = await ethers.getContractFactory("MyERC1155");
  const erc1155 = await ERC1155.deploy("MyToken1155", "MTN1155", METADATA_LINK);

  await erc721.deployed();
  await erc1155.deployed();

  console.log("ERC721 deployed to:", erc721.address);
  console.log("ERC1155 deployed to", erc1155.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
