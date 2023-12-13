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
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59 // https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, // https://testnet.snowtrace.io/token/0x0b9d5d9136855f6fec3c0993fee6e9ce8a297846
            router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177 // https://docs.chain.link/ccip/supported-networks#avalanche-fuji
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        WETH9 weth9 = new WETH9();
        MockARM mockArm = new MockARM();
        Router router = new Router(address(weth9), address(mockArm));
        MockLinkToken mockLink = new MockLinkToken();
        return NetworkConfig({link: address(mockLink), router: address(router)});
    }
}
