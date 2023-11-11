// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {CustomDerivative} from "./CustomDerivative.sol";

/**
 * @title DerivativeFactory
 * @author palmcivet.eth
 *
 * This is the contract that allows users to deploy their own versions of our CustomDerivative contract.
 * When a user deploys their CustomDerivative contract they will specify the following parameters:
 *  - underlying asset
 *  - strike price (the final price being above or below this will determine the party receiving the payout)
 *  - settlement time (the time the underlying asset's price will be compared to the strike price)
 *  - collateral asset (ERC20 token, USDC is recommended for demonstration purposes)
 *  - collateral amount (amount of collateral to be deposited by both parties)
 *  - long or short position (the deploying user will choose their position and the counterparty will take the opposite)
 */

contract DerivativeFactory {
    event DerivativeCreated(address derivativeContract, address partyA);

    function createCustomDerivative(
        address priceFeed, // underlying asset
        uint256 strikePrice,
        uint256 settlementTime,
        address collateralToken, // USDC
        uint256 collateralAmount,
        bool isPartyALong
    ) external returns (address) {
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
}
