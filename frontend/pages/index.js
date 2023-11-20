import Head from "next/head";
import styles from "@/styles/Home.module.css";
import DeploySection from "@/components/DeploySection";
import DeployedContractsEthSep from "@/components/DeployedContractsEthSep";

export default function Home() {
  return (
    <>
      <Head>
        <title>Custom Derivatives</title>
        <meta
          name="description"
          content="Web3 custom derivatives by palmcivet.eth"
        />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <main className={styles.main}>
        <div className={styles.description}>
          <DeploySection />
          <DeployedContractsEthSep />
        </div>
      </main>
    </>
  );
}
