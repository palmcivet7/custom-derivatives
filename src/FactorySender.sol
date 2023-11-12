// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FactorySender is Ownable {
    error FactorySender__NoLinkToWithdraw();
    error FactorySender__LinkTransferFailed();

    address public link;
    address public router;

    constructor(address _link, address _router) {
        link = _link;
        router = _router;
    }

    function createCrossChainCustomDerivative(
        address _receiver,
        uint64 _destinationChainSelector,
        address _priceFeed,
        uint256 _strikePrice,
        uint256 _settlementTime,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong
    ) public {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 2000000, strict: false})),
            feeToken: link
        });

        uint256 fees = IRouterClient(router).getFee(_destinationChainSelector, message);
        LinkTokenInterface(link).approve(address(router), fees);
        IRouterClient(router).ccipSend(_destinationChainSelector, message);
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(link).balanceOf(address(this));
        if (balance == 0) revert FactorySender__NoLinkToWithdraw();

        if (!LinkTokenInterface(link).transfer(msg.sender, balance)) revert FactorySender__LinkTransferFailed();
    }
}
