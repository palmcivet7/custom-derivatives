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

    address public immutable i_link;
    address public immutable i_router;
    address public immutable i_priceFeed;

    constructor(address _link, address _router, address _priceFeed) {
        i_link = _link;
        i_router = _router;
        i_priceFeed = _priceFeed;
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
            data: abi.encode(_priceFeed, _strikePrice, _settlementTime, _collateralToken, _collateralAmount, _isPartyALong),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 4000000, strict: false})),
            feeToken: i_link
        });

        uint256 fees = IRouterClient(i_router).getFee(_destinationChainSelector, message);
        LinkTokenInterface(i_link).approve(address(i_router), fees);
        IRouterClient(i_router).ccipSend(_destinationChainSelector, message);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price,,,) = AggregatorV3Interface(i_priceFeed).latestRoundData();
        return uint256(price);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert FactorySender__NothingToWithdraw();

        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) revert FactorySender__TransferFailed();
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(i_link).balanceOf(address(this));
        if (balance == 0) revert FactorySender__NoLinkToWithdraw();

        if (!LinkTokenInterface(i_link).transfer(msg.sender, balance)) revert FactorySender__LinkTransferFailed();
    }
}
