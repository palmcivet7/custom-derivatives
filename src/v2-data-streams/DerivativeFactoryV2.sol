// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {CustomDerivativeV2} from "./CustomDerivativeV2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DerivativeFactoryV2
 * @author palmcivet
 * This V2 contract is differentiated from the first DerivativeFactory contract because the CustomDerivative it
 * deploys uses Data Streams as opposed to Data Feeds for efficiently securing the underlying asset price
 * at the time of settlement.
 *
 * This is the factory contract that allows users to deploy their own versions of our CustomDerivative contract.
 * When a user deploys their CustomDerivative contract they will specify the following parameters:
 *  - underlying asset - this is determined by the verifier address and feedIds
 *  - strike price (the final price being above or below this will determine the party receiving the payout)
 *  - settlement time (the time the underlying asset's price will be compared to the strike price)
 *  - collateral asset (ERC20 token, USDC is recommended for demonstration purposes)
 *  - collateral amount (amount of collateral to be deposited by both parties)
 *  - long or short position (the deploying user will choose their position and the counterparty will take the opposite)
 * @dev Chainlink Automation is used for settling the CustomDerivative contract so when a new contract is deployed here,
 * we need to register it with Chainlink Automation using registerAndPredictID().
 */
struct RegistrationParams {
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

interface AutomationRegistrarInterface {
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256);
}

contract DerivativeFactoryV2 is Ownable {
    error DerivativeFactory__NoLinkToWithdraw();
    error DerivativeFactory__LinkTransferFailed();
    error DerivativeFactory__LinkTransferAndCallFailed();
    error DerivativeFactory__CustomLogicRegistrationFailed();
    error DerivativeFactory__LogTriggerRegistrationFailed();

    address public immutable i_link;
    address public immutable i_registrar;

    event DerivativeCreated(address derivativeContract, address partyA);
    event CustomLogicUpkeepRegistered(uint256 upkeepID, address derivativeContract);
    event LogTriggerUpkeepRegistered(uint256 upkeepID, address derivativeContract);

    constructor(address _link, address _registrar) {
        i_link = _link;
        i_registrar = _registrar;
    }

    function createCustomDerivative(
        address payable partyA,
        address payable verifier,
        uint256 strikePrice,
        uint256 settlementTime,
        address collateralToken,
        uint256 collateralAmount,
        bool isPartyALong,
        string[] memory feedIds
    ) public returns (address) {
        CustomDerivativeV2 newCustomDerivative = new CustomDerivativeV2(
            partyA, verifier, strikePrice, settlementTime, collateralToken, collateralAmount, isPartyALong, feedIds
        );

        emit DerivativeCreated(address(newCustomDerivative), partyA);
        registerAndPredictID(address(newCustomDerivative));
        if (!LinkTokenInterface(i_link).transfer(address(newCustomDerivative), 2000000000000000000)) {
            revert DerivativeFactory__LinkTransferFailed();
        }
        return address(newCustomDerivative);
    }

    function registerAndPredictID(address _deployedContract) private {
        RegistrationParams memory params = RegistrationParams({
            name: "",
            encryptedEmail: hex"",
            upkeepContract: _deployedContract,
            gasLimit: 2000000,
            adminAddress: owner(),
            triggerType: 0, // 	0 is Conditional upkeep, 1 is Log trigger upkeep
            checkData: hex"",
            triggerConfig: hex"",
            offchainConfig: hex"",
            amount: 3000000000000000000
        });

        LinkTokenInterface(i_link).approve(i_registrar, params.amount);
        uint256 upkeepID = AutomationRegistrarInterface(i_registrar).registerUpkeep(params);
        if (upkeepID != 0) {
            emit CustomLogicUpkeepRegistered(upkeepID, _deployedContract);
        } else {
            revert DerivativeFactory__CustomLogicRegistrationFailed();
        }
    }

    function withdrawLink() external onlyOwner {
        uint256 balance = LinkTokenInterface(i_link).balanceOf(address(this));
        if (balance == 0) revert DerivativeFactory__NoLinkToWithdraw();

        if (!LinkTokenInterface(i_link).transfer(msg.sender, balance)) revert DerivativeFactory__LinkTransferFailed();
    }
}
