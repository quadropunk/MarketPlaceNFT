import "dotenv/config";

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "./tasks/index.ts";

const { ETHERSCAN_API_KEY, INFURA_KEY, PRIVATE_KEY, NETWORK } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  defaultNetwork: NETWORK,
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

export default config;
