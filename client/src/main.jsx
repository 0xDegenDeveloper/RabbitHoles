import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";
import { InjectedConnector, StarknetConfig } from "@starknet-react/core";

const connectors = [
  new InjectedConnector({ options: { id: "braavos" } }),
  new InjectedConnector({ options: { id: "argentX" } }),
];

ReactDOM.createRoot(document.getElementById("root")).render(
  // <React.StrictMode>
  <StarknetConfig autoConnect connectors={connectors}>
    <App />
  </StarknetConfig>
  // </React.StrictMode>
);
