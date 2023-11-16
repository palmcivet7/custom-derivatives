// components/DeploySection.js
import React, { useState } from "react";
import styles from "../styles/DeploySection.module.css";

const DeploySection = () => {
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    chain: "",
    underlyingAsset: "",
    strikePrice: "",
    settlementTime: "",
    collateralAsset: "",
    collateralAmount: "",
    position: "", // 'long' or 'short'
  });

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handlePositionChange = (position) => {
    setFormData({ ...formData, position });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Logic to deploy contract goes here
    console.log("Form Data:", formData);
  };

  return (
    <div>
      <p>
        Create a custom derivative contract and deploy on your chain of choice
      </p>
      {!showModal && (
        <button onClick={() => setShowModal(true)}>Create Contract</button>
      )}

      {showModal && (
        <div className={styles.modal}>
          <form onSubmit={handleSubmit}>
            {/* Dropdown for chain selection */}
            <div className={styles.formElement}>
              <select name="chain" onChange={handleInputChange}>
                <option value="">Select Chain</option>
                <option value="chainA">Chain A</option>
                <option value="chainB">Chain B</option>
                {/* Add more chains as needed */}
              </select>
            </div>

            {/* Dropdown for underlying asset */}
            <div className={styles.formElement}>
              <select name="underlyingAsset" onChange={handleInputChange}>
                <option value="">Select Underlying Asset</option>
                <option value="asset1">Asset 1</option>
                <option value="asset2">Asset 2</option>
                {/* Add more assets as needed */}
              </select>
            </div>

            {/* Input for strike price */}
            <div className={styles.formElement}>
              <input
                type="number"
                name="strikePrice"
                placeholder="Strike Price"
                onChange={handleInputChange}
              />
            </div>

            {/* Input/Dropdown for settlement time */}
            <div className={styles.formElement}>
              <input
                type="datetime-local"
                name="settlementTime"
                onChange={handleInputChange}
              />
            </div>

            {/* Dropdown for collateral asset */}
            <div className={styles.formElement}>
              <select name="collateralAsset" onChange={handleInputChange}>
                <option value="">Select Collateral Asset</option>
                <option value="collateral1">Collateral 1</option>
                <option value="collateral2">Collateral 2</option>
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

            <div className={styles.buttons}>
              <button type="submit">Deploy Contract</button>
              <button type="button" onClick={() => setShowModal(false)}>
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};

export default DeploySection;
