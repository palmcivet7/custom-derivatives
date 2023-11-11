// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./DerivativeFactory.sol";
import {CCIPReceiver} from "@chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";

contract FactoryReceiver is DerivativeFactory, CCIPReceiver {
    constructor(address _router) CCIPReceiver(_router) {}

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        (
            address _priceFeed,
            uint256 _strikePrice,
            uint256 _settlementTime,
            address _collateralToken,
            uint256 _collateralAmount,
            bool _isPartyALong
        ) = abi.decode(message.data, (address, uint256, uint256, address, uint256, bool));
        createCustomDerivative(
            _priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong
        );
    }
}
