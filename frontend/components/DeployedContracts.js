import React, { useState, useEffect } from "react";
import axios from "axios";
import {
  SEPOLIA_FACTORY_RECEIVER_ADDRESS,
  ETHERSCAN_API_KEY,
  ETHERSCAN_API_URL,
} from "../utils/constants";

const DeployedContracts = () => {
  const [deployedContracts, setDeployedContracts] = useState([]);

  useEffect(() => {
    fetchDeployedContracts();
  }, []);

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

      console.log("API Response:", response);
      console.log("Transactions:", response.data.result);

      if (response.data && response.data.result) {
        // Filter and process the transactions to extract created contract addresses
        const filteredContracts = response.data.result.filter(
          (tx) =>
            tx.from.toLowerCase() ===
              SEPOLIA_FACTORY_RECEIVER_ADDRESS.toLowerCase() &&
            tx.type === "create" &&
            tx.contractAddress
        );

        console.log("Filtered Contracts:", filteredContracts);

        const mappedContracts = filteredContracts.map((tx) => ({
          address: tx.contractAddress,
        }));

        console.log("Mapped Contracts:", mappedContracts);

        setDeployedContracts(mappedContracts);

        // Log the state update
        console.log("Updated Deployed Contracts State:", deployedContracts);
      }
    } catch (error) {
      console.error("Error fetching deployed contracts:", error);
      console.log("Error Details:", error.response);
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
              {/* Add more details as needed */}
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
