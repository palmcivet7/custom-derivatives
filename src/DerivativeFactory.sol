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
 * @dev Chainlink Automation is used for settling the CustomDerivative contract so when a new contract is deployed here,
 * we need to register it with Chainlink Automation using registerUpkeepForDeployedContract().
 */

contract DerivativeFactory is Ownable {
    error DerivativeFactory__NoLinkToWithdraw();
    error DerivativeFactory__LinkTransferFailed();
    error DerivativeFactory__LinkTransferAndCallFailed();

    event DerivativeCreated(address derivativeContract, address partyA);

    address public link;
    address public registrar;

    constructor(address _link, address _registrar) {
        link = _link;
        registrar = _registrar;
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
        registerUpkeepForDeployedContract(address(newCustomDerivative));
        return address(newCustomDerivative);
    }

    function registerUpkeepForDeployedContract(address _deployedContract) public returns (bool) {
        bytes memory registrationData =
            abi.encode("", "", _deployedContract, 200000, owner(), 0, "0x", "0x", "0x", 1000000000000000000);

        bool success = LinkTokenInterface(link).transferAndCall(registrar, 1000000000000000000, registrationData);
        if (!success) revert DerivativeFactory__LinkTransferAndCallFailed();
        return success;
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(link).balanceOf(address(this));
        if (balance == 0) revert DerivativeFactory__NoLinkToWithdraw();

        if (!LinkTokenInterface(link).transfer(msg.sender, balance)) revert DerivativeFactory__LinkTransferFailed();
    }
}
