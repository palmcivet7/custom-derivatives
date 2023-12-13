// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactorySenderV2} from "../../src/v2-data-streams/FactorySenderV2.sol";
import {HelperSenderConfig} from ".././HelperSenderConfig.s.sol";

contract DeployFactorySenderV2 is Script {
    function run() external returns (FactorySenderV2, HelperSenderConfig) {
        HelperSenderConfig config = new HelperSenderConfig();
        (address link, address router) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactorySenderV2 factorySender = new FactorySenderV2(link, router);
        vm.stopBroadcast();
        return (factorySender, config);
    }
}
