import { task } from "hardhat/config";
import fetch from "node-fetch";

task("mintTo", "Mints new nft to some address")
  .addParam("receiver")
  .setAction(async function (taskArguments, hre) {
    const ERC721 = await hre.ethers.getContractAt(
      "MyERC721",
      process.env.ERC721_ADDRESS || ""
    );
    const id = await ERC721.mintTo(taskArguments.receiver);
    console.log(`Minted new token with id: ${id}`);
  });

task("printNft", "Prints metadata of the given token id")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const ERC721 = await hre.ethers.getContractAt(
      "MyERC721",
      process.env.ERC721_ADDRESS || ""
    );
    const response = await ERC721.tokenURI(taskArguments.tokenId);
    console.log(`Token URI: ${response}`);
    const json = await fetch(response).then((res) => res.json());
    console.log(JSON.stringify(json, null, 2));
  });
