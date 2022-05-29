import { ethers } from "hardhat";
import "dotenv/config";

async function main() {
  const METADATA_LINK = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;

  const ERC20 = await ethers.getContractFactory("MyERC20");
  const erc20 = await ERC20.deploy("MyToken20", "MTN20");

  const ERC721 = await ethers.getContractFactory("MyERC721");
  const erc721 = await ERC721.deploy("MyToken721", "MTN721", METADATA_LINK);

  const ERC1155 = await ethers.getContractFactory("MyERC1155");
  const erc1155 = await ERC1155.deploy(METADATA_LINK);

  const MARKET_PLACE = await ethers.getContractFactory("Marketplace");
  const marketPlace = await MARKET_PLACE.deploy(
    erc20.address,
    erc721.address,
    erc1155.address
  );

  await erc20.deployed();
  await erc721.deployed();
  await erc1155.deployed();
  await marketPlace.deployed();

  console.log("ERC20 deployed to: ", erc20.address);
  console.log("ERC721 deployed to:", erc721.address);
  console.log("ERC1155 deployed to", erc1155.address);
  console.log("Market place deployed to: ", marketPlace.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
