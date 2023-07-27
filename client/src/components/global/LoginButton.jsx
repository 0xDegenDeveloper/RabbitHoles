import { useState, useMemo } from "react";
import { useAccount, useConnectors } from "@starknet-react/core";
import styled from "styled-components";
import LoginModal from "./LoginModal";
import Modal from "./Modal";

export default function LoginButton() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const { address } = useAccount();

  return <>{address ? <ConnectedBtn /> : <DisconnectedBtn />}</>;

  function ConnectedBtn() {
    const { address } = useAccount();
    const { disconnect } = useConnectors();

    const shortenedAddress = useMemo(() => {
      if (!address) return "";
      return `${address.slice(0, 6)}...${address.slice(-4)}`;
    }, [address]);

    return (
      <LoginBtn
        onClick={() => {
          setLoggedIn(!loggedIn);
          setIsModalOpen(false);
          disconnect();
        }}
      >
        <span>Connected: {shortenedAddress}</span>
        {/* <button onClick={disconnect}>Disconnect</button> */}
      </LoginBtn>
    );
  }

  function DisconnectedBtn() {
    const { connectors, connect } = useConnectors();

    return (
      <>
        <LoginBtn
          onClick={() => {
            setIsModalOpen(true);
          }}
        >
          {/* <span>Choose a wallet:</span> */}
          <span>Verify Keys</span>
        </LoginBtn>
        <Modal modal={isModalOpen} onClose={() => setIsModalOpen(false)} />
      </>
    );
  }
}

const LoginBtn = styled.div`
  position: absolute;
  max-width: fit-content;
  white-space: nowrap;
  background-color: var(--forrestGreen);
  color: var(--forrestGreen);
  border-color: var(--forrestGreen);
  border-style: solid;
  border-width: 2px;
  border-radius: 2rem;
  border-top-left-radius: 0;
  border-bottom-right-radius: 0;
  background-color: rgba(255, 255, 255, 0.01);
  backdrop-filter: blur(2px);
  -webkit-backdrop-filter: blur(2px);
  -moz-backdrop-filter: blur(2px);
  -o-backdrop-filter: blur(2px);
  -ms-backdrop-filter: blur(2px);
  box-shadow: 0px 0px 25px 0px rgba(0, 0, 0, 0.2);
  border-top-left-radius: 0;
  border-bottom-right-radius: 2rem;
  border-top-right-radius: 0;
  border-bottom-left-radius: 0;
  padding: 0 1rem;
  top: 0;
  top: -2px;
  left: -2px;
  padding: 1rem 1rem;
  z-index: 1000;
  overflow: hidden;
  font-family: "Lato";
  font-weight: 700;
  font-size: clamp(12px, 2vw, 17px);

  &:hover {
    cursor: pointer;
    color: var(--greyGreen);
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    background-color: var(--forrestGreen);
    border-top-left-radius: 2rem;
    border-bottom-right-radius: 2rem;
    border-bottom-left-radius: 2rem;
    border-top-right-radius: 2rem;
    top: 1rem;
    left: 1rem;
  }

  transition: all 0.1s 0.05s ease-in-out;
`;
