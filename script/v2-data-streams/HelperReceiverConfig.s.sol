// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Router} from "@chainlink/contracts/src/v0.8/ccip/Router.sol";
import {MockARM} from "@chainlink/contracts/src/v0.8/ccip/test/mocks/MockARM.sol";
import {WETH9} from "@chainlink/contracts/src/v0.8/ccip/test/WETH9.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";
// import {AutomationRegistrar2_1} from "@chainlink/contracts/src/v0.8/automation/v2_1/AutomationRegistrar2_1.sol";

contract HelperReceiverConfig is Script {
    struct NetworkConfig {
        address link;
        address router;
        address registrar;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 421614) {
            activeNetworkConfig = getArbitrumSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getArbitrumSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E, // https://sepolia.arbiscan.io/address/0xb1d4538b4571d411f07960ef2838ce337fe1e80e
            router: address(0), // https://docs.chain.link/ccip/supported-networks/testnet
            registrar: 0x881918E24290084409DaA91979A30e6f0dB52eBe // https://docs.chain.link/chainlink-automation/overview/supported-networks#arbitrum-sepolia-testnet
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        MockLinkToken mockLink = new MockLinkToken();
        address router;
        address registrar;
        return NetworkConfig({link: address(mockLink), router: address(router), registrar: address(registrar)});
    }
}
