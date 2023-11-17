// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FactorySender is Ownable {
    error FactorySender__NotEnoughPayment();
    error FactorySender__NothingToWithdraw();
    error FactorySender__NoLinkToWithdraw();
    error FactorySender__LinkTransferFailed();
    error FactorySender__TransferFailed();

    address public link;
    address public router;
    address public priceFeed;

    constructor(address _link, address _router, address _priceFeed) {
        link = _link;
        router = _router;
        priceFeed = _priceFeed;
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
    ) public payable {
        uint256 price = getLatestPrice();
        uint256 mintingPrice = (5 * 10 ** 18 * 10 ** 8) / price;
        if (msg.value < mintingPrice) {
            revert FactorySender__NotEnoughPayment();
        }

        if (msg.value > mintingPrice) {
            uint256 excessAmount = msg.value - mintingPrice;
            payable(msg.sender).transfer(excessAmount);
        }

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(
                payable(msg.sender),
                _priceFeed,
                _strikePrice,
                _settlementTime,
                _collateralToken,
                _collateralAmount,
                _isPartyALong
                ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 4000000, strict: false})),
            feeToken: link
        });

        uint256 fees = IRouterClient(router).getFee(_destinationChainSelector, message);
        LinkTokenInterface(link).approve(address(router), fees);
        IRouterClient(router).ccipSend(_destinationChainSelector, message);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price,,,) = AggregatorV3Interface(priceFeed).latestRoundData();
        return uint256(price);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert FactorySender__NothingToWithdraw();

        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) revert FactorySender__TransferFailed();
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(link).balanceOf(address(this));
        if (balance == 0) revert FactorySender__NoLinkToWithdraw();

        if (!LinkTokenInterface(link).transfer(msg.sender, balance)) revert FactorySender__LinkTransferFailed();
    }
}
