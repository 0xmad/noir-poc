import "@nomicfoundation/hardhat-toolbox";
import "hardhat-noir";

import type { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.29",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100_000_000,
      },
    },
  },
  paths: {
    noir: "circuits",
    tests: "./tests",
    artifacts: "./artifacts",
    sources: "./solidity",
  },
  noir: {
    version: "1.0.0-beta.9",
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 0.525,
    coinmarketcap: process.env.COINMARKETCAP,
  },
};

export default config;
