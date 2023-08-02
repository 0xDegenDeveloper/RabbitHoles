import React from "react";
import styled from "styled-components";
import Modal from "./Modal";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faXmarkCircle } from "@fortawesome/free-solid-svg-icons";
import { ContainerStyled, OptionStyled } from "./WalletModal";
import { useAccount, useConnectors } from "@starknet-react/core";
import { useNavigate } from "react-router-dom";

export default function AccountModal(props) {
  const { address } = useAccount();
  const { disconnect } = useConnectors();
  const navigate = useNavigate();

  const handleDisconnect = (connector) => {
    // const starknetProperty = `starknet_${connector?.id}`;
    // if (window[starknetProperty]) {
    //   props.onClose();
    //   connect(connector);
    // } else {
    //   window.open(table[connector.id].download);
    // }
  };

  return (
    <Modal onClose={props.onClose} modal={props.modal}>
      <ContainerStyled className="dark-box-600w">
        <h3>{`<${address?.slice(0, 6)}...${address?.slice(-4)}>`}</h3>
        <div>
          <OptionStyled
            onClick={() => {
              navigate("/user");
              props.onClose(false);
            }}
          >
            <span>{"view profile"}</span>
          </OptionStyled>
        </div>
        <div>
          <OptionStyled
            onClick={() => {
              disconnect();
              props.onClose(false);
            }}
          >
            <span>{"disconnect"}</span>
          </OptionStyled>
        </div>

        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={() => {
            props.onClose(false);
          }}
        />
      </ContainerStyled>
    </Modal>
  );
}

// export default Modal;
