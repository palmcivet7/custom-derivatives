// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DerivativeFactory.sol";
import {CCIPReceiver} from "@chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";

contract FactoryReceiver is DerivativeFactory, CCIPReceiver {
    constructor(address _link, address _router, address _registrar)
        DerivativeFactory(_link, _registrar)
        CCIPReceiver(_router)
    {}

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        address _partyA;
        address _priceFeed;
        uint256 _strikePrice;
        uint256 _settlementTime;
        address _collateralToken;
        uint256 _collateralAmount;
        bool _isPartyALong;

        (_partyA, _priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong) =
            abi.decode(message.data, (address, address, uint256, uint256, address, uint256, bool));

        address payable partyAPayable = payable(_partyA);

        createCustomDerivative(
            partyAPayable, _priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong
        );
    }
}
