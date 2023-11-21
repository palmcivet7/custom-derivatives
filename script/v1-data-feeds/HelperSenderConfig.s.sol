// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Router} from "@chainlink/contracts/src/v0.8/ccip/Router.sol";
import {MockARM} from "@chainlink/contracts/src/v0.8/ccip/test/mocks/MockARM.sol";
import {WETH9} from "@chainlink/contracts/src/v0.8/ccip/test/WETH9.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract HelperSenderConfig is Script {
    struct NetworkConfig {
        address link;
        address router;
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 43113) {
            activeNetworkConfig = getFujiConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // https://sepolia.etherscan.io/token/0x779877a7b0d9e8603169ddbd7836e478b4624789
            router: 0xD0daae2231E9CB96b94C8512223533293C3693Bf, // https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1#sepolia-testnet
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, // https://testnet.snowtrace.io/token/0x0b9d5d9136855f6fec3c0993fee6e9ce8a297846
            router: 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, // https://docs.chain.link/ccip/supported-networks#avalanche-fuji
            priceFeed: 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD // https://docs.chain.link/data-feeds/price-feeds/addresses?network=avalanche&page=1#avalanche-testnet
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        WETH9 weth9 = new WETH9();
        MockARM mockArm = new MockARM();
        Router router = new Router(address(weth9), address(mockArm));
        MockLinkToken mockLink = new MockLinkToken();
        address priceFeed;
        return NetworkConfig({link: address(mockLink), router: address(router), priceFeed: address(priceFeed)});
    }
}
