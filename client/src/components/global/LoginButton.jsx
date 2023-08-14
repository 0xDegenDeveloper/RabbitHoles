import { useAccount, useConnectors } from "@starknet-react/core";
import styled from "styled-components";
import WalletModal from "../cards/ProviderCard";

import { useState, useMemo, useEffect } from "react";
export default function LoginButton(props) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const { address } = useAccount();

  return (
    <Wrap>
      {address ? (
        <ConnectedBtn
          setAccountModal={props.setAccountModal}
          modal={props.accountModal}
          darkMode={props.darkMode}
        />
      ) : (
        <DisconnectedBtn
          setIsModalOpen={setIsModalOpen}
          darkMode={props.darkMode}
        />
      )}
      <WalletModal modal={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </Wrap>
  );
}

const Wrap = styled.div`
  top: -2px;
  right: -2px;
  position: absolute;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2rem;

  svg {
    color: var(--forrestGreen);
    font-size: 1.5rem;

    &:hover {
      cursor: pointer;
      color: var(--greyGreen);
    }
  }
`;

function DisconnectedBtn(props) {
  return (
    <LoginBtn
      onClick={() => {
        props.setIsModalOpen(true);
      }}
      connected={false}
      darkMode={props.darkMode}
    >
      <span>Connect Account</span>
    </LoginBtn>
  );
}

function ConnectedBtn(props) {
  const { address, status } = useAccount();

  console.log(status);
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
      darkMode={props.darkMode}
      modal={props.modal}
    >
      <span>{shortenedAddress}</span>
    </LoginBtn>
  );
}

const LoginBtn = styled.div`
  /* position: absolute; */
  max-width: fit-content;
  white-space: nowrap;
  background-color: ${(props) =>
    props.darkMode ? "var(--forrestGreen)" : "rgba(255, 255, 255, 0.01)"};
  color: ${(props) =>
    props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
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
  /* top: -2px;
  right: -2px; */
  padding: 1rem 1rem;
  /* z-index: 1000; */
  overflow: hidden;
  font-family: "Lato";
  font-weight: 700;
  font-size: clamp(12px, 2vw, 17px);

  &:hover {
    cursor: pointer;
    /* color: ${(props) =>
      props.darkMode
        ? "var(--greyGreen)"
        : "var(--greyGreen)"}; // var(--forrestGreen);
    background-color: ${(props) =>
      props.darkMode ? "var(--forrestGreen)" : "var(--forrestGreen)"}; */
    scale: 1.05;
  }

  transition: all 0.05s 0s ease-in-out;
`;
