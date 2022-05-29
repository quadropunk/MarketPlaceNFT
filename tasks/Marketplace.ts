import { task } from "hardhat/config";

const MARKETPLACE_ADDRESS = process.env.MARKETPLACE_ADDRESS as string;

task("createERC721", "Creates item with ERC721 standard")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.createItem(taskArguments.tokenId);
    console.log(`Created ERC721 item with ${taskArguments.tokenId} id`);
  });

task("createERC1155", "Creates item with ERC1155 standard")
  .addParam("tokenId")
  .addParam("amount")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.createItem(taskArguments.amount, taskArguments.tokenId);
    console.log(
      `Created ERC1155 items (${taskArguments.amount}) with ${taskArguments.tokenId} id`
    );
  });

task("listERC721", "Lists item with ERC721 standard")
  .addParam("tokenId")
  .addParam("price")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.listItem(taskArguments.tokenId, taskArguments.price);
    console.log(`Listed ERC721 item for (${taskArguments.price}) tokens`);
  });

task("listERC1155", "Lists item with ERC1155 standard")
  .addParam("tokenId")
  .addParam("price")
  .addParam("amount")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.listItem(
      taskArguments.tokenId,
      taskArguments.price,
      taskArguments.amount
    );
    console.log(
      `Listed ERC1155 items (${taskArguments.amount}) for (${taskArguments.price}) tokens`
    );
  });

task("cancel", "Cancels listing item")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.cancel(taskArguments.tokenId);
    console.log(`Canceled listing ${taskArguments.tokenId} token`);
  });

task("buyERC721", "Buys item with ERC721 standard")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.buyItem(taskArguments.tokenId);
    console.log(`Item with ${taskArguments.tokenId} id is bought`);
  });

task("buyERC1155", "Buys item with ERC1155 standard")
  .addParam("tokenId")
  .addParam("amount")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.buyItem(taskArguments.tokenId, taskArguments.amount);
    console.log(
      `Items (${taskArguments.amount}) with ${taskArguments.tokenId} id is bought`
    );
  });

task("listERC721onAuction", "Lists item with ERC721 standard on Auction")
  .addParam("tokenId")
  .addParam("price")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.listItemOnAuction(
      taskArguments.tokenId,
      taskArguments.price
    );
    console.log(
      `Listed ERC721 item on auction for (${taskArguments.price}) tokens`
    );
  });

task("listERC1155onAuction", "Lists item with ERC1155 standard")
  .addParam("tokenId")
  .addParam("price")
  .addParam("amount")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.listItemOnAuction(
      taskArguments.tokenId,
      taskArguments.price,
      taskArguments.amount
    );
    console.log(
      `Listed ERC1155 items (${taskArguments.amount}) on auction for (${taskArguments.price}) tokens`
    );
  });

task("makeBid", "Makes a bid on the given token setting new price")
  .addParam("tokenId")
  .addParam("price")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.makeBid(taskArguments.tokenId, taskArguments.price);
    console.log(
      `The price of token ${taskArguments.tokenId} is ${taskArguments.price} noew`
    );
  });

task("finishAuction", "Finished listing of token on auction")
  .addParam("tokenId")
  .setAction(async function (taskArguments, hre) {
    const marketplace = await hre.ethers.getContractAt(
      "Marketplace",
      MARKETPLACE_ADDRESS
    );
    await marketplace.finishAuction(taskArguments.tokenId);
    console.log(`Listing ${taskArguments.tokenId} token is finished now`);
  });