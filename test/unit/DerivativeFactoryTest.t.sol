// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDerivativeFactory} from "../../script/DeployDerivativeFactory.s.sol";
import {DerivativeFactory} from "../../src/DerivativeFactory.sol";
import {CustomDerivative} from "../../src/CustomDerivative.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";

contract DerivativeFactoryTest is Test {
    DerivativeFactory derivativeFactory;
    CustomDerivative customDerivative;

    uint8 public constant DECIMALS = 8;
    int256 public constant ASSET_USD_PRICE = 2000e8;

    address priceFeed; // underlying asset
    uint256 public constant STRIKE_PRICE = 1900e8;
    uint256 public settlementTime = block.timestamp + 50;
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

    function setUp() external {
        DeployDerivativeFactory deployer = new DeployDerivativeFactory();
        (derivativeFactory) = deployer.run();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, ASSET_USD_PRICE);
        priceFeed = address(mockPriceFeed);
        MockUSDC mockUsdc = new MockUSDC();
        collateralToken = address(mockUsdc);
    }

    modifier longContract() {
        vm.prank(PARTY_A);
        customLong = derivativeFactory.createCustomDerivative(
            priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, long
        );
        customDerivative = CustomDerivative(customLong);
        _;
    }

    modifier shortContract() {
        vm.prank(PARTY_A);
        customShort = derivativeFactory.createCustomDerivative(
            priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, notLong
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
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT - 1);
        assertEq(customDerivative.partyB(), address(PARTY_B));
        assertEq(customDerivative.counterpartyAgreed(), true);
        assertEq(customDerivative.partyBCollateral(), COLLATERAL_AMOUNT);
        vm.expectRevert(CustomDerivative.CustomDerivative__CounterpartyAlreadyAgreed.selector);
        customDerivative.agreeToContractAndDeposit(COLLATERAL_AMOUNT);
        vm.stopPrank();
    }
}
