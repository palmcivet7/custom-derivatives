// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {CustomDerivative} from "./CustomDerivative.sol";

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
