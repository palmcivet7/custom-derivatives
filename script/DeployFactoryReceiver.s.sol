// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactoryReceiver} from "../src/FactoryReceiver.sol";
import {HelperReceiverConfig} from "./HelperReceiverConfig.s.sol";

contract DeployReceiverConfig is Script {
    function run() external returns (FactoryReceiver, HelperReceiverConfig) {
        HelperReceiverConfig config = new HelperReceiverConfig();
        (address link, address router, address registrar) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactoryReceiver factoryReceiver = new FactoryReceiver(link, router, registrar);
        vm.stopBroadcast();
        return (factoryReceiver, config);
    }
}
