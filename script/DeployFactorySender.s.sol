// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactorySender} from "../src/FactorySender.sol";
import {HelperSenderConfig} from "./HelperSenderConfig.s.sol";

contract DeployFactorySender is Script {
    function run() external returns (FactorySender, HelperSenderConfig) {
        HelperSenderConfig config = new HelperSenderConfig();
        (address link, address router, address priceFeed) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactorySender factorySender = new FactorySender(link, router, priceFeed);
        vm.stopBroadcast();
        return (factorySender, config);
    }
}
