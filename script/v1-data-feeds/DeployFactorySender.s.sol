// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactorySender} from "../../src/v1-data-feeds/FactorySender.sol";
import {HelperSenderConfig} from "./HelperSenderConfig.s.sol";

contract DeployFactorySender is Script {
    function run() external returns (FactorySender, HelperSenderConfig) {
        HelperSenderConfig config = new HelperSenderConfig();
        (address link, address router) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactorySender factorySender = new FactorySender(link, router);
        vm.stopBroadcast();
        return (factorySender, config);
    }
}
