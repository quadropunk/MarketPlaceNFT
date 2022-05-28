import { task } from "hardhat/config";
import fetch from "node-fetch";

task("mintErc1155To", "Mints new nft to some address")
  .addParam("receiver")
  .addParam("amount")
  .setAction(async function (taskArguments, hre) {
    const ERC1155 = await hre.ethers.getContractAt(
      "MyERC1155",
      process.env.ERC1155_ADDRESS || ""
    );
    const id = await ERC1155.mintTo(
      taskArguments.receiver,
      taskArguments.amount
    );
    console.log(`Minted new tokens (${taskArguments.amount}) with id: ${id}`);
  });

task("printErc1155", "Prints metadata of the given token id")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const ERC1155 = await hre.ethers.getContractAt(
      "MyERC1155",
      process.env.ERC1155_ADDRESS || ""
    );
    const response = await ERC1155.uri(taskArguments.tokenId);
    console.log(`Token URI: ${response}`);
    const json = await fetch(response).then((res) => res.json());
    console.log(JSON.stringify(json, null, 2));
  });
