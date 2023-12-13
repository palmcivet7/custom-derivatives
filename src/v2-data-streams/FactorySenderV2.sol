// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FactorySenderV2 is Ownable {
    error FactorySender__DestinationChainNotAllowlisted(uint64 destinationChainSelector);
    error FactorySender__NothingToWithdraw();
    error FactorySender__NoLinkToWithdraw();
    error FactorySender__LinkTransferFailed();
    error FactorySender__TransferFailed();

    address public immutable i_link;
    address public immutable i_router;
    mapping(uint64 chainSelector => bool isAllowlisted) public s_allowlistedDestinationChains;

    constructor(address _link, address _router) {
        i_link = _link;
        i_router = _router;
    }

    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!s_allowlistedDestinationChains[_destinationChainSelector]) {
            revert FactorySender__DestinationChainNotAllowlisted(_destinationChainSelector);
        }
        _;
    }

    function allowlistDestinationChain(uint64 _destinationChainSelector, bool allowed) external onlyOwner {
        s_allowlistedDestinationChains[_destinationChainSelector] = allowed;
    }

    function createCrossChainCustomDerivative(
        address _receiver,
        uint64 _destinationChainSelector,
        address _verifier,
        uint256 _strikePrice,
        uint256 _settlementTime,
        address _collateralToken,
        uint256 _collateralAmount,
        bool _isPartyALong,
        string[] memory _feedIds
    ) public onlyAllowlistedDestinationChain(_destinationChainSelector) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(
                payable(msg.sender),
                _verifier,
                _strikePrice,
                _settlementTime,
                _collateralToken,
                _collateralAmount,
                _isPartyALong,
                _feedIds
                ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 4000000})),
            feeToken: i_link
        });

        uint256 fees = IRouterClient(i_router).getFee(_destinationChainSelector, message);
        LinkTokenInterface(i_link).approve(address(i_router), fees);
        IRouterClient(i_router).ccipSend(_destinationChainSelector, message);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert FactorySender__NothingToWithdraw();

        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) revert FactorySender__TransferFailed();
    }

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(i_link).balanceOf(address(this));
        if (balance == 0) revert FactorySender__NoLinkToWithdraw();

        if (!LinkTokenInterface(i_link).transfer(msg.sender, balance)) revert FactorySender__LinkTransferFailed();
    }
}
