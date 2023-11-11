// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CustomDerivative {
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

    event CounterpartyEntered(address partyB);
    event CollateralDeposited(address depositor, uint256 amount);
    event ContractSettled(uint256 finalPrice);
    event ContractCancelled();
    event CollateralWithdrawn(address withdrawer, uint256 amount);
    event PartyRequestedCancellation(address party);

    address payable public partyA;
    address payable public partyB;

    AggregatorV3Interface public priceFeed;
    uint256 public strikePrice;
    uint256 public settlementTime;
    IERC20 public collateralToken;

    bool public isPartyALong;
    bool public counterpartyAgreed;
    bool public contractSettled;
    bool public partyACancel;
    bool public partyBCancel;
    bool public contractCancelled;

    uint256 public collateralAmount;
    uint256 public partyACollateral;
    uint256 public partyBCollateral;

    constructor(
        address payable _partyA,
        address _priceFeed,
        uint256 _strikePrice,
        uint256 _settlementTime,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong
    ) {
        partyA = _partyA;
        priceFeed = AggregatorV3Interface(_priceFeed);
        strikePrice = _strikePrice;
        settlementTime = _settlementTime;
        collateralToken = IERC20(_collateralToken);
        collateralAmount = _collateralAmount;
        isPartyALong = _isPartyALong;
        counterpartyAgreed = false;
        contractSettled = false;
    }

    //////////////////////////////
    ///////// Modifiers /////////
    ////////////////////////////

    modifier notSettledOrCancelled() {
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();
        if (contractCancelled) revert CustomDerivative__ContractCancelled();
        _;
    }

    //////////////////////////////////////
    //////// Deposit Collateral /////////
    ////////////////////////////////////

    function _agreeToContract() private {
        if (counterpartyAgreed) revert CustomDerivative__CounterpartyAlreadyAgreed();
        address sender = msg.sender;
        if (sender == partyA) revert CustomDerivative__AddressCannotBeBothParties();
        partyB = payable(sender);
        counterpartyAgreed = true;
        emit CounterpartyEntered(sender);
    }

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

    function depositCollateralPartyA(uint256 amount) external notSettledOrCancelled {
        if (msg.sender != partyA) revert CustomDerivative__OnlyDepositsByPartyA();
        _depositCollateral(amount);
    }

    function agreeToContractAndDeposit(uint256 amount) external notSettledOrCancelled {
        _agreeToContract();
        _depositCollateral(amount);
    }

    /////////////////////////////////
    //////// Settlement ////////////
    ///////////////////////////////

    function settleContract() external notSettledOrCancelled {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        if (partyACollateral == 0 || partyBCollateral == 0) revert CustomDerivative__CollateralNotFullyDeposited();

        (, int256 price,,,) = priceFeed.latestRoundData();
        uint256 finalPrice = uint256(price);
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

        if (!collateralToken.transfer(winner, totalCollateral)) revert CustomDerivative__TransferFailed();
        emit ContractSettled(finalPrice);
    }

    ////////////////////////////////////
    ///////// Cancel Contract /////////
    //////////////////////////////////

    function _cancelContract() private {
        contractCancelled = true;
        if (!collateralToken.transfer(partyA, partyACollateral)) revert CustomDerivative__TransferFailed();
        if (!collateralToken.transfer(partyB, partyBCollateral)) revert CustomDerivative__TransferFailed();
        emit ContractCancelled();
    }

    function setCancelPartyA() external notSettledOrCancelled {
        if (msg.sender != partyA) revert CustomDerivative__OnlyPartyACanCall();
        partyACancel = true;
        emit PartyRequestedCancellation(msg.sender);
        if (partyBCancel) {
            _cancelContract();
        }
    }

    function setCancelPartyB() external notSettledOrCancelled {
        if (msg.sender != partyB) revert CustomDerivative__OnlyPartyBCanCall();
        partyBCancel = true;
        emit PartyRequestedCancellation(msg.sender);
        if (partyACancel) {
            _cancelContract();
        }
    }

    function cancelDueToIncompleteDeposit() external {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        uint256 _partyACollateral = partyACollateral;
        uint256 _partyBCollateral = partyBCollateral;
        uint256 _collateralAmount = collateralAmount;
        if (_partyACollateral >= _collateralAmount && _partyBCollateral >= _collateralAmount) {
            revert CustomDerivative__CollateralFullyDeposited();
        }

        // If cancellation period is reached and one of the parties has not deposited
        // the full collateral, allow the other party to withdraw their collateral
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
