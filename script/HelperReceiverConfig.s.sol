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
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 43113) {
            activeNetworkConfig = getFujiConfig();
        } else if (block.chainid == 421614) {
            activeNetworkConfig = getArbitrumSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // https://sepolia.etherscan.io/token/0x779877a7b0d9e8603169ddbd7836e478b4624789
            router: 0xD0daae2231E9CB96b94C8512223533293C3693Bf, // https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
            registrar: 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976 // https://docs.chain.link/chainlink-automation/overview/supported-networks#sepolia-testnet
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, // https://testnet.snowtrace.io/token/0x0b9d5d9136855f6fec3c0993fee6e9ce8a297846
            router: 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, // https://docs.chain.link/ccip/supported-networks#avalanche-fuji
            registrar: 0x819B58A646CDd8289275A87653a2aA4902b14fe6 // https://docs.chain.link/chainlink-automation/overview/supported-networks#fuji-testnet
        });
    }

    function getArbitrumSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E, // https://sepolia.arbiscan.io/address/0xb1d4538b4571d411f07960ef2838ce337fe1e80e
            router: 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165, // https://cll-devrel.gitbook.io/ccip-masterclass-3/ccip-masterclass/exercise-xnft
            registrar: 0x881918E24290084409DaA91979A30e6f0dB52eBe // https://docs.chain.link/chainlink-automation/overview/supported-networks#arbitrum-sepolia-testnet
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        MockLinkToken mockLink = new MockLinkToken();
        WETH9 weth9 = new WETH9();
        MockARM mockArm = new MockARM();
        Router router = new Router(address(weth9), address(mockArm));
        // AutomationRegistrar2_1 registrar = new AutomationRegistrar2_1();
        address registrar;
        return NetworkConfig({link: address(mockLink), router: address(router), registrar: address(registrar)});
    }
}
