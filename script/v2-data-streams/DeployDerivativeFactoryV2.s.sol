// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DerivativeFactoryV2} from "../../src/v2-data-streams/DerivativeFactoryV2.sol";
import {HelperReceiverConfig} from "./HelperReceiverConfig.s.sol";

contract DeployDerivativeFactoryV2 is Script {
    function run() external returns (DerivativeFactoryV2, HelperReceiverConfig) {
        HelperReceiverConfig config = new HelperReceiverConfig();
        (address link,, address registrar) = config.activeNetworkConfig();

        vm.startBroadcast();
        DerivativeFactoryV2 derivativeFactory = new DerivativeFactoryV2(link, registrar);
        vm.stopBroadcast();
        return (derivativeFactory, config);
    }
}
