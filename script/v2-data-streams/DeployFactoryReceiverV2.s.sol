// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FactoryReceiverV2} from "../../src/v2-data-streams/FactoryReceiverV2.sol";
import {HelperReceiverConfig} from ".././HelperReceiverConfig.s.sol";

contract DeployReceiverConfig is Script {
    function run() external returns (FactoryReceiverV2, HelperReceiverConfig) {
        HelperReceiverConfig config = new HelperReceiverConfig();
        (address link, address router, address registrar) = config.activeNetworkConfig();
        vm.startBroadcast();
        FactoryReceiverV2 factoryReceiver = new FactoryReceiverV2(link, router, registrar);
        vm.stopBroadcast();
        return (factoryReceiver, config);
    }
}
