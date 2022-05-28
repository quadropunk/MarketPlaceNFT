import "./ERC721.ts";
import "./ERC1155.ts";

import { task } from "hardhat/config";
import "dotenv/config";

const METADATA_LINK = `https://${process.env.METADATA_CID}.ipfs.nftstorage.link/metadata/`;

task("verifyERC20").setAction(async function (taskArgs, hre) {
  await hre.run("verify:verify", {
    address: process.env.ERC20_ADDRESS,
    constructorArguments: ["MyToken20", "MTN20"],
    contract: "contracts/tokens/MyERC20.sol:MyERC20",
  });
});

task("verifyERC721").setAction(async function (taskArgs, hre) {
  await hre.run("verify:verify", {
    address: process.env.ERC721_ADDRESS,
    constructorArguments: ["MyToken721", "MTN721", METADATA_LINK],
    contract: "contracts/tokens/MyERC721.sol:MyERC721",
  });
});

task("verifyERC1155").setAction(async function (taskArgs, hre) {
  await hre.run("verify:verify", {
    address: process.env.ERC1155_ADDRESS,
    constructorArguments: ["MyToken1155", "MTN1155", METADATA_LINK],
    contract: "contracts/tokens/MyERC1155.sol:MyERC1155",
  });
});

task("verifyMarketplace").setAction(async function (taskArgs, hre) {
  await hre.run("verify:verify", {
    address: process.env.MARKETPLACE_ADDRESS,
    constructorArguments: [
      process.env.ERC20_ADDRESS,
      process.env.ERC721_ADDRESS,
      process.env.ERC1155_ADDRESS,
    ],
    contract: "contracts/Marketplace.sol:Marketplace",
  });
});
