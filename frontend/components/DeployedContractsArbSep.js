import React, { useState, useEffect } from "react";
import axios from "axios";
import { ethers } from "ethers";
import styles from "../styles/DeployedContracts.module.css";
import {
  ARBITRUM_SEPOLIA_FACTORY_ADDRESS,
  ARBISCAN_API_KEY,
  ARBISCAN_API_URL,
  DATA_STREAMS_CUSTOM_DERIVATIVE_ABI,
  ARBITRUM_SEPOLIA_RPC_URL,
  ERC20_ABI,
} from "../utils/constants";

const DeployedContractsArbSep = () => {
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
    const provider = new ethers.providers.JsonRpcProvider(
      ARBITRUM_SEPOLIA_RPC_URL
    );
    const contract = new ethers.Contract(
      contractAddress,
      DATA_STREAMS_CUSTOM_DERIVATIVE_ABI,
      provider
    );

    try {
      const underlyingAsset = "ETH";
      // const feedIdsArray = await contract.feedIds();
      // const underlyingAsset = formatAssetArray(feedIdsArray[0]);
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
        chain: "Arbitrum Sepolia",
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
      const response = await axios.get(`${ARBISCAN_API_URL}`, {
        params: {
          module: "account",
          action: "txlistinternal",
          address: ARBITRUM_SEPOLIA_FACTORY_ADDRESS,
          startblock: 0,
          endblock: 99999999,
          sort: "asc",
          apikey: ARBISCAN_API_KEY,
        },
      });

      const filteredContracts = response.data.result.filter(
        (tx) =>
          tx.from.toLowerCase() ===
            ARBITRUM_SEPOLIA_FACTORY_ADDRESS.toLowerCase() &&
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

  const formatAssetArray = (feedId) => {
    // Map the feedId to the corresponding asset name
    const knownFeedId =
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b";
    if (feedId === knownFeedId) {
      return "ETH";
    }
    return "Unknown Asset"; // Default case if feedId does not match
  };

  const formatAsset = (assetAddress) => {
    switch (assetAddress) {
      case "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b":
        return "ETH";
      case "0xbd3f8ec76e5829a4a35ce369a19c7b53bcb14d98":
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
      DATA_STREAMS_CUSTOM_DERIVATIVE_ABI,
      signer
    );

    const collateralTokenContract = new ethers.Contract(
      contract.collateralAsset,
      ERC20_ABI,
      signer
    );

    try {
      const collateralAmount = await contractInstance.collateralAmount();
      const amountInWei = collateralAmount.toString();

      const allowance = await collateralTokenContract.allowance(
        connectedWallet,
        contract.address
      );
      if (allowance.lt(collateralAmount)) {
        alert(
          "This transaction is for approving the token transfer only, another transaction will have to be made for the deposit afterwards"
        );
        const approveTx = await collateralTokenContract.approve(
          contract.address,
          amountInWei
        );
        await approveTx.wait();
      }

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
      <h2>Deployed Contracts on Arbitrum Sepolia</h2>
      {deployedContracts.length > 0 ? (
        <ul className={styles.deployedContractsList}>
          {deployedContracts.map((contract, index) => (
            <li key={index} className={styles.deployedContractItem}>
              <p>
                <a
                  href={`https://sepolia.arbiscan.io/address/${contract.address}`}
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
                  disabled={
                    !connectedWallet ||
                    connectedWallet.toLowerCase() ===
                      contract.deployer.toLowerCase() ||
                    contract.counterpartyDeposited
                  }
                  className={`${styles.depositButton} ${
                    !connectedWallet ||
                    connectedWallet.toLowerCase() ===
                      contract.deployer.toLowerCase() ||
                    contract.counterpartyDeposited
                      ? styles.buttonDisabled
                      : ""
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
                    href={`https://sepolia.arbiscan.io/tx/${contract.txHash}`}
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

export default DeployedContractsArbSep;
