// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DerivativeFactory.sol";
import {CCIPReceiver} from "@chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";

contract FactoryReceiver is DerivativeFactory, CCIPReceiver {
    error FactoryReceiver__SourceChainNotAllowed(uint64 sourceChainSelector);
    error FactoryReceiver__SenderNotAllowed(address sender);

    mapping(uint64 chainSelecotor => bool isAllowlisted) public allowlistedSourceChains;
    mapping(address sender => bool isAllowlisted) public allowlistedSenders;

    constructor(address _link, address _router, address _registrar)
        DerivativeFactory(_link, _registrar)
        CCIPReceiver(_router)
    {}

    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (!allowlistedSourceChains[_sourceChainSelector]) {
            revert FactoryReceiver__SourceChainNotAllowed(_sourceChainSelector);
        }
        if (!allowlistedSenders[_sender]) revert FactoryReceiver__SenderNotAllowed(_sender);
        _;
    }

    function allowlistSourceChain(uint64 _sourceChainSelector, bool allowed) external onlyOwner {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    function allowlistSender(address _sender, bool allowed) external onlyOwner {
        allowlistedSenders[_sender] = allowed;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message)
        internal
        override
        onlyRouter
        onlyAllowlisted(message.sourceChainSelector, abi.decode(message.sender, (address)))
    {
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
