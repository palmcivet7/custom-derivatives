// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract CustomDerivative {
    error CustomDerivative__CounterpartyAlreadyAgreed();
    error CustomDerivative__AddressCannotBeBothParties();
    error CustomDerivative__OnlyPartiesCanDeposit();
    error CustomDerivative__ContractAlreadySettled();
    error CustomDerivative__OnlyDepositsByPartyA();
    error CustomDerivative__NotEnoughCollateral();
    error CustomDerivative__TransferFailed();
    error CustomDerivative__CounterpartyHasntAgreed();
    error CustomDerivative__SettlementTimeNotReached();
    error CustomDerivative__OnlyPartiesCanWithdraw();
    error CustomDerivative__OnlyPartyACanCall();
    error CustomDerivative__OnlyPartyBCanCall();
    error CustomDerivative__BothPartiesNeedToAgreeToCancel();
    error CustomDerivative__ContractCancelled();
    error CustomDerivative__ContractNotCancelled();

    event CounterpartyEntered(address partyB);
    event CollateralDeposited(address depositor, uint256 amount);
    event ContractSettled(uint256 finalPrice);
    event ContractCancelled();
    event CollateralWithdrawn(address withdrawer, uint256 amount);
    event PartyRequestedCancellation(address party);

    address payable public partyA;
    address payable public partyB;

    IPriceFeed public priceFeed;
    uint256 public strikePrice;
    uint256 public settlementTime;
    uint256 public cancellationPeriod;
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
        uint256 _cancellationPeriod,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong
    ) {
        partyA = _partyA;
        priceFeed = IPriceFeed(_priceFeed);
        strikePrice = _strikePrice;
        settlementTime = _settlementTime;
        cancellationPeriod = _cancellationPeriod;
        collateralToken = IERC20(_collateralToken);
        collateralAmount = _collateralAmount;
        isPartyALong = _isPartyALong;
        counterpartyAgreed = false;
        contractSettled = false;
    }

    modifier notSettledOrCancelled() {
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();
        if (contractCancelled) revert CustomDerivative__ContractCancelled();
        _;
    }

    function _agreeToContract() private {
        if (counterpartyAgreed) revert CustomDerivative__CounterpartyAlreadyAgreed();
        address sender = msg.sender;
        if (sender == partyA) revert CustomDerivative__AddressCannotBeBothParties();
        partyB = payable(sender);
        counterpartyAgreed = true;
        emit CounterpartyEntered(sender);
    }

    function _depositCollateral(uint256 amount) private {
        address _partyA = partyA;
        address _partyB = partyB;
        address sender = msg.sender;
        if (sender != _partyA || sender != _partyB) revert CustomDerivative__OnlyPartiesCanDeposit();
        if (amount < collateralAmount) revert CustomDerivative__NotEnoughCollateral();
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();

        if (!collateralToken.transferFrom(sender, address(this), amount)) revert CustomDerivative__TransferFailed();
        if (sender == _partyA) {
            partyACollateral = amount;
        } else {
            partyBCollateral = amount;
        }

        emit CollateralDeposited(sender, amount);
    }

    function depositCollateralPartyA(uint256 amount) external {
        if (msg.sender != partyA) revert CustomDerivative__OnlyDepositsByPartyA();
        _depositCollateral(amount);
    }

    function agreeToContractAndDeposit(uint256 amount) external {
        _agreeToContract();
        _depositCollateral(amount);
    }

    function settleContract() external notSettledOrCancelled {
        if (block.timestamp < settlementTime) revert CustomDerivative__SettlementTimeNotReached();
        if (!counterpartyAgreed) revert CustomDerivative__CounterpartyHasntAgreed();

        uint256 finalPrice = priceFeed.getLatestPrice();
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

    // Allow parties to withdraw their collateral if the contract is canceled
    function withdrawCollateral() external {
        if (!contractCancelled) revert CustomDerivative__ContractNotCancelled();
        if (msg.sender != partyA || msg.sender != partyB) revert CustomDerivative__OnlyPartiesCanWithdraw();
        if (contractSettled) revert CustomDerivative__ContractAlreadySettled();

        uint256 amount;
        if (msg.sender == partyA) {
            amount = partyACollateral;
            partyACollateral = 0;
            if (!collateralToken.transfer(partyA, partyACollateral)) revert CustomDerivative__TransferFailed();
        } else {
            amount = partyBCollateral;
            partyBCollateral = 0;
            if (!collateralToken.transfer(partyB, partyBCollateral)) revert CustomDerivative__TransferFailed();
        }

        emit CollateralWithdrawn(msg.sender, amount);
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
}
