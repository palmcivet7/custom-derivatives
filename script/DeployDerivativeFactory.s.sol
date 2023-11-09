// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DerivativeFactory} from "../src/DerivativeFactory.sol";

contract DeployDerivativeFactory is Script {
    function run() external returns (DerivativeFactory) {
        vm.startBroadcast();
        DerivativeFactory derivativeFactory = new DerivativeFactory();
        vm.stopBroadcast();
        return (derivativeFactory);
    }
}
