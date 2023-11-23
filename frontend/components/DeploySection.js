// components/DeploySection.js
import React, { useState } from "react";
import styles from "../styles/DeploySection.module.css";
import { ethers } from "ethers";
import {
  FUJI_FACTORY_SENDER_ADDRESS,
  FUJI_FACTORY_SENDER_ABI,
  SEPOLIA_FACTORY_RECEIVER_ADDRESS,
  SEPOLIA_FACTORY_RECEIVER_ABI,
  SEPOLIA_DESTINATION_CHAIN_SELECTOR,
  SEPOLIA_ETH_PRICE_FEED_ADDRESS,
  SEPOLIA_MOCK_USDC_TOKEN_ADDRESS,
  FUJI_AVAX_PRICE_FEED_ADDRESS,
  ARBITRUM_SEPOLIA_ETH_USD_FEED_ID,
  ARBITRUM_SEPOLIA_FACTORY_ADDRESS,
  ARBITRUM_SEPOLIA_FACTORY_ABI,
  ARBITRUM_SEPOLIA_MOCK_USDC_TOKEN_ADDRESS,
  ARBITRUM_SEPOLIA_VERIFIER_ADDRESS,
} from "../utils/constants";

const DeploySection = () => {
  const [showModal, setShowModal] = useState(false);
  const [loading, setLoading] = useState(false);
  const [txHash, setTxHash] = useState(null);
  const [formData, setFormData] = useState({
    chain: "",
    underlyingAsset: "",
    strikePrice: "",
    settlementTime: "",
    collateralAsset: "",
    collateralAmount: "",
    position: "", // 'long' or 'short'
    feedId: "",
  });
  const [isDateTimeInputActive, setIsDateTimeInputActive] = useState(false);
  const [settlementTime, setSettlementTime] = useState("");

  const handleSettlementTimeChange = (e) => {
    setSettlementTime(e.target.value);
    setFormData({ ...formData, settlementTime: e.target.value });
  };

  const handleDateTimeInputFocus = () => {
    setIsDateTimeInputActive(true);
  };

  const handleDateTimeInputBlur = () => {
    if (!settlementTime) {
      setIsDateTimeInputActive(false);
    }
  };

  const handleInputChange = (e) => {
    if (e.target.name === "underlyingAsset" && formData.chain === "chainA") {
      // Automatically set feedId for Arbitrum Sepolia if ETH is selected
      const newFeedId =
        e.target.value === "asset1" ? ARBITRUM_SEPOLIA_ETH_USD_FEED_ID : "";
      setFormData({
        ...formData,
        [e.target.name]: e.target.value,
        feedId: newFeedId,
      });
    } else {
      // Handle other input changes normally
      setFormData({ ...formData, [e.target.name]: e.target.value });
    }
  };

  const handlePositionChange = (position) => {
    setFormData({ ...formData, position });
  };

  // const calculateMintingPrice = async () => {
  //   try {
  //     const provider = new ethers.providers.Web3Provider(window.ethereum);
  //     const signer = provider.getSigner();
  //     const priceFeedContract = new ethers.Contract(
  //       FUJI_AVAX_PRICE_FEED_ADDRESS,
  //       FUJI_FACTORY_SENDER_ABI,
  //       signer
  //     );

  //     const price = await priceFeedContract.getLatestPrice(); // Assuming price is in Wei
  //     const mintingPrice = ethers.utils
  //       .parseUnits("5", 18)
  //       .mul(ethers.constants.WeiPerEther)
  //       .div(price);
  //     return mintingPrice;
  //   } catch (error) {
  //     console.error("Error fetching latest price:", error);
  //     return ethers.constants.Zero;
  //   }
  // };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true); // Start loading

    let receiverAddress;
    let destinationChainSelector;
    let priceFeedAddress;
    let collateralTokenAddress;
    let isPartyALong;

    const testFeedIds = [
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
    ];
    // Use testFeedIds in the contract function call

    // Set the receiver address and destination chain selector
    if (formData.chain === "chainB") {
      // Ethereum Sepolia
      receiverAddress = SEPOLIA_FACTORY_RECEIVER_ADDRESS;
      destinationChainSelector = SEPOLIA_DESTINATION_CHAIN_SELECTOR;
      priceFeedAddress =
        formData.underlyingAsset === "asset1"
          ? SEPOLIA_ETH_PRICE_FEED_ADDRESS
          : "";
      collateralTokenAddress =
        formData.collateralAsset === "collateral1"
          ? SEPOLIA_MOCK_USDC_TOKEN_ADDRESS
          : "";
    } else if (formData.chain === "chainA") {
      // Arbitrum Sepolia
      receiverAddress = ARBITRUM_SEPOLIA_FACTORY_ADDRESS;
      destinationChainSelector = ""; // Set your destination chain selector for Arbitrum Sepolia
      collateralTokenAddress =
        formData.collateralAsset === "collateral1"
          ? ARBITRUM_SEPOLIA_MOCK_USDC_TOKEN_ADDRESS
          : "";
    }

    // Convert strike price and collateral amount to Wei
    const strikePriceInWei = ethers.utils
      .parseUnits(formData.strikePrice, 18)
      .toString();
    const collateralAmountInWei = ethers.utils
      .parseUnits(formData.collateralAmount, 18)
      .toString();

    // Convert settlement time to Unix timestamp
    const settlementTimeUnix =
      new Date(formData.settlementTime).getTime() / 1000;

    // Set isPartyALong
    isPartyALong = formData.position === "long";

    console.log("Form Data:", formData);

    if (formData.chain === "chainB") {
      console.log(
        "Ethereum Sepolia Real data:",
        "Receiver Address:",
        receiverAddress,
        "Destination Chain Selector:",
        destinationChainSelector,
        "Price Feed Address:",
        priceFeedAddress,
        "Strike Price (Wei):",
        strikePriceInWei,
        "Settlement Time Unix:",
        settlementTimeUnix,
        "Collateral Token Address:",
        collateralTokenAddress,
        "Collateral Amount (Wei):",
        collateralAmountInWei,
        "Is Party A Long:",
        isPartyALong
      );
    } else if (formData.chain === "chainA") {
      console.log(
        "Arbitrum Sepolia Real data:",
        "Receiver Address:",
        receiverAddress,
        "Destination Chain Selector:",
        destinationChainSelector,
        "Feed IDs:",
        formData.feedId,
        "Strike Price (Wei):",
        strikePriceInWei,
        "Settlement Time Unix:",
        settlementTimeUnix,
        "Collateral Token Address:",
        collateralTokenAddress,
        "Collateral Amount (Wei):",
        collateralAmountInWei,
        "Is Party A Long:",
        isPartyALong
      );
    }

    // Interact with the contract
    if (typeof window.ethereum !== "undefined") {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        let tx;

        if (formData.chain === "chainB") {
          // Interact with Ethereum Sepolia contract
          const contract = new ethers.Contract(
            FUJI_FACTORY_SENDER_ADDRESS,
            FUJI_FACTORY_SENDER_ABI,
            signer
          );
          tx = await contract.createCrossChainCustomDerivative(
            receiverAddress,
            destinationChainSelector,
            priceFeedAddress,
            strikePriceInWei,
            settlementTimeUnix,
            collateralTokenAddress,
            collateralAmountInWei,
            isPartyALong
          );
        } else if (formData.chain === "chainA") {
          // Interact with Arbitrum Sepolia contract
          const feedIds =
            formData.underlyingAsset === "asset1"
              ? [ARBITRUM_SEPOLIA_ETH_USD_FEED_ID]
              : [];
          const contract = new ethers.Contract(
            ARBITRUM_SEPOLIA_FACTORY_ADDRESS,
            ARBITRUM_SEPOLIA_FACTORY_ABI,
            signer
          );
          tx = await contract.createCustomDerivative(
            signer.getAddress(), // partyA
            ARBITRUM_SEPOLIA_VERIFIER_ADDRESS, // verifier
            strikePriceInWei,
            settlementTimeUnix,
            collateralTokenAddress,
            collateralAmountInWei,
            isPartyALong,
            testFeedIds
          );
        }

        const receipt = await tx.wait();
        setTxHash(receipt.transactionHash); // Update txHash state
        console.log("Contract deployed successfully");
      } catch (error) {
        console.error("Error deploying contract:", error);
      }
    } else {
      console.log("MetaMask is not installed");
    }

    setLoading(false);
  };

  const handleCancel = () => {
    setShowModal(false);
    setSettlementTime("");
    setIsDateTimeInputActive(false);
    // Reset other form data as needed
    setFormData({
      chain: "",
      underlyingAsset: "",
      strikePrice: "",
      settlementTime: "",
      collateralAsset: "",
      collateralAmount: "",
      position: "",
    });
  };

  return (
    <div>
      <p>
        Create a custom derivative contract and deploy on your chain of choice.{" "}
      </p>
      <p>
        Please make sure your wallet is connected and you are on Avalanche Fuji
        testnet for the initial tx.{" "}
      </p>

      {!showModal && (
        <button onClick={() => setShowModal(true)}>Create Contract</button>
      )}

      {showModal && !loading && !txHash && (
        <div className={styles.modal}>
          <form onSubmit={handleSubmit}>
            {/* Dropdown for chain selection */}
            <div className={styles.formElement}>
              <select name="chain" onChange={handleInputChange}>
                <option value="">Select Chain</option>
                <option value="chainA">Arbitrum Sepolia</option>
                <option value="chainB">Ethereum Sepolia</option>
                {/* Add more chains as needed */}
              </select>
            </div>

            {/* Dropdown for underlying asset */}
            <div className={styles.formElement}>
              <select name="underlyingAsset" onChange={handleInputChange}>
                <option value="">Select Underlying Asset</option>
                <option value="asset1">ETH</option>
                <option value="asset2">BTC</option>
                {/* Add more assets as needed */}
              </select>
            </div>

            {/* Input for strike price */}
            <div className={styles.formElement}>
              <input
                type="number"
                name="strikePrice"
                placeholder="Strike Price in $"
                onChange={handleInputChange}
              />
            </div>

            {/* Input/Dropdown for settlement time */}
            <div className={styles.formElement}>
              {!isDateTimeInputActive && (
                <div
                  className={styles.dateTimePlaceholder}
                  onClick={handleDateTimeInputFocus}
                >
                  Select Settlement Date & Time
                </div>
              )}
              {isDateTimeInputActive && (
                <input
                  type="datetime-local"
                  name="settlementTime"
                  value={settlementTime}
                  onChange={handleSettlementTimeChange}
                  onBlur={handleDateTimeInputBlur}
                />
              )}
            </div>

            {/* Dropdown for collateral asset */}
            <div className={styles.formElement}>
              <select name="collateralAsset" onChange={handleInputChange}>
                <option value="">Select Collateral Asset</option>
                <option value="collateral1">USDC</option>
                <option value="collateral2">ETH</option>
                {/* Add more collateral types as needed */}
              </select>
            </div>

            {/* Input for collateral amount */}
            <div className={styles.formElement}>
              <input
                type="number"
                name="collateralAmount"
                placeholder="Collateral Amount"
                onChange={handleInputChange}
              />
            </div>

            {/* Radio buttons for long/short position */}
            <div className={styles.formElement}>
              <div className={styles.tradePosition}>
                <label>
                  <input
                    type="radio"
                    name="position"
                    value="long"
                    checked={formData.position === "long"}
                    onChange={() => handlePositionChange("long")}
                  />
                  Long Position
                </label>
                <label>
                  <input
                    type="radio"
                    name="position"
                    value="short"
                    checked={formData.position === "short"}
                    onChange={() => handlePositionChange("short")}
                  />
                  Short Position
                </label>
              </div>
            </div>

            <div className={styles.buttons}>
              <button type="submit">Deploy Contract</button>
              <button type="cancel" onClick={handleCancel}>
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {loading && (
        <div className="loadingSpinner">Loading...</div> // Replace with your actual spinner
      )}

      {txHash && (
        <div className={styles.successMessage}>
          <p>Transaction Successful!</p>
          {formData.chain === "chainB" ? (
            <a
              href={`https://testnet.snowtrace.io/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
            >
              View on Snowtrace
            </a>
          ) : (
            <a
              href={`https://sepolia.arbiscan.io/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
            >
              View on Arbiscan
            </a>
          )}
        </div>
      )}
    </div>
  );
};

export default DeploySection;
