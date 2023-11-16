import styles from "../styles/Header.module.css";
import ConnectWalletButton from "./ConnectWalletButton";

export default function Header() {
  return (
    <div className={styles.header}>
      <div className={styles.emptyDiv}></div>
      <h1 className={styles.title}>Custom Derivatives</h1>
      <div className={styles.buttonDiv}>
        <ConnectWalletButton />
      </div>
    </div>
  );
}
