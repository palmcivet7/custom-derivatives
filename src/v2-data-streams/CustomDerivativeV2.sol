// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {ILogAutomation} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {IVerifierProxy} from "../interfaces/IVerifierProxy.sol";
import {IFeeManager} from "../interfaces/IFeeManager.sol";
import {ChainlinkCommon} from "../libraries/ChainlinkCommon.sol";

/**
 * @title CustomDerivativeV2
 * @author palmcivet
 * This V2 contract is differentiated from the first CustomDerivative contract because it uses
 * Data Streams as opposed to Data Feeds for efficiently securing the underlying asset price
 * at the time of settlement.
 * This is the custom contract that is deployed by users via the DerivativeFactoryV2 contract.
 * @notice This contract contains the main logic for our the derivative agreement between parties.
 */
interface StreamsLookupCompatibleInterface {
    error StreamsLookup(string feedParamKey, string[] feeds, string timeParamKey, uint256 time, bytes extraData);

    function checkCallback(bytes[] memory values, bytes memory extraData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData);
}

interface IReportHandler {
    function handleReport(bytes calldata report) external;
}

interface IRewardManager {}

contract CustomDerivativeV2 is AutomationCompatible {
    error StreamsLookup(string feedParamKey, string[] feeds, string timeParamKey, uint256 time, bytes extraData);
    error CustomDerivative__InvalidAddress();
    error CustomDerivative__NeedsToBeMoreThanZero();
    error CustomDerivative__SettlementTimeNeedsToBeInFuture();
    error CustomDerivative__CounterpartyAlreadyAgreed();
    error CustomDerivative__AddressCannotBeBothParties();
    error CustomDerivative__OnlyPartiesCanDeposit();
    error CustomDerivative__ContractAlreadySettled();
    error CustomDerivative__OnlyDepositsByPartyA();
    error CustomDerivative__NotEnoughCollateral();
    error CustomDerivative__TransferFailed();
    error CustomDerivative__SettlementTimeNotReached();
    error CustomDerivative__OnlyPartyACanCall();
    error CustomDerivative__OnlyPartyBCanCall();
    error CustomDerivative__BothPartiesNeedToAgreeToCancel();
    error CustomDerivative__ContractCancelled();
    error CustomDerivative__ContractNotCancelled();
    error CustomDerivative__CollateralNotFullyDeposited();
    error CustomDerivative__CollateralFullyDeposited();

    struct BasicReport {
        bytes32 feedId; // The feed ID the report has data for
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain’s native token (WETH/ETH)
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK
        uint32 expiresAt; // Latest timestamp where the report can be verified on-chain
        int192 price; // DON consensus median price, carried to 8 decimal places
    }

    address payable public immutable partyA;
    address payable public partyB;
    // a 2% fee will be taken from successful trades and sent to the DEVELOPER wallet
    address private constant DEVELOPER = 0xe0141DaBb4A8017330851f99ff8fc34aa619BBFD;
    uint256 public constant DEVELOPER_FEE_PERCENTAGE = 2; // 2%

    IVerifierProxy public immutable verifier;
    IERC20 public immutable collateralToken;
    uint256 public immutable strikePrice;
    uint256 public immutable settlementTime;

    uint256 public immutable collateralAmount;
    uint256 public partyACollateral;
    uint256 public partyBCollateral;

    bool public immutable isPartyALong;
    bool public counterpartyAgreed;
    bool public contractSettled;
    bool public partyACancel;
    bool public partyBCancel;
    bool public contractCancelled;

    string public constant STRING_DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant STRING_DATASTREAMS_QUERYLABEL = "timestamp";
    string[] public feedIds;

    event CounterpartyEntered(address partyB);
    event CollateralDeposited(address depositor, uint256 amount);
    event ContractSettled(uint256 finalPrice);
    event ContractCancelled();
    event CollateralWithdrawn(address withdrawer, uint256 amount);
    event PartyRequestedCancellation(address party);

    //////////////////////////////
    ///////// Modifiers /////////
    ////////////////////////////

    /**
     * @notice Functions with this modifier will revert if the contract has already settled or been cancelled.
     */
    modifier notSettledOrCancelled() {
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();
        if (contractCancelled) revert CustomDerivative__ContractCancelled();
        _;
    }

    /**
     * @param _partyA The address of user who deployed the custom contract via the DerivativeFactory
     * @param _verifier The Chainlink Data Streams Verifier Proxy address
     * @param _strikePrice The strike price is what the final price is compared against to determine the payout receipient
     * @param _settlementTime The settlement time at which the strike price is compared to the underlying asset price
     * @param _collateralToken The address of the ERC20 token used for collateral
     * @param _collateralAmount The amount of the collateral asset to be deposited by both parties
     * @param _isPartyALong The position of the deploying user (partyA) - if true they are long, if false they are short
     * param _feedIds The Chainlink Data Streams ID(s)
     * @notice These constructor parameters are intended to be set when the createCustomDerivative()
     * in the DerivativeFactory contract is called.
     */
    constructor(
        address payable _partyA,
        address payable _verifier,
        uint256 _strikePrice,
        uint256 _settlementTime,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong,
        string[] memory _feedIds
    ) {
        if (_partyA == address(0)) revert CustomDerivative__InvalidAddress();
        if (_verifier == address(0)) revert CustomDerivative__InvalidAddress();
        if (_strikePrice == 0) revert CustomDerivative__NeedsToBeMoreThanZero();
        if (_settlementTime < block.timestamp) revert CustomDerivative__SettlementTimeNeedsToBeInFuture();
        if (_collateralToken == address(0)) revert CustomDerivative__InvalidAddress();
        if (_collateralAmount == 0) revert CustomDerivative__NeedsToBeMoreThanZero();
        partyA = _partyA;
        verifier = IVerifierProxy(_verifier);
        strikePrice = _strikePrice;
        settlementTime = _settlementTime;
        collateralToken = IERC20(_collateralToken);
        collateralAmount = _collateralAmount;
        isPartyALong = _isPartyALong;
        counterpartyAgreed = false;
        contractSettled = false;
        feedIds = _feedIds;
    }

    //////////////////////////////////////
    //////// Deposit Collateral /////////
    ////////////////////////////////////

    /**
     * @notice This function is called by agreeToContractAndDeposit()
     * and sets the msg.sender as the contract's counterparty (partyB)
     */
    function _agreeToContract() private {
        if (counterpartyAgreed) revert CustomDerivative__CounterpartyAlreadyAgreed();
        address sender = msg.sender;
        if (sender == partyA) revert CustomDerivative__AddressCannotBeBothParties();
        partyB = payable(sender);
        counterpartyAgreed = true;
        emit CounterpartyEntered(sender);
    }

    /**
     * @notice This function is called by the depositCollateralPartyA()
     * and agreeToContractAndDeposit() functions, which are called by
     * parties A and B respectively.
     * @param amount The amount of collateral to deposit.
     * The function reverts if not enough is sent and refunds any excess.
     */
    function _depositCollateral(uint256 amount) private {
        address sender = msg.sender;
        uint256 _collateralAmount = collateralAmount;
        if (amount < _collateralAmount) revert CustomDerivative__NotEnoughCollateral();
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();

        if (!collateralToken.transferFrom(sender, address(this), amount)) revert CustomDerivative__TransferFailed();
        uint256 excess = amount - _collateralAmount;
        if (excess > 0) {
            if (!collateralToken.transfer(sender, excess)) revert CustomDerivative__TransferFailed();
        }
        if (sender == partyA) {
            partyACollateral = amount;
        } else {
            partyBCollateral = amount;
        }

        emit CollateralDeposited(sender, amount);
    }

    /**
     * @notice This function can only be called by partyA - the user who set the terms and
     * deployed the contract - to deposit their collateral.
     * @param amount The amount of collateral to deposit.
     * The function passes this amount to the _depositCollateral() function.
     */
    function depositCollateralPartyA(uint256 amount) external notSettledOrCancelled {
        if (msg.sender != partyA) revert CustomDerivative__OnlyDepositsByPartyA();
        _depositCollateral(amount);
    }

    /**
     * @notice This function is to be called by a voluntary counterparty who agrees to
     * the terms of the contract, but takes an opposing position to the deployer.
     * @param amount The amount of collateral to deposit.
     * The function passes this amount to the _depositCollateral() function
     * after calling _agreeToContract().
     */
    function agreeToContractAndDeposit(uint256 amount) external notSettledOrCancelled {
        _agreeToContract();
        _depositCollateral(amount);
    }

    /////////////////////////////////
    //////// Settlement ////////////
    ///////////////////////////////

    /**
     * @notice This function checks if the settlement time has been reached using Chainlink Automation.
     * @dev This Chainlink Automation implementation uses custom logic that is evaluated off-chain.
     * @return upkeepNeeded This will be true when the settlement time has been reached.
     */
    function checkUpkeep(bytes calldata /* checkData */ )
        external
        view
        cannotExecute
        notSettledOrCancelled
        returns (bool, bytes memory /* performData */ )
    {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        if (partyACollateral == 0 || partyBCollateral == 0) revert CustomDerivative__CollateralNotFullyDeposited();
        revert StreamsLookup(STRING_DATASTREAMS_FEEDLABEL, feedIds, STRING_DATASTREAMS_QUERYLABEL, settlementTime, "");
    }

    function checkCallback(bytes[] calldata values, bytes calldata extraData)
        external
        view
        cannotExecute
        notSettledOrCancelled
        returns (bool, bytes memory)
    {
        return (true, abi.encode(values, extraData));
    }

    /**
     * @notice This function uses Chainlink Automation to call the settleContract() function
     * when checkUpkeep() returns true.
     */
    function performUpkeep(bytes calldata performData) external notSettledOrCancelled {
        (bytes[] memory signedReports,) = abi.decode(performData, (bytes[], bytes));

        bytes memory report = signedReports[0];

        (, bytes memory reportData) = abi.decode(report, (bytes32[3], bytes));

        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));
        IRewardManager rewardManager = IRewardManager(address(feeManager.i_rewardManager()));
        address feeTokenAddress = feeManager.i_linkAddress();
        (ChainlinkCommon.Asset memory fee,,) = feeManager.getFeeAndReward(address(this), reportData, feeTokenAddress);
        IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);

        bytes memory verifiedReportData = verifier.verify(report, abi.encode(feeTokenAddress));

        BasicReport memory verifiedReport = abi.decode(verifiedReportData, (BasicReport));

        settleContract(verifiedReport.price);
    }

    /**
     * @notice This function settles the contract. It can only be called after the settlementTime has passed
     * and if both parties have deposited their collateral.
     * It pays out both parties collateral to the party who's long or short position was correct.
     * @dev Chainlink Data Streams are used to retrieve the price of the underlying asset.
     * @param price This is the price retrieved by Data Streams and passed to this function by performUpkeep().
     * @notice A 2% fee is taken from the total collateral and sent to the developer address
     * for every successful derivative settlement.
     */
    function settleContract(int192 price) private notSettledOrCancelled {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        if (partyACollateral == 0 || partyBCollateral == 0) revert CustomDerivative__CollateralNotFullyDeposited();

        uint256 finalPrice = uint256(int256(price));
        contractSettled = true;
        uint256 totalCollateral = partyACollateral + partyBCollateral;
        address winner;
        if (
            (isPartyALong && finalPrice >= uint256(strikePrice)) || (!isPartyALong && finalPrice < uint256(strikePrice))
        ) {
            winner = partyA;
        } else {
            winner = partyB;
        }

        uint256 developerFee = (totalCollateral * DEVELOPER_FEE_PERCENTAGE) / 100;
        uint256 winnerAmount = totalCollateral - developerFee;
        if (!collateralToken.transfer(DEVELOPER, developerFee)) revert CustomDerivative__TransferFailed();
        if (!collateralToken.transfer(winner, winnerAmount)) revert CustomDerivative__TransferFailed();

        emit ContractSettled(finalPrice);
    }

    ////////////////////////////////////
    ///////// Cancel Contract /////////
    //////////////////////////////////

    /**
     * @notice This function cancels the contract. It can only be called if both parties agree
     * and the contract hasn't already reached the time of settlement.
     */
    function _cancelContract() private {
        contractCancelled = true;
        if (!collateralToken.transfer(partyA, partyACollateral)) revert CustomDerivative__TransferFailed();
        if (!collateralToken.transfer(partyB, partyBCollateral)) revert CustomDerivative__TransferFailed();
        emit ContractCancelled();
    }

    /**
     * @notice This function allows Party A to request cancellation of the contract.
     * If Party B has already requested cancellation, this function will call _cancelContract()
     */
    function setCancelPartyA() external notSettledOrCancelled {
        if (msg.sender != partyA) revert CustomDerivative__OnlyPartyACanCall();
        partyACancel = true;
        if (partyBCancel) {
            _cancelContract();
        } else {
            emit PartyRequestedCancellation(msg.sender);
        }
    }

    /**
     * @notice This function allows Party B to request cancellation of the contract.
     * If Party A has already requested cancellation, this function will call _cancelContract()
     */
    function setCancelPartyB() external notSettledOrCancelled {
        if (msg.sender != partyB) revert CustomDerivative__OnlyPartyBCanCall();
        partyBCancel = true;
        if (partyACancel) {
            _cancelContract();
        } else {
            emit PartyRequestedCancellation(msg.sender);
        }
    }

    /**
     * @notice This function allows either party to cancel the contract and withdraw their deposit
     * if the settlement time has been reached and a counterparty never deposited any collateral.
     */
    function cancelDueToIncompleteDeposit() external {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        uint256 _partyACollateral = partyACollateral;
        uint256 _partyBCollateral = partyBCollateral;
        uint256 _collateralAmount = collateralAmount;
        if (_partyACollateral >= _collateralAmount && _partyBCollateral >= _collateralAmount) {
            revert CustomDerivative__CollateralFullyDeposited();
        }

        if (_partyACollateral > 0) {
            partyACollateral = 0;
            if (!collateralToken.transfer(partyA, _partyACollateral)) revert CustomDerivative__TransferFailed();
        }

        if (_partyBCollateral > 0) {
            partyBCollateral = 0;
            if (!collateralToken.transfer(partyB, _partyBCollateral)) revert CustomDerivative__TransferFailed();
        }

        contractCancelled = true;
        emit ContractCancelled();
    }
}
