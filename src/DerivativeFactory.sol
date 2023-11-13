// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {CustomDerivative} from "./CustomDerivative.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DerivativeFactory
 * @author palmcivet.eth
 *
 * This is the factory contract that allows users to deploy their own versions of our CustomDerivative contract.
 * When a user deploys their CustomDerivative contract they will specify the following parameters:
 *  - underlying asset
 *  - strike price (the final price being above or below this will determine the party receiving the payout)
 *  - settlement time (the time the underlying asset's price will be compared to the strike price)
 *  - collateral asset (ERC20 token, USDC is recommended for demonstration purposes)
 *  - collateral amount (amount of collateral to be deposited by both parties)
 *  - long or short position (the deploying user will choose their position and the counterparty will take the opposite)
 */

contract DerivativeFactory is Ownable {
    error DerivativeFactory__NoLinkToWithdraw();
    error DerivativeFactory__LinkTransferFailed();

    event DerivativeCreated(address derivativeContract, address partyA);

    address public link;

    constructor(address _link) {
        link = _link;
    }

    function createCustomDerivative(
        address priceFeed, // underlying asset
        uint256 strikePrice,
        uint256 settlementTime,
        address collateralToken, // USDC
        uint256 collateralAmount,
        bool isPartyALong
    ) public returns (address) {
        CustomDerivative newCustomDerivative = new CustomDerivative(
            payable(msg.sender),
            priceFeed,
            strikePrice,
            settlementTime,
            collateralToken,
            collateralAmount,
            isPartyALong
        );

        emit DerivativeCreated(address(newCustomDerivative), msg.sender);

        return address(newCustomDerivative);
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(link).balanceOf(address(this));
        if (balance == 0) revert DerivativeFactory__NoLinkToWithdraw();

        if (!LinkTokenInterface(link).transfer(msg.sender, balance)) revert DerivativeFactory__LinkTransferFailed();
    }
}
