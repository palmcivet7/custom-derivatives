// DISCLAIMER: I know it is bad practice to include alchemy rpc and etherscan api.
//             They are just there temporarily for the duration of the hackathon
//             for the sake of simplicity. They will be deleted when the hackathon is finished.

export const CUSTOM_DERIVATIVE_ABI = [
  {
    inputs: [
      {
        internalType: "address payable",
        name: "_partyA",
        type: "address",
      },
      {
        internalType: "address",
        name: "_priceFeed",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_strikePrice",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_settlementTime",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_collateralToken",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_collateralAmount",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_isPartyALong",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "CustomDerivative__AddressCannotBeBothParties",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__BothPartiesNeedToAgreeToCancel",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CollateralFullyDeposited",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CollateralNotFullyDeposited",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractAlreadySettled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractCancelled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractNotCancelled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CounterpartyAlreadyAgreed",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__InvalidAddress",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__NeedsToBeMoreThanZero",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__NotEnoughCollateral",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyDepositsByPartyA",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartiesCanDeposit",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartyACanCall",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartyBCanCall",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__SettlementTimeNeedsToBeInFuture",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__SettlementTimeNotReached",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__TransferFailed",
    type: "error",
  },
  {
    inputs: [],
    name: "OnlySimulatedBackend",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "depositor",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "CollateralDeposited",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "withdrawer",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "CollateralWithdrawn",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [],
    name: "ContractCancelled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "finalPrice",
        type: "uint256",
      },
    ],
    name: "ContractSettled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "partyB",
        type: "address",
      },
    ],
    name: "CounterpartyEntered",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "party",
        type: "address",
      },
    ],
    name: "PartyRequestedCancellation",
    type: "event",
  },
  {
    inputs: [],
    name: "DEVELOPER_FEE_PERCENTAGE",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "agreeToContractAndDeposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "cancelDueToIncompleteDeposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "checkUpkeep",
    outputs: [
      {
        internalType: "bool",
        name: "upkeepNeeded",
        type: "bool",
      },
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "collateralAmount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "collateralToken",
    outputs: [
      {
        internalType: "contract IERC20",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "contractCancelled",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "contractSettled",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "counterpartyAgreed",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "depositCollateralPartyA",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "isPartyALong",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyA",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyACancel",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyACollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyB",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyBCancel",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyBCollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "performUpkeep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "priceFeed",
    outputs: [
      {
        internalType: "contract AggregatorV3Interface",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "setCancelPartyA",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "setCancelPartyB",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "settleContract",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "settlementTime",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "strikePrice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export const FUJI_FACTORY_SENDER_ADDRESS =
  "0x98be1c31Fb80d1760604775fa6027025E436ad70";

export const FUJI_FACTORY_SENDER_ABI = [
  {
    inputs: [
      { internalType: "address", name: "_link", type: "address" },
      { internalType: "address", name: "_router", type: "address" },
      { internalType: "address", name: "_priceFeed", type: "address" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  { inputs: [], name: "FactorySender__LinkTransferFailed", type: "error" },
  { inputs: [], name: "FactorySender__NoLinkToWithdraw", type: "error" },
  { inputs: [], name: "FactorySender__NotEnoughPayment", type: "error" },
  { inputs: [], name: "FactorySender__NothingToWithdraw", type: "error" },
  { inputs: [], name: "FactorySender__TransferFailed", type: "error" },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      { internalType: "address", name: "_receiver", type: "address" },
      {
        internalType: "uint64",
        name: "_destinationChainSelector",
        type: "uint64",
      },
      { internalType: "address", name: "_priceFeed", type: "address" },
      { internalType: "uint256", name: "_strikePrice", type: "uint256" },
      { internalType: "uint256", name: "_settlementTime", type: "uint256" },
      { internalType: "address", name: "_collateralToken", type: "address" },
      { internalType: "uint256", name: "_collateralAmount", type: "uint256" },
      { internalType: "bool", name: "_isPartyALong", type: "bool" },
    ],
    name: "createCrossChainCustomDerivative",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "getLatestPrice",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "link",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "priceFeed",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "router",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "newOwner", type: "address" }],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdrawLink",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export const SEPOLIA_FACTORY_RECEIVER_ADDRESS =
  "0xa76f758E860053b100184EcA3FaaCf37e6eA4f48";

export const SEPOLIA_FACTORY_RECEIVER_ABI = [
  {
    inputs: [
      { internalType: "address", name: "_link", type: "address" },
      { internalType: "address", name: "_router", type: "address" },
      { internalType: "address", name: "_registrar", type: "address" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "DerivativeFactory__AutomationRegistrationFailed",
    type: "error",
  },
  {
    inputs: [],
    name: "DerivativeFactory__LinkTransferAndCallFailed",
    type: "error",
  },
  { inputs: [], name: "DerivativeFactory__LinkTransferFailed", type: "error" },
  { inputs: [], name: "DerivativeFactory__NoLinkToWithdraw", type: "error" },
  {
    inputs: [{ internalType: "address", name: "router", type: "address" }],
    name: "InvalidRouter",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "derivativeContract",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "partyA",
        type: "address",
      },
    ],
    name: "DerivativeCreated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "upkeepID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "derivativeContract",
        type: "address",
      },
    ],
    name: "UpkeepRegistered",
    type: "event",
  },
  {
    inputs: [
      {
        components: [
          { internalType: "bytes32", name: "messageId", type: "bytes32" },
          {
            internalType: "uint64",
            name: "sourceChainSelector",
            type: "uint64",
          },
          { internalType: "bytes", name: "sender", type: "bytes" },
          { internalType: "bytes", name: "data", type: "bytes" },
          {
            components: [
              { internalType: "address", name: "token", type: "address" },
              { internalType: "uint256", name: "amount", type: "uint256" },
            ],
            internalType: "struct Client.EVMTokenAmount[]",
            name: "destTokenAmounts",
            type: "tuple[]",
          },
        ],
        internalType: "struct Client.Any2EVMMessage",
        name: "message",
        type: "tuple",
      },
    ],
    name: "ccipReceive",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address payable", name: "partyA", type: "address" },
      { internalType: "address", name: "priceFeed", type: "address" },
      { internalType: "uint256", name: "strikePrice", type: "uint256" },
      { internalType: "uint256", name: "settlementTime", type: "uint256" },
      { internalType: "address", name: "collateralToken", type: "address" },
      { internalType: "uint256", name: "collateralAmount", type: "uint256" },
      { internalType: "bool", name: "isPartyALong", type: "bool" },
    ],
    name: "createCustomDerivative",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "getRouter",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "link",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "registrar",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [{ internalType: "bytes4", name: "interfaceId", type: "bytes4" }],
    name: "supportsInterface",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "newOwner", type: "address" }],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdrawLink",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export const SEPOLIA_DESTINATION_CHAIN_SELECTOR = "16015286601757825753";

export const SEPOLIA_ETH_PRICE_FEED_ADDRESS =
  "0x694AA1769357215DE4FAC081bf1f309aDC325306";

export const SEPOLIA_MOCK_USDC_TOKEN_ADDRESS =
  "0x679dc61439EE95b27ac931a4e8b0943F25Ad0f54";

export const ETHERSCAN_API_KEY = "******YOUR_ETHERSCAN_API_KEY_HERE******";

export const ETHERSCAN_API_URL = "https://api-sepolia.etherscan.io/api";

export const SEPOLIA_RPC_URL = "******YOUR_SEPOLIA_RPC_URL_HERE******";

export const ERC20_ABI = [
  {
    inputs: [
      { internalType: "address", name: "to", type: "address" },
      { internalType: "uint256", name: "initSupply", type: "uint256" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, internalType: "address", name: "from", type: "address" },
      { indexed: true, internalType: "address", name: "to", type: "address" },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    inputs: [
      { internalType: "address", name: "owner", type: "address" },
      { internalType: "address", name: "spender", type: "address" },
    ],
    name: "allowance",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "spender", type: "address" },
      { internalType: "uint256", name: "amount", type: "uint256" },
    ],
    name: "approve",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "account", type: "address" }],
    name: "balanceOf",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "uint256", name: "amount", type: "uint256" }],
    name: "burn",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "decimals",
    outputs: [{ internalType: "uint8", name: "", type: "uint8" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "spender", type: "address" },
      { internalType: "uint256", name: "subtractedValue", type: "uint256" },
    ],
    name: "decreaseAllowance",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "spender", type: "address" },
      { internalType: "uint256", name: "addedValue", type: "uint256" },
    ],
    name: "increaseAllowance",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "to", type: "address" },
      { internalType: "uint256", name: "amount", type: "uint256" },
    ],
    name: "transfer",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "from", type: "address" },
      { internalType: "address", name: "to", type: "address" },
      { internalType: "uint256", name: "amount", type: "uint256" },
    ],
    name: "transferFrom",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export const FUJI_AVAX_PRICE_FEED_ADDRESS =
  "0x5498BB86BC934c8D34FDA08E81D444153d0D06aD";

export const ARBITRUM_SEPOLIA_RPC_URL =
  "https://sepolia-rollup.arbitrum.io/rpc";

export const ARBITRUM_SEPOLIA_MOCK_USDC_TOKEN_ADDRESS =
  "0xbd3f8ec76e5829a4a35ce369a19c7b53bcb14d98";

export const DATA_STREAMS_CUSTOM_DERIVATIVE_ABI = [
  {
    inputs: [
      {
        internalType: "address payable",
        name: "_partyA",
        type: "address",
      },
      {
        internalType: "address payable",
        name: "_verifier",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_strikePrice",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_settlementTime",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_collateralToken",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_collateralAmount",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_isPartyALong",
        type: "bool",
      },
      {
        internalType: "string[]",
        name: "_feedIds",
        type: "string[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "CustomDerivative__AddressCannotBeBothParties",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__BothPartiesNeedToAgreeToCancel",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CollateralFullyDeposited",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CollateralNotFullyDeposited",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractAlreadySettled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractCancelled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__ContractNotCancelled",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__CounterpartyAlreadyAgreed",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__InvalidAddress",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__NeedsToBeMoreThanZero",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__NotEnoughCollateral",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyDepositsByPartyA",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartiesCanDeposit",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartyACanCall",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__OnlyPartyBCanCall",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__SettlementTimeNeedsToBeInFuture",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__SettlementTimeNotReached",
    type: "error",
  },
  {
    inputs: [],
    name: "CustomDerivative__TransferFailed",
    type: "error",
  },
  {
    inputs: [],
    name: "OnlySimulatedBackend",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "feedParamKey",
        type: "string",
      },
      {
        internalType: "string[]",
        name: "feeds",
        type: "string[]",
      },
      {
        internalType: "string",
        name: "timeParamKey",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "time",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "extraData",
        type: "bytes",
      },
    ],
    name: "StreamsLookup",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "depositor",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "CollateralDeposited",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "withdrawer",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "CollateralWithdrawn",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [],
    name: "ContractCancelled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "finalPrice",
        type: "uint256",
      },
    ],
    name: "ContractSettled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "partyB",
        type: "address",
      },
    ],
    name: "CounterpartyEntered",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "party",
        type: "address",
      },
    ],
    name: "PartyRequestedCancellation",
    type: "event",
  },
  {
    inputs: [],
    name: "DEVELOPER_FEE_PERCENTAGE",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "STRING_DATASTREAMS_FEEDLABEL",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "STRING_DATASTREAMS_QUERYLABEL",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "agreeToContractAndDeposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "cancelDueToIncompleteDeposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "values",
        type: "bytes[]",
      },
      {
        internalType: "bytes",
        name: "extraData",
        type: "bytes",
      },
    ],
    name: "checkCallback",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "checkUpkeep",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "collateralAmount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "collateralToken",
    outputs: [
      {
        internalType: "contract IERC20",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "contractCancelled",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "contractSettled",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "counterpartyAgreed",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "depositCollateralPartyA",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "feedIds",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "isPartyALong",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "link",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyA",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyACancel",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyACollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyB",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyBCancel",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "partyBCollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "performData",
        type: "bytes",
      },
    ],
    name: "performUpkeep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "setCancelPartyA",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "setCancelPartyB",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "settlementTime",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "strikePrice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "verifier",
    outputs: [
      {
        internalType: "contract IVerifierProxy",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export const ARBITRUM_SEPOLIA_FACTORY_ADDRESS =
  "0x403a021E8EeB066cC7FFC1A9aB0be4eE8f703880";

export const ARBITRUM_SEPOLIA_FACTORY_ABI = [
  {
    inputs: [
      { internalType: "address", name: "_link", type: "address" },
      { internalType: "address", name: "_registrar", type: "address" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "DerivativeFactory__CustomLogicRegistrationFailed",
    type: "error",
  },
  {
    inputs: [],
    name: "DerivativeFactory__LinkTransferAndCallFailed",
    type: "error",
  },
  { inputs: [], name: "DerivativeFactory__LinkTransferFailed", type: "error" },
  {
    inputs: [],
    name: "DerivativeFactory__LogTriggerRegistrationFailed",
    type: "error",
  },
  { inputs: [], name: "DerivativeFactory__NoLinkToWithdraw", type: "error" },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "upkeepID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "derivativeContract",
        type: "address",
      },
    ],
    name: "CustomLogicUpkeepRegistered",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "derivativeContract",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "partyA",
        type: "address",
      },
    ],
    name: "DerivativeCreated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "upkeepID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "derivativeContract",
        type: "address",
      },
    ],
    name: "LogTriggerUpkeepRegistered",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      { internalType: "address payable", name: "partyA", type: "address" },
      { internalType: "address payable", name: "verifier", type: "address" },
      { internalType: "uint256", name: "strikePrice", type: "uint256" },
      { internalType: "uint256", name: "settlementTime", type: "uint256" },
      { internalType: "address", name: "collateralToken", type: "address" },
      { internalType: "uint256", name: "collateralAmount", type: "uint256" },
      { internalType: "bool", name: "isPartyALong", type: "bool" },
      { internalType: "string[]", name: "feedIds", type: "string[]" },
    ],
    name: "createCustomDerivative",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "i_link",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "i_registrar",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "newOwner", type: "address" }],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdrawLink",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export const ARBISCAN_API_URL = "https://api-sepolia.arbiscan.io/api";

export const ARBISCAN_API_KEY = "******YOUR_ARBISCAN_API_KEY_HERE******";

export const ARBITRUM_SEPOLIA_ETH_USD_FEED_ID = [
  "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
];

export const ARBITRUM_SEPOLIA_VERIFIER_ADDRESS =
  "0x2ff010DEbC1297f19579B4246cad07bd24F2488A";
