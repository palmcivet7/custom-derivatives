// components/ConnectWalletButton.js
import React, { useState, useEffect } from "react";
import { ethers } from "ethers";

const ConnectWalletButton = () => {
  const [walletAddress, setWalletAddress] = useState("");

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", handleAccountsChanged);
    }
    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener(
          "accountsChanged",
          handleAccountsChanged
        );
      }
    };
  }, []);

  const handleAccountsChanged = (accounts) => {
    if (accounts.length === 0) {
      console.log("Please connect to MetaMask.");
    } else {
      setWalletAddress(accounts[0]);
    }
  };

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        setWalletAddress(accounts[0]);
      } catch (error) {
        console.error("Error connecting to MetaMask:", error);
      }
    } else {
      console.log("Please install MetaMask.");
    }
  };

  return (
    <button
      onClick={connectWallet}
      style={{
        padding: "10px 15px",
        background: "blue",
        color: "white",
        border: "none",
        borderRadius: "5px",
      }}
    >
      {walletAddress
        ? `Connected: ${walletAddress.substring(
            0,
            6
          )}...${walletAddress.substring(walletAddress.length - 4)}`
        : "Connect Wallet"}
    </button>
  );
};

export default ConnectWalletButton;
