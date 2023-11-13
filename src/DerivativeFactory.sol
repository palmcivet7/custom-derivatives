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
    error DerivativeFactory__LinkTransferAndCallFailed();

    event DerivativeCreated(address derivativeContract, address partyA);

    address public link;
    address public registrar;

    RegistrationData public registrationInfo;

    struct RegistrationData {
        string name;
        bytes encryptedEmail;
        address upkeepContract;
        uint32 gasLimit;
        address adminAddress;
        uint8 triggerType;
        bytes checkData;
        bytes triggerConfig;
        bytes offchainConfig;
        uint96 amount;
    }

    constructor(address _link, address _registrar) {
        link = _link;
        registrar = _registrar;

        registrationInfo = RegistrationData({
            name: "",
            encryptedEmail: "",
            upkeepContract: address(0),
            gasLimit: 200000,
            adminAddress: msg.sender,
            triggerType: 0,
            checkData: "",
            triggerConfig: "",
            offchainConfig: "",
            amount: 0
        });
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

    function registerUpkeepForDeployedContract(address deployedContract) public returns (bool) {
        registrationInfo.upkeepContract = deployedContract;

        bytes memory registrationData = abi.encode(
            registrationInfo.name,
            registrationInfo.encryptedEmail,
            registrationInfo.upkeepContract,
            registrationInfo.gasLimit,
            registrationInfo.adminAddress,
            registrationInfo.triggerType,
            registrationInfo.checkData,
            registrationInfo.triggerConfig,
            registrationInfo.offchainConfig,
            registrationInfo.amount
        );

        LinkTokenInterface(link).transferAndCall(registrar, registrationInfo.amount, registrationData);
        bool success = LinkTokenInterface(link).transferAndCall(registrar, registrationInfo.amount, registrationData);
        if (!success) revert DerivativeFactory__LinkTransferAndCallFailed();
        return success;
    }

    function updateRegistrationData(
        string calldata newName,
        bytes calldata newEncryptedEmail,
        address newUpkeepContract,
        uint32 newGasLimit,
        address newAdminAddress,
        uint8 newTriggerType,
        bytes calldata newCheckData,
        bytes calldata newTriggerConfig,
        bytes calldata newOffchainConfig,
        uint96 newAmount
    ) external onlyOwner {
        registrationInfo = RegistrationData({
            name: newName,
            encryptedEmail: newEncryptedEmail,
            upkeepContract: newUpkeepContract,
            gasLimit: newGasLimit,
            adminAddress: newAdminAddress,
            triggerType: newTriggerType,
            checkData: newCheckData,
            triggerConfig: newTriggerConfig,
            offchainConfig: newOffchainConfig,
            amount: newAmount
        });
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(link).balanceOf(address(this));
        if (balance == 0) revert DerivativeFactory__NoLinkToWithdraw();

        if (!LinkTokenInterface(link).transfer(msg.sender, balance)) revert DerivativeFactory__LinkTransferFailed();
    }
}
