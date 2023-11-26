# Palmcivet's Custom Derivatives

This project allows users to deploy custom derivative contracts to any chain, speculating on any asset, with any collateral. Palmcivet's Custom Derivatives utilizes Chainlink [CCIP](https://docs.chain.link/ccip), [Automation](https://docs.chain.link/chainlink-automation), [Data Feeds](https://docs.chain.link/data-feeds), and [Data Streams](https://docs.chain.link/data-streams). There are two versions of this project - **V1** uses [Data Feeds](https://docs.chain.link/data-feeds) and **V2** uses [Data Streams](https://docs.chain.link/data-streams). Both of these Chainlink services are used for securing the price of the underlying asset in the derivative contract, but in slightly different ways - Data Feeds is a push based oracle and Data Streams is a pull based oracle.

[Video Demonstration](https://www.youtube.com/watch?v=SLAF6xqBhVk)

## Table of Contents

- [Palmcivet's Custom Derivatives](#palmcivets-custom-derivatives)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Versions](#versions)
    - [V1 - Data Feeds](#v1---data-feeds)
    - [V2 - Data Streams](#v2---data-streams)
    - [zkEVM Edition](#zkevm-edition)
  - [Demonstrations](#demonstrations)
    - [V1 Deployments/Transactions](#v1-deploymentstransactions)
    - [V2 Deployments/Transactions](#v2-deploymentstransactions)
  - [Frontend](#frontend)
  - [License](#license)

## Overview

Derivatives agreements have long been a popular investment vehicle and potential usecase for smart contracts. With Palmcivet's Custom Derivatives; anyone can deploy a derivative agreement, specifying the following parameters:

- **Underlying Asset** - The price of this asset is what will be speculated on.
- **Strike Price** - The price the _actual_ price of the _underlying asset_ will be compared to.
- **Settlement Time** - The time the _actual_ price of the _underlying asset_ will be compared to the _strike price_.
- **Collateral Asset** - The asset both parties put forward to speculate on the _underlying asset_ with.
- **Collateral Amount** - The amount of the _collateral asset_ both parties put forward.
- **Long or Short Position** - The deploying party must specify their long or short position. The counterparty will take the opposite.

Users interact with a _Derivative Factory_ contract to deploy their custom contract. When a user deploys their custom derivative contract, the _Derivative Factory_ contract registers it with Chainlink Automation. Custom Logic Automation is used for comparing the price of the underlying asset against the specified _strike price_ and paying out the collateral deposited by both parties to the party with the winning _long or short position_ when the _settlement time_ is reached. A 2% fee is taken from the total collateral and sent to a developer address.

The contract can be cancelled if both parties agree. If one party requests a cancellation, but the other party doesn't want one; the agreement will continue as originally specified. When both parties agree to a cancellation, they will both receive their full deposits back.

If one party deposits and the other doesn't, when the _settlement time_ is reached, the depositing party can withdraw their full deposit.

## Versions

As mentioned above there are two versions of this project, each utilizing a different Chainlink service for securing the price of the underlying asset - Data Feeds for **V1** and Data Streams for **V2**.

### V1 - Data Feeds

**V1** uses CCIP to allow users to deploy a custom derivative to their chain of choice. It achieves this with a _Factory Sender_ contract on Avalanche Fuji where the user inputs their specifications including the chain of their choice, and a _Factory Receiver_ contract on the chain of their choice which deploys their custom derivative contract and registers its settlement with Chainlink Automation.

`latestRoundData()` is called on the `AggregatorV3Interface` (the address of which would have been specified by the user as the _underlying asset_ on deployment) to retrieve the price of the _underlying asset_ at settlement time.

### V2 - Data Streams

My original intention when starting the development of this project was to use only Data Streams to secure the _underlying asset_'s price and also use CCIP to allow users to deploy to their chain of choice. When starting development I was under the impression Data Streams testnet access was restricted and so built **V1** with Data Feeds in place of where Data Streams was intended. It turned out testnet access for Data Streams was not restricted and after implementing Data Streams I realised that unfortunately it was [not available on a CCIP compatible testnet](https://docs.chain.link/data-streams/stream-ids?network=arbitrum&page=1#networks). That is the reason there are two versions of this project currently. When Data Streams is on a [CCIP supported network](https://docs.chain.link/ccip/supported-networks/testnet), the option to deploy to a choice of chains through CCIP with Data Streams securing the _underlying asset_'s price will be available.

Chainlink Custom Logic Automation is once again used in this version with the Data Streams `StreamsLookup` revert error emitted in the `checkUpkeep()` function. The `checkCallback()` function checks the data in the emitted error, passing it to `performUpkeep()` which retrieves the price and settles the contract.

### zkEVM Edition

I also ended up doing a [Polygon zkEVM Edition](https://github.com/palmcivet7/zkevm-custom-derivatives). Although as Chainlink services were unavailable on this chain, I was unable to implement Chainlink features.

## Demonstrations

### V1 Deployments/Transactions

[Factory Sender contract deployed on Avalanche Fuji](https://testnet.snowtrace.io/address/0x98be1c31fb80d1760604775fa6027025e436ad70#code) _**Note**: this deployment comments out payable logic in `createCrossChainCustomDerivative()`(the CCIP Sender function) and still has `getPrice()` from `AggregatorV3Interface` from when I was considering having users pay a predetermined price based on Data Feeds_

[Factory Receiver contract deployed on Ethereum Sepolia](https://sepolia.etherscan.io/address/0xa76f758e860053b100184eca3faacf37e6ea4f48#internaltx)

[Successful CCIP Tx deploying a custom derivative](https://ccip.chain.link/msg/0xc532de66f1808a5791eb9c8f301d15fb3cfb197f567ac2be5d1a1d1b7002593d)

[Automation paying out to the winning position Tx](https://sepolia.etherscan.io/tx/0x098a07923ea420091c4bfd94dcc0ffd53b2069d7dd91b44442cd83533fdabc2d)

---

### V2 Deployments/Transactions

[Derivative Factory contract deployed on Arbitrum Sepolia](https://sepolia.arbiscan.io/address/0x403a021e8eeb066cc7ffc1a9ab0be4ee8f703880#internaltx)

[Automation paying out to winning position using Data Streams Tx](https://sepolia.arbiscan.io/tx/0x9d5cc7bf376812a308c7177797037f9e1d0c2ae3e9e6ea8ac5bf194b91ecac6d)

## Frontend

The `/frontend` directory contains a basic frontend built with Next.js for deploying custom derivative contracts and depositing collateral.

To `npm run dev` inside the `/frontend` directory, you will need to provide the following environment variables to `/frontend/utils/constants.js`:

- `ETHERSCAN_API_KEY`
- `SEPOLIA_RPC_URL`
- `ARBISCAN_API_KEY`

## License

This project is licensed under the [MIT License](https://opensource.org/license/mit/).
