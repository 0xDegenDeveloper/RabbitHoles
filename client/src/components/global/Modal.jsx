// import { Section } from "../global/GlobalStyles.style";
import ReactDOM from "react-dom";
import styled from "styled-components";
import { useAccount, useConnectors } from "@starknet-react/core";

// import ArtifactSelector from "./ArtifactSelector";

const OverlayStyle = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  /* background-color: rgba(255, 255, 255, 0.1); */
  /* background: red; */
  backdrop-filter: blur(6px);
  z-index: 1000;
`;

export default function Modal(props) {
  if (!props.modal) return null;

  const handleOverlayClick = (event) => {
    // Check if the clicked element is the overlay itself and not the content inside (LoginModal)
    if (event.target === event.currentTarget) {
      props.onClose();
    }
  };

  return ReactDOM.createPortal(
    <>
      <OverlayStyle onClick={handleOverlayClick}>
        <LoginModal />
      </OverlayStyle>
    </>,
    document.getElementById("modal-root")
  );
}

function LoginModal(props) {
  const { connectors, connect } = useConnectors();

  return (
    <div style={LOGIN_STYLES}>
      {connectors.map((connector) => {
        return (
          <div>
            <span>{connector.id}</span>
            <button key={connector.id} onClick={() => connect(connector)}>
              connect
            </button>
          </div>
        );
      })}
    </div>
  );
}

const LOGIN_STYLES = {
  position: "fixed",
  top: "50%",
  left: "50%",
  transform: "translate(-50%,-50%)",
  backgroundColor: "var(--forrestGreen)",
  padding: "2rem",
  zIndex: "2000",
  display: "grid",
  borderRadius: "0.5rem",
  maxWidth: "500px",
};

// export default Modal;
