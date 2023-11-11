// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactorySender} from "../src/FactorySender.sol";
import {HelperSenderConfig} from "./HelperSenderConfig.s.sol";

contract DeployFactorySender is Script {
    function run() external returns (FactorySender, HelperSenderConfig) {
        HelperSenderConfig config = new HelperSenderConfig();
        (address router, address link) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactorySender factorySender = new FactorySender(router, link);
        vm.stopBroadcast();
        return (factorySender, config);
    }
}
