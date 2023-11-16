import React, { useState, useEffect } from "react";
import axios from "axios";
import { ethers } from "ethers";
import {
  SEPOLIA_FACTORY_RECEIVER_ADDRESS,
  ETHERSCAN_API_KEY,
  ETHERSCAN_API_URL,
  CUSTOM_DERIVATIVE_ABI,
  SEPOLIA_RPC_URL,
} from "../utils/constants";

const DeployedContracts = () => {
  const [deployedContracts, setDeployedContracts] = useState([]);

  useEffect(() => {
    fetchDeployedContracts();
  }, []);

  const fetchContractDetails = async (contractAddress) => {
    const provider = new ethers.providers.JsonRpcProvider(SEPOLIA_RPC_URL);
    const contract = new ethers.Contract(
      contractAddress,
      CUSTOM_DERIVATIVE_ABI,
      provider
    );

    try {
      const underlyingAsset = await contract.priceFeed();
      const strikePrice = await contract.strikePrice();
      const settlementTime = new Date((await contract.settlementTime()) * 1000);
      const collateralAsset = await contract.collateralToken();
      const collateralAmount = await contract.collateralAmount();
      const deployer = await contract.partyA();
      const isPartyALong = await contract.isPartyALong();

      return {
        address: contractAddress,
        chain: "Ethereum Sepolia",
        underlyingAsset,
        strikePrice: ethers.utils.formatUnits(strikePrice, 18), // Assuming strike price is in wei
        settlementTime: settlementTime.toLocaleString(),
        collateralAsset,
        collateralAmount: ethers.utils.formatUnits(collateralAmount, 18), // Assuming collateral amount is in wei
        deployer,
        position: isPartyALong ? "Long" : "Short",
      };
    } catch (error) {
      console.error(
        `Error fetching details for contract ${contractAddress}:`,
        error
      );
      return null;
    }
  };

  const fetchDeployedContracts = async () => {
    try {
      const response = await axios.get(`${ETHERSCAN_API_URL}`, {
        params: {
          module: "account",
          action: "txlistinternal",
          address: SEPOLIA_FACTORY_RECEIVER_ADDRESS,
          startblock: 0,
          endblock: 99999999,
          sort: "asc",
          apikey: ETHERSCAN_API_KEY,
        },
      });

      const filteredContracts = response.data.result.filter(
        (tx) =>
          tx.from.toLowerCase() ===
            SEPOLIA_FACTORY_RECEIVER_ADDRESS.toLowerCase() &&
          tx.type === "create" &&
          tx.contractAddress
      );

      const contractDetailsPromises = filteredContracts.map((tx) =>
        fetchContractDetails(tx.contractAddress)
      );

      const contractsDetails = await Promise.all(contractDetailsPromises);
      setDeployedContracts(
        contractsDetails.filter((details) => details !== null)
      );
    } catch (error) {
      console.error("Error fetching deployed contracts:", error);
    }
  };

  return (
    <div>
      <h2>Deployed Contracts</h2>
      {deployedContracts.length > 0 ? (
        <ul>
          {deployedContracts.map((contract, index) => (
            <li key={index}>
              <p>Contract Address: {contract.address}</p>
              <p>Chain: {contract.chain}</p>
              <p>Underlying Asset: {contract.underlyingAsset}</p>
              <p>Strike Price: {contract.strikePrice}</p>
              <p>Settlement Time: {contract.settlementTime}</p>
              <p>Collateral Asset: {contract.collateralAsset}</p>
              <p>Collateral Amount: {contract.collateralAmount}</p>
              <p>Deployer: {contract.deployer}</p>
              <p>Position: {contract.position}</p>
            </li>
          ))}
        </ul>
      ) : (
        <p>No deployed contracts found.</p>
      )}
    </div>
  );
};

export default DeployedContracts;
