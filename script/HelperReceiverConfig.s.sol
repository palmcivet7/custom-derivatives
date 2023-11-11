// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Router} from "@chainlink/contracts/src/v0.8/ccip/Router.sol";
import {MockARM} from "@chainlink/contracts/src/v0.8/ccip/test/mocks/MockARM.sol";
import {WETH9} from "@chainlink/contracts/src/v0.8/ccip/test/WETH9.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract HelperReceiverConfig is Script {
    struct NetworkConfig {
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
            router: 0xD0daae2231E9CB96b94C8512223533293C3693Bf // https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            router: 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8 // https://docs.chain.link/ccip/supported-networks#avalanche-fuji
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        WETH9 weth9 = new WETH9();
        MockARM mockArm = new MockARM();
        Router router = new Router(address(weth9), address(mockArm));
        return NetworkConfig({router: address(router)});
    }
}
