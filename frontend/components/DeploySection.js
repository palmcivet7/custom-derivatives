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
    setFormData({ ...formData, [e.target.name]: e.target.value });
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

    // Set the receiver address and destination chain selector
    if (formData.chain === "chainB") {
      // Ethereum Sepolia
      receiverAddress = SEPOLIA_FACTORY_RECEIVER_ADDRESS;
      destinationChainSelector = SEPOLIA_DESTINATION_CHAIN_SELECTOR;
    }

    // Set the price feed address
    if (formData.chain === "chainB" && formData.underlyingAsset === "asset1") {
      // ETH
      priceFeedAddress = SEPOLIA_ETH_PRICE_FEED_ADDRESS;
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

    // Set the collateral token address
    if (
      formData.chain === "chainB" &&
      formData.collateralAsset === "collateral1"
    ) {
      // USDC
      collateralTokenAddress = SEPOLIA_MOCK_USDC_TOKEN_ADDRESS;
    }

    // Set isPartyALong
    isPartyALong = formData.position === "long";

    console.log("Form Data:", formData);
    console.log(
      "Real data:",
      receiverAddress,
      destinationChainSelector,
      priceFeedAddress,
      strikePriceInWei,
      settlementTimeUnix,
      collateralTokenAddress,
      collateralAmountInWei,
      isPartyALong
    );

    // const mintingPrice = await calculateMintingPrice();

    // Interact with the contract
    if (typeof window.ethereum !== "undefined") {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(
          FUJI_FACTORY_SENDER_ADDRESS,
          FUJI_FACTORY_SENDER_ABI,
          signer
        );

        const tx = await contract.createCrossChainCustomDerivative(
          receiverAddress,
          destinationChainSelector,
          priceFeedAddress,
          strikePriceInWei,
          settlementTimeUnix,
          collateralTokenAddress,
          collateralAmountInWei,
          isPartyALong
          // { value: mintingPrice }
        );
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
          <a
            href={`https://testnet.snowtrace.io/tx/${txHash}`}
            target="_blank"
            rel="noopener noreferrer"
          >
            View on Snowtrace
          </a>
        </div>
      )}
    </div>
  );
};

export default DeploySection;
