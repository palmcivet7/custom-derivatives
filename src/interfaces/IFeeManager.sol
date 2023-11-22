// SPDX-License-Identifier: MIT

import {ChainlinkCommon} from "../libraries/ChainlinkCommon.sol";

pragma solidity ^0.8.19;

interface IFeeManager {
    function getFeeAndReward(address subscriber, bytes memory report, address quoteAddress)
        external
        returns (ChainlinkCommon.Asset memory, ChainlinkCommon.Asset memory, uint256);

    function i_linkAddress() external view returns (address);

    function i_nativeAddress() external view returns (address);

    function i_rewardManager() external view returns (address);
}
