import { useAccount, useConnectors } from "@starknet-react/core";
import styled from "styled-components";
import WalletModal from "./WalletModal";

import { useState, useMemo, useEffect } from "react";

export default function LoginButton(props) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const { address } = useAccount();

  return (
    <>
      {address ? (
        <ConnectedBtn
          setAccountModal={props.setAccountModal}
          modal={props.accountModal}
        />
      ) : (
        <DisconnectedBtn setIsModalOpen={setIsModalOpen} />
      )}
      <WalletModal modal={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </>
  );
}

function DisconnectedBtn() {
  return (
    <LoginBtn
      onClick={() => {
        props.setIsModalOpen(true);
      }}
      connected={false}
    >
      <span>Connect Wallet</span>
    </LoginBtn>
  );
}

function ConnectedBtn(props) {
  const { address } = useAccount();
  const { disconnect } = useConnectors();

  const shortenedAddress = useMemo(() => {
    if (!address) return "";
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  }, [address]);

  return (
    <LoginBtn
      setAccountModal={props.setAccountModal}
      connected={true}
      // disconnect={disconnect}
      onClick={() => {
        props.setAccountModal(true);
      }}
      modal={props.modal}
    >
      <span>{shortenedAddress}</span>
    </LoginBtn>
  );
}

const LoginBtn = styled.div`
  position: absolute;
  max-width: fit-content;
  white-space: nowrap;
  background-color: ${(props) =>
    props.connected ? "var(--forrestGreen)" : "rgba(255, 255, 255, 0.01)"};
  color: ${(props) =>
    props.connected ? "var(--greyGreen)" : "var(--forrestGreen)"};
  border-color: rgba(0, 0, 0, 0);
  border-style: solid;
  border-width: 2px;
  /* border-radius: 2rem; */
  border-radius: 0 0 0 2rem;
  /* border-bottom-right-radius: 2rem; */
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  -moz-backdrop-filter: blur(10px);
  -o-backdrop-filter: blur(10px);
  -ms-backdrop-filter: blur(10px);
  box-shadow: 0px 0px 5px 0px var(--forrestGreen);
  padding: 0 1rem;
  top: -2px;
  right: -2px;
  padding: 1rem 1rem;
  z-index: 1000;
  overflow: hidden;
  font-family: "Lato";
  font-weight: 700;
  font-size: clamp(12px, 2vw, 17px);

  &:hover {
    cursor: pointer;
    color: ${(props) =>
      props.connected
        ? "var(--forrestGreen)"
        : "var(--greyGreen)"}; // var(--forrestGreen);
    background-color: ${(props) =>
      props.connected ? "rgba(0,0,0,0)" : "var(--forrestGreen)"};
  }

  transition: all 0.05s 0s ease-in-out;
`;
