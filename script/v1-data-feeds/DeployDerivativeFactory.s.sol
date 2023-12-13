// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DerivativeFactory} from "../../src/v1-data-feeds/DerivativeFactory.sol";
import {HelperReceiverConfig} from ".././HelperReceiverConfig.s.sol";

contract DeployDerivativeFactory is Script {
    function run() external returns (DerivativeFactory, HelperReceiverConfig) {
        HelperReceiverConfig config = new HelperReceiverConfig();
        (address link,, address registrar) = config.activeNetworkConfig();

        vm.startBroadcast();
        DerivativeFactory derivativeFactory = new DerivativeFactory(link, registrar);
        vm.stopBroadcast();
        return (derivativeFactory, config);
    }
}
