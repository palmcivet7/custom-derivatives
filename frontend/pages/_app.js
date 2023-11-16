import "@/styles/globals.css";
import Head from "next/head";
import Header from "../components/Header";

export default function App({ Component, pageProps }) {
  return (
    <div>
      <Head>
        <title>Custom Derivatives</title>
        <meta
          name="description"
          content="Web3 custom derivatives by palmcivet.eth"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Header />
      <Component {...pageProps} />
    </div>
  );
}
