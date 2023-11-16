export const FUJI_FACTORY_SENDER_ADDRESS =
  "0xd2363623fA2A1864E445EcE2a39237d80960f501";

export const FUJI_FACTORY_SENDER_ABI = [
  {
    inputs: [
      { internalType: "address", name: "_link", type: "address" },
      { internalType: "address", name: "_router", type: "address" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  { inputs: [], name: "FactorySender__LinkTransferFailed", type: "error" },
  { inputs: [], name: "FactorySender__NoLinkToWithdraw", type: "error" },
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
    name: "withdrawLink",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export const SEPOLIA_FACTORY_RECEIVER_ADDRESS =
  "0x64000C2561305650367849F6D628DEF5947E91DA";

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
