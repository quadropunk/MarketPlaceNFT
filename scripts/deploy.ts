import { ethers } from "hardhat";

async function main() {
  const ERC721 = await ethers.getContractFactory("MyERC721");
  const erc721 = await ERC721.deploy("NFT", "NFT");

  await erc721.deployed();

  console.log("ERC721 deployed to:", erc721.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
