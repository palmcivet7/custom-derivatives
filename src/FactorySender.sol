// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FactorySender is Ownable {
    address public link;
    address public router;

    struct Config {
        address receiver;
        uint64 chainSelector;
    }

    Config public config;

    constructor(address _link, address _router) {
        link = _link;
        router = _router;
    }

    function createCrossChainCustomDerivative(
        address _priceFeed,
        uint256 _strikePrice,
        uint256 _settlementTime,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong
    ) public {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(config.receiver),
            data: abi.encode(_priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: link
        });

        uint64 destinationChainSelector = config.chainSelector;
        uint256 fees = IRouterClient(router).getFee(destinationChainSelector, message);
        LinkTokenInterface(link).approve(address(router), fees);
        IRouterClient(router).ccipSend(destinationChainSelector, message);
    }

    function setConfig(address _receiver, uint64 _chainSelector) public onlyOwner {
        config.receiver = _receiver;
        config.chainSelector = _chainSelector;
    }
}
