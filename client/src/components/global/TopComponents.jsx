import Navbar from "./Navbar";
import LoginButton from "./LoginButton";
import Logo from "./Logo";
import Footer from "./Footer";
import { useState } from "react";

export default function TopComponents(props) {
  const [walletShowing, setWalletShowing] = useState(false);
  // const [darkMode, setDarkMode] = useState(false);

  return (
    <div style={{ overflow: "hidden" }}>
      <LoginButton
        mobile={props.mobile}
        walletShowing={walletShowing}
        setAccountModal={props.setAccountModal}
        darkMode={props.darkMode}
        accountModal={props.accountModal}
      />
      <Navbar style={{ zIndex: 1000 }} />
      <Logo
        mobile={props.mobile}
        walletShowing={walletShowing}
        // setWalletShowing={setWalletShowing}
        darkMode={props.darkMode}
        setDarkMode={props.setDarkMode}
      />
      <Footer
        mobile={props.mobile}
        walletShowing={walletShowing}
        // setWalletShowing={setWalletShowing}
        darkMode={props.darkMode}
        setDarkMode={props.setDarkMode}
      />
    </div>
  );
}
