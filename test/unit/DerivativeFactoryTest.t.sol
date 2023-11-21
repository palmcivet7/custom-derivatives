// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDerivativeFactory} from "../../script/v1-data-feeds/DeployDerivativeFactory.s.sol";
import {DerivativeFactory} from "../../src/v1-data-feeds/DerivativeFactory.sol";
import {CustomDerivative} from "../../src/v1-data-feeds/CustomDerivative.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {HelperReceiverConfig} from "../../script/v1-data-feeds/HelperReceiverConfig.s.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract DerivativeFactoryTest is Test {
    DerivativeFactory derivativeFactory;
    CustomDerivative customDerivative;
    HelperReceiverConfig helperConfig;

    address linkAddress;
    address routerAddress;
    address registrarAddress;

    uint8 public constant DECIMALS = 8;
    int256 public constant ASSET_USD_PRICE = 2000e8;

    address priceFeed; // underlying asset
    uint256 public constant STRIKE_PRICE = 1900e8;
    uint256 public settlementTime = block.timestamp + 10 minutes;
    address collateralToken;
    uint256 public constant COLLATERAL_AMOUNT = 4000e8;
    bool long = true;
    bool notLong;

    address customLong;
    address customShort;

    address public PARTY_A = makeAddr("PARTY_A");
    address public PARTY_B = makeAddr("PARTY_B");
    address public RANDOM_USER = makeAddr("RANDOM_USER");
    uint256 public USER_BALANCE = 1000 ether;
    address private constant DEVELOPER = 0xe0141DaBb4A8017330851f99ff8fc34aa619BBFD;
    uint256 public constant DEVELOPER_FEE_PERCENTAGE = 2; // 2%

    function setUp() external {
        DeployDerivativeFactory deployer = new DeployDerivativeFactory();
        (derivativeFactory, helperConfig) = deployer.run();
        (linkAddress, routerAddress, registrarAddress) = helperConfig.activeNetworkConfig();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, ASSET_USD_PRICE);
        priceFeed = address(mockPriceFeed);
        MockUSDC mockUsdc = new MockUSDC();
        collateralToken = address(mockUsdc);
        MockLinkToken(linkAddress).setBalance(address(derivativeFactory), USER_BALANCE);
    }

    modifier longContract() {
        vm.prank(PARTY_A);
        customLong = derivativeFactory.createCustomDerivative(
            payable(PARTY_A), priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, long
        );
        customDerivative = CustomDerivative(customLong);
        _;
    }

    modifier longContractDoubleStrike() {
        vm.prank(PARTY_A);
        customLong = derivativeFactory.createCustomDerivative(
            payable(PARTY_A), priceFeed, STRIKE_PRICE * 2, settlementTime, collateralToken, COLLATERAL_AMOUNT, long
        );
        customDerivative = CustomDerivative(customLong);
        _;
    }

    modifier shortContract() {
        vm.prank(PARTY_A);
        customShort = derivativeFactory.createCustomDerivative(
            payable(PARTY_A), priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, notLong
        );
        customDerivative = CustomDerivative(customShort);
        _;
    }

    modifier shortContractDoubleStrike() {
        vm.prank(PARTY_A);
        customShort = derivativeFactory.createCustomDerivative(
            payable(PARTY_A), priceFeed, STRIKE_PRICE * 2, settlementTime, collateralToken, COLLATERAL_AMOUNT, notLong
        );
        customDerivative = CustomDerivative(customShort);
        _;
    }

    function testConstructorPropertiesSetCorrectly() public longContract {
        assertEq(customDerivative.partyA(), address(PARTY_A));
        assertEq(address(customDerivative.priceFeed()), priceFeed);
        assertEq(customDerivative.strikePrice(), STRIKE_PRICE);
        assertEq(customDerivative.settlementTime(), settlementTime);
        assertEq(address(customDerivative.collateralToken()), collateralToken);
        assertEq(customDerivative.collateralAmount(), COLLATERAL_AMOUNT);
        assertEq(customDerivative.isPartyALong(), long);
    }

    modifier fundUsersAndApproveContract() {
        vm.deal(address(PARTY_A), USER_BALANCE);
        vm.deal(address(PARTY_B), USER_BALANCE);
        vm.startPrank(msg.sender);
        MockUSDC(collateralToken).mintTokens(10000 ether);
        MockUSDC(collateralToken).transfer(address(PARTY_A), USER_BALANCE);
        MockUSDC(collateralToken).transfer(address(PARTY_B), USER_BALANCE);
        vm.stopPrank();
        vm.prank(address(PARTY_A));
        MockUSDC(collateralToken).approve(address(customDerivative), USER_BALANCE);
        vm.prank(address(PARTY_B));
        MockUSDC(collateralToken).approve(address(customDerivative), USER_BALANCE);
        vm.stopPrank();
        _;
    }

    //////////////////////////////////////
    //////// Deposit Collateral /////////
    ////////////////////////////////////

    function testDepositCollateralPartyARevertsIfNotPartyA() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_B);
        vm.expectRevert(CustomDerivative.CustomDerivative__OnlyDepositsByPartyA.selector);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    function test_depositCollateralRevertsIfNotEnoughCollateral() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__NotEnoughCollateral.selector);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT - 1);
        vm.stopPrank();
    }

    function testAgreeToContractAndDeposit() public longContract fundUsersAndApproveContract {
        vm.prank(PARTY_B);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        assertEq(customDerivative.partyB(), address(PARTY_B));
        assertEq(customDerivative.counterpartyAgreed(), true);
        assertEq(customDerivative.partyBCollateral(), COLLATERAL_AMOUNT);
    }

    function testAgreeToContractAndDepositRevertsIfAlreadySet() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_B);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        assertEq(customDerivative.partyB(), address(PARTY_B));
        assertEq(customDerivative.counterpartyAgreed(), true);
        assertEq(customDerivative.partyBCollateral(), COLLATERAL_AMOUNT);
        vm.expectRevert(CustomDerivative.CustomDerivative__CounterpartyAlreadyAgreed.selector);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    function testAgreeToContractAndDepositRevertsIfPartyA() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__AddressCannotBeBothParties.selector);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    function testAgreeToContractAndDepositRevertsIfNotEnoughCollateral()
        public
        longContract
        fundUsersAndApproveContract
    {
        vm.startPrank(PARTY_B);
        vm.expectRevert(CustomDerivative.CustomDerivative__NotEnoughCollateral.selector);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT - 1);
        vm.stopPrank();
    }

    function testDepositCollateralPartyARefundsExcess() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT + 1);
        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        assertEq(endingBalance, startingBalance - COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    function testDepositCollateralPartyA() public longContract fundUsersAndApproveContract {
        vm.prank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        assertEq(customDerivative.partyACollateral(), COLLATERAL_AMOUNT);
    }

    /////////////////////////////////
    //////// Settlement ////////////
    ///////////////////////////////

    function testSettleContractRevertsIfTimeNotReached() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__SettlementTimeNotReached.selector);
        customDerivative.settleContract();
        vm.stopPrank();
    }

    function testSettleContractRevertsIfCollateralNotFullyDeposited() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        vm.warp(block.timestamp + 11 minutes);
        vm.expectRevert(CustomDerivative.CustomDerivative__CollateralNotFullyDeposited.selector);
        customDerivative.settleContract();
        vm.stopPrank();
    }

    modifier bothPartiesDeposited() {
        vm.prank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        vm.prank(PARTY_B);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        _;
    }

    function testSettleContractPaysPartyAWhenALong()
        public
        longContract
        fundUsersAndApproveContract
        bothPartiesDeposited
    {
        vm.warp(block.timestamp + 11 minutes);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        uint256 devStartingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        vm.prank(PARTY_A);
        customDerivative.settleContract();

        uint256 developerFee = ((COLLATERAL_AMOUNT * 2) * DEVELOPER_FEE_PERCENTAGE) / 100;
        uint256 winnerAmount = (COLLATERAL_AMOUNT * 2) - developerFee;

        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        uint256 devEndingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        assertEq(startingBalance + winnerAmount, endingBalance);
        assertEq(devStartingBalance + developerFee, devEndingBalance);
        assertEq(customDerivative.contractSettled(), true);
    }

    function testSettleContractPaysPartyBWhenAShort()
        public
        shortContract
        fundUsersAndApproveContract
        bothPartiesDeposited
    {
        vm.warp(block.timestamp + 11 minutes);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        uint256 devStartingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        vm.prank(PARTY_A);
        customDerivative.settleContract();

        uint256 developerFee = ((COLLATERAL_AMOUNT * 2) * DEVELOPER_FEE_PERCENTAGE) / 100;
        uint256 winnerAmount = (COLLATERAL_AMOUNT * 2) - developerFee;

        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        uint256 devEndingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        assertEq(startingBalance + winnerAmount, endingBalance);
        assertEq(devStartingBalance + developerFee, devEndingBalance);
        assertEq(customDerivative.contractSettled(), true);
    }

    function testSettleContractPaysPartyBWhenALong()
        public
        longContractDoubleStrike
        fundUsersAndApproveContract
        bothPartiesDeposited
    {
        vm.warp(block.timestamp + 11 minutes);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        uint256 devStartingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        vm.prank(PARTY_A);
        customDerivative.settleContract();
        uint256 developerFee = ((COLLATERAL_AMOUNT * 2) * DEVELOPER_FEE_PERCENTAGE) / 100;
        uint256 winnerAmount = (COLLATERAL_AMOUNT * 2) - developerFee;
        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        uint256 devEndingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        assertEq(startingBalance + winnerAmount, endingBalance);
        assertEq(devStartingBalance + developerFee, devEndingBalance);
        assertEq(customDerivative.contractSettled(), true);
    }

    function testSettleContractPaysPartyAWhenAShort()
        public
        shortContractDoubleStrike
        fundUsersAndApproveContract
        bothPartiesDeposited
    {
        vm.warp(block.timestamp + 11 minutes);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        vm.prank(PARTY_A);
        uint256 devStartingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        customDerivative.settleContract();
        uint256 developerFee = ((COLLATERAL_AMOUNT * 2) * DEVELOPER_FEE_PERCENTAGE) / 100;
        uint256 winnerAmount = (COLLATERAL_AMOUNT * 2) - developerFee;
        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        uint256 devEndingBalance = MockUSDC(collateralToken).balanceOf(DEVELOPER);
        assertEq(startingBalance + winnerAmount, endingBalance);
        assertEq(devStartingBalance + developerFee, devEndingBalance);
        assertEq(customDerivative.contractSettled(), true);
    }

    function testSettleContractRevertsIfAlreadySettled()
        public
        longContract
        fundUsersAndApproveContract
        bothPartiesDeposited
    {
        vm.warp(block.timestamp + 11 minutes);
        vm.startPrank(PARTY_A);
        customDerivative.settleContract();
        assertEq(customDerivative.contractSettled(), true);
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractAlreadySettled.selector);
        customDerivative.settleContract();
    }

    ////////////////////////////////////
    ///////// Cancel Contract /////////
    //////////////////////////////////

    function testSetCancelPartyA() public longContract fundUsersAndApproveContract {
        vm.prank(PARTY_A);
        customDerivative.setCancelPartyA();
        assertEq(customDerivative.partyACancel(), true);
    }

    function testSetCancelPartyARevertsIfNotPartyA() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_B);
        vm.expectRevert(CustomDerivative.CustomDerivative__OnlyPartyACanCall.selector);
        customDerivative.setCancelPartyA();
        vm.stopPrank();
    }

    modifier depositCollateral() {
        vm.prank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        vm.prank(PARTY_B);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        _;
    }

    function testSetCancelPartyB() public longContract fundUsersAndApproveContract depositCollateral {
        vm.prank(PARTY_B);
        customDerivative.setCancelPartyB();
        assertEq(customDerivative.partyBCancel(), true);
    }

    function testSetCancelPartyBRevertsIfNotPartyB() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__OnlyPartyBCanCall.selector);
        customDerivative.setCancelPartyB();
        vm.stopPrank();
    }

    function test_cancelContract() public longContract fundUsersAndApproveContract depositCollateral {
        uint256 aStartingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        uint256 bStartingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        vm.prank(PARTY_A);
        customDerivative.setCancelPartyA();
        vm.prank(PARTY_B);
        customDerivative.setCancelPartyB();
        uint256 aEndingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        uint256 bEndingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        assertEq(customDerivative.contractCancelled(), true);
        assertEq(aStartingBalance + COLLATERAL_AMOUNT, aEndingBalance);
        assertEq(bStartingBalance + COLLATERAL_AMOUNT, bEndingBalance);
    }

    function testSetCancelPartyARevertsIfAlreadyCancelled()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
    {
        vm.prank(PARTY_B);
        customDerivative.setCancelPartyB();
        vm.startPrank(PARTY_A);
        customDerivative.setCancelPartyA();
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractCancelled.selector);
        customDerivative.setCancelPartyA();
    }

    function testSetCancelPartyBRevertsIfAlreadyCancelled()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
    {
        vm.prank(PARTY_A);
        customDerivative.setCancelPartyA();
        vm.startPrank(PARTY_B);
        customDerivative.setCancelPartyB();
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractCancelled.selector);
        customDerivative.setCancelPartyB();
    }

    modifier settleContract() {
        vm.warp(block.timestamp + 11 minutes);
        vm.prank(PARTY_A);
        customDerivative.settleContract();
        _;
    }

    function testSetCancelPartyARevertsIfAlreadySettled()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
        settleContract
    {
        vm.startPrank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractAlreadySettled.selector);
        customDerivative.setCancelPartyA();
        vm.stopPrank();
    }

    function testSetCancelPartyBRevertsIfAlreadySettled()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
        settleContract
    {
        vm.startPrank(PARTY_B);
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractAlreadySettled.selector);
        customDerivative.setCancelPartyB();
        vm.stopPrank();
    }

    modifier cancelContract() {
        vm.prank(PARTY_A);
        customDerivative.setCancelPartyA();
        vm.prank(PARTY_B);
        customDerivative.setCancelPartyB();
        _;
    }

    function testSettleContractRevertsIfCancelled()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
        cancelContract
    {
        vm.prank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__ContractCancelled.selector);
        customDerivative.settleContract();
    }

    function testCancelDueToIncompleteDepositRevertsIfSettlementTimeNotReached()
        public
        longContract
        fundUsersAndApproveContract
    {
        vm.startPrank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        vm.expectRevert(CustomDerivative.CustomDerivative__SettlementTimeNotReached.selector);
        customDerivative.cancelDueToIncompleteDeposit();
        vm.stopPrank();
    }

    function testCancelDueToIncompleteDepositRevertsIfCollateralFullyDeposited()
        public
        longContract
        fundUsersAndApproveContract
        depositCollateral
    {
        vm.warp(block.timestamp + 11 minutes);
        vm.prank(PARTY_A);
        vm.expectRevert(CustomDerivative.CustomDerivative__CollateralFullyDeposited.selector);
        customDerivative.cancelDueToIncompleteDeposit();
    }

    function testCancelDueToIncompleteDepositWorksForPartyA() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_A);
        customDerivative.depositCollateralPartyA(COLLATERAL_AMOUNT);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        vm.warp(block.timestamp + 11 minutes);
        customDerivative.cancelDueToIncompleteDeposit();
        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_A);
        vm.stopPrank();
        assertEq(startingBalance + COLLATERAL_AMOUNT, endingBalance);
    }

    function testCancelDueToIncompleteDepositWorksForPartyB() public longContract fundUsersAndApproveContract {
        vm.startPrank(PARTY_B);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        uint256 startingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        vm.warp(block.timestamp + 11 minutes);
        customDerivative.cancelDueToIncompleteDeposit();
        uint256 endingBalance = MockUSDC(collateralToken).balanceOf(PARTY_B);
        vm.stopPrank();
        assertEq(startingBalance + COLLATERAL_AMOUNT, endingBalance);
    }
}
