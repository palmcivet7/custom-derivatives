// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDerivativeFactory} from "../../script/DeployDerivativeFactory.s.sol";
import {DerivativeFactory} from "../../src/DerivativeFactory.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {MockUSDC} from "../mocks/MockUSDC.sol";

contract DerivativeFactoryTest is Test {
    DerivativeFactory derivativeFactory;

    uint8 public constant DECIMALS = 8;
    int256 public constant ASSET_USD_PRICE = 2000e8;

    address priceFeed; // underlying asset
    uint256 public constant STRIKE_PRICE = 1900e8;
    uint256 public settlementTime = block.timestamp + 50;
    address collateralToken;
    uint256 public constant COLLATERAL_AMOUNT = 4000e8;
    bool long = true;
    bool notLong;

    function setUp() external {
        DeployDerivativeFactory deployer = new DeployDerivativeFactory();
        (derivativeFactory) = deployer.run();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, ASSET_USD_PRICE);
        priceFeed = address(mockPriceFeed);
        MockUSDC mockUsdc = new MockUSDC();
        collateralToken = address(mockUsdc);
    }

    modifier longContract() {
        derivativeFactory.createCustomDerivative(
            priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, long
        );
        _;
    }

    modifier shortContract() {
        derivativeFactory.createCustomDerivative(
            priceFeed, STRIKE_PRICE, settlementTime, collateralToken, COLLATERAL_AMOUNT, notLong
        );
        _;
    }

    function testConstructorPropertiesSetCorrectly() public longContract {}
}
