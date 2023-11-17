import React, { useState, useEffect } from "react";
import axios from "axios";
import { ethers } from "ethers";
import styles from "../styles/DeployedContracts.module.css";
import {
  SEPOLIA_FACTORY_RECEIVER_ADDRESS,
  ETHERSCAN_API_KEY,
  ETHERSCAN_API_URL,
  CUSTOM_DERIVATIVE_ABI,
  SEPOLIA_RPC_URL,
} from "../utils/constants";

const DeployedContracts = () => {
  const [deployedContracts, setDeployedContracts] = useState([]);
  const [connectedWallet, setConnectedWallet] = useState("");

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum
        .request({ method: "eth_accounts" })
        .then((accounts) => setConnectedWallet(accounts[0] || ""))
        .catch((error) => console.error(error));

      window.ethereum.on("accountsChanged", (accounts) => {
        setConnectedWallet(accounts[0] || "");
      });
    }

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
      const partyACollateral = await contract.partyACollateral();
      const partyBCollateral = await contract.partyBCollateral();

      const deployerDeposited = partyACollateral.gt(ethers.constants.Zero);
      const counterpartyDeposited = partyBCollateral.gt(ethers.constants.Zero);

      return {
        address: contractAddress,
        chain: "Ethereum Sepolia",
        underlyingAsset,
        strikePrice: ethers.utils.formatUnits(strikePrice, 18),
        settlementTime: settlementTime.toLocaleString(),
        collateralAsset,
        collateralAmount: ethers.utils.formatUnits(collateralAmount, 18),
        deployer,
        position: isPartyALong ? "Long" : "Short",
        deployerDeposited,
        counterpartyDeposited,
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

  const formatAsset = (assetAddress) => {
    switch (assetAddress) {
      case "0x694AA1769357215DE4FAC081bf1f309aDC325306":
        return "ETH";
      case "0x679dc61439EE95b27ac931a4e8b0943F25Ad0f54":
        return "USDC";
      default:
        return assetAddress;
    }
  };

  const handleDeposit = async (contract, isDeployer) => {
    if (!window.ethereum) {
      console.log("Ethereum wallet not connected");
      return;
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contractInstance = new ethers.Contract(
      contract.address,
      CUSTOM_DERIVATIVE_ABI,
      signer
    );

    try {
      const collateralAmount = await contractInstance.collateralAmount();
      const amountInWei = collateralAmount.toString();
      let tx;

      if (
        isDeployer &&
        connectedWallet.toLowerCase() === contract.deployer.toLowerCase()
      ) {
        tx = await contractInstance.depositCollateralPartyA(amountInWei);
      } else if (
        !isDeployer &&
        connectedWallet.toLowerCase() !== contract.deployer.toLowerCase()
      ) {
        tx = await contractInstance.agreeToContractAndDeposit(amountInWei);
      } else {
        console.log("Not authorized or incorrect function call");
        return;
      }

      const receipt = await tx.wait();
      const updatedContract = {
        ...contract,
        deployerDeposited: isDeployer || contract.deployerDeposited,
        counterpartyDeposited: !isDeployer || contract.counterpartyDeposited,
        txHash: receipt.transactionHash,
      };

      setDeployedContracts((currentContracts) =>
        currentContracts.map((c) =>
          c.address === contract.address ? updatedContract : c
        )
      );
    } catch (error) {
      console.error("Error during transaction:", error);
    }
  };

  return (
    <div>
      <h2>Deployed Contracts</h2>
      {deployedContracts.length > 0 ? (
        <ul className={styles.deployedContractsList}>
          {deployedContracts.map((contract, index) => (
            <li key={index} className={styles.deployedContractItem}>
              <p>
                <a
                  href={`https://sepolia.etherscan.io/address/${contract.address}`}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {contract.address}
                </a>
              </p>
              <p>Live on {contract.chain}</p>
              <p>Underlying Asset: {formatAsset(contract.underlyingAsset)}</p>
              <p>Strike Price: {contract.strikePrice}</p>
              <p>Settlement Time: {contract.settlementTime}</p>
              <p>Collateral Asset: {formatAsset(contract.collateralAsset)}</p>
              <p>Collateral Amount: {contract.collateralAmount}</p>
              <p>Deployer: {contract.deployer}</p>
              <p>Deployer Position: {contract.position}</p>
              <br></br>
              <div className={styles.buttons}>
                <button
                  onClick={() => handleDeposit(contract, true)}
                  disabled={
                    !connectedWallet ||
                    connectedWallet.toLowerCase() !==
                      contract.deployer.toLowerCase() ||
                    contract.deployerDeposited
                  }
                  className={`${styles.depositButton} ${
                    !connectedWallet ||
                    connectedWallet.toLowerCase() !==
                      contract.deployer.toLowerCase() ||
                    contract.deployerDeposited
                      ? styles.buttonDisabled
                      : ""
                  }`}
                >
                  {contract.deployerDeposited
                    ? "Deployer Deposited"
                    : "Deposit as Deployer"}
                </button>
                <button
                  onClick={() => handleDeposit(contract, false)}
                  disabled={contract.counterpartyDeposited}
                  className={`${styles.depositButton} ${
                    contract.counterpartyDeposited ? styles.buttonDisabled : ""
                  }`}
                >
                  {contract.counterpartyDeposited
                    ? "Counterparty Deposited"
                    : "Deposit as Counterparty"}
                </button>
              </div>
              {contract.txHash && (
                <div>
                  <a
                    href={`https://sepolia.etherscan.io/tx/${contract.txHash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    View Transaction
                  </a>
                </div>
              )}
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
