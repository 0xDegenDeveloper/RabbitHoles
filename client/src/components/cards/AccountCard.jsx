import React from "react";
import styled from "styled-components";
import Modal from "../global/Modal";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faXmarkCircle } from "@fortawesome/free-solid-svg-icons";
import { ContainerStyled, OptionStyled } from "./ProviderCard";
import { useAccount, useConnectors, useProvider } from "@starknet-react/core";
import { useNavigate } from "react-router-dom";

export default function AccountModal(props) {
  const { address } = useAccount();
  const { disconnect } = useConnectors();
  const navigate = useNavigate();

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
        <a
          target="_blank"
          href="https://app.ens.domains/degendeveloper.eth"
          onClick={() => {
            console.log("you're awesome !");
          }}
        >
          {" "}
          <OptionStyled>
            <span>{"donate :)"}</span>
          </OptionStyled>
        </a>
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
