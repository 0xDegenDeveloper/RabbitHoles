import React from "react";
import Modal from "./Modal";
import { useState, useMemo } from "react";
import { useAccount, useConnectors } from "@starknet-react/core";
import styled from "styled-components";

const MODAL_STYLES = {
  position: "absolute",
  top: "50%",
  left: "50%",
  transform: "translate(-50%,-50%)",
  backgroundColor: "(255,255,255, 0.01)",
  blur: "2px",
  zIndex: 1000,
  color: "black",
};

export default function LoginModal(props) {
  const { connectors, connect } = useConnectors();

  return (
    <Modal onClose={props.onClose()}>
      {/* <div>
        {connectors.map((connector) => {
          return (
            <button key={connector.id} onClick={() => connect(connector)}>
              {connector.id}
            </button>
          );
        })}
      </div> */}
      <div style={MODAL_STYLES}> hi</div>
      <div> world</div>
    </Modal>
  );
}
