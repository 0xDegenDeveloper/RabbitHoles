import React from "react";
import ReactDOM from "react-dom";
import styled from "styled-components";

export default function Modal(props) {
  if (!props.modal) return null;

  const handleOverlayClick = (event) => {
    if (event.target === event.currentTarget) {
      props.onClose();
    }
  };

  return ReactDOM.createPortal(
    <>
      <OverlayStyle onClick={handleOverlayClick}>{props.children}</OverlayStyle>
    </>,
    document.getElementById("modal-root")
  );
}

const OverlayStyle = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.3);
  /* background: red; */
  backdrop-filter: blur(10px);
  z-index: 1000;
  white-space: nowrap;
`;
