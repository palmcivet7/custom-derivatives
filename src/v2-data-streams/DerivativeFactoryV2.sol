// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {CustomDerivativeV2} from "./CustomDerivativeV2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DerivativeFactoryV2
 * @author palmcivet.eth
 *
 * This V2 contract is differentiated from the first DerivativeFactory contract because the CustomDerivative it
 * deploys uses Data Streams as opposed to Data Feeds for efficiently securing the underlying asset price
 * at the time of settlement.
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

struct LogTriggerConfig {
    address contractAddress; // must have address that will be emitting the log
    uint8 filterSelector; // must have filtserSelector, denoting  which topics apply to filter ex 000, 101, 111...only last 3 bits apply
    bytes32 topic0; // must have signature of the emitted event
    bytes32 topic1; // optional filter on indexed topic 1
    bytes32 topic2; // optional filter on indexed topic 2
    bytes32 topic3; // optional filter on indexed topic 3
}

interface AutomationRegistrarInterface {
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256);
}

contract DerivativeFactory is Ownable {
    error DerivativeFactory__NoLinkToWithdraw();
    error DerivativeFactory__LinkTransferFailed();
    error DerivativeFactory__LinkTransferAndCallFailed();
    error DerivativeFactory__AutomationRegistrationFailed();

    event DerivativeCreated(address derivativeContract, address partyA);
    event UpkeepRegistered(uint256 upkeepID, address derivativeContract);

    address public immutable i_link;
    address public immutable i_registrar;

    constructor(address _link, address _registrar) {
        i_link = _link;
        i_registrar = _registrar;
    }

    function createCustomDerivative(
        address payable partyA,
        // address priceFeed, // underlying asset
        address verifier,
        uint256 strikePrice,
        uint256 settlementTime,
        address collateralToken,
        uint256 collateralAmount,
        bool isPartyALong
    ) public returns (address) {
        CustomDerivativeV2 newCustomDerivative = new CustomDerivativeV2(
            partyA,
            // priceFeed,
            verifier,
            strikePrice,
            settlementTime,
            collateralToken,
            collateralAmount,
            isPartyALong
        );

        emit DerivativeCreated(address(newCustomDerivative), partyA);
        registerAndPredictID(address(newCustomDerivative));
        return address(newCustomDerivative);
    }

    function registerAndPredictID(address _deployedContract) private {
        RegistrationParams memory params = RegistrationParams({
            name: "",
            encryptedEmail: hex"",
            upkeepContract: _deployedContract,
            gasLimit: 2000000,
            adminAddress: owner(),
            triggerType: 1, // 	0 is Conditional upkeep, 1 is Log trigger upkeep
            checkData: hex"",
            triggerConfig: hex"",
            offchainConfig: hex"",
            amount: 1000000000000000000
        });

        LinkTokenInterface(i_link).approve(i_registrar, params.amount);
        uint256 upkeepID = AutomationRegistrarInterface(i_registrar).registerUpkeep(params);
        if (upkeepID != 0) {
            emit UpkeepRegistered(upkeepID, _deployedContract);
        } else {
            revert DerivativeFactory__AutomationRegistrationFailed();
        }
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(i_link).balanceOf(address(this));
        if (balance == 0) revert DerivativeFactory__NoLinkToWithdraw();

        if (!LinkTokenInterface(i_link).transfer(msg.sender, balance)) revert DerivativeFactory__LinkTransferFailed();
    }
}
