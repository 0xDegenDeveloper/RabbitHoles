import { faInfo, faInfoCircle } from "@fortawesome/free-solid-svg-icons";
import fetchGlobalStats from "../components/hooks/fetchGlobalStats";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { useState } from "react";
import FlowModal from "../components/FlowModal";

import styled from "styled-components";

export default function StatsPage(props) {
  const { holes, rabbits, depth, totalSupply, digFee, digReward, diggerBps } =
    fetchGlobalStats();

  return (
    <>
      <div className="container">
        <div
          className="dark-box-600w"
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
            gap: "0",
            position: "relative",
            textAlign: "center",
          }}
        >
          <h1 style={{ color: "var(--limeGreen)" }}>Metrics</h1>
          <h4>
            Supply: <em>{totalSupply} $RBITS</em>
          </h4>
          <h4>
            Dig Fee: <em>{digFee}Ξ</em>
            {" > "}Dig Reward: <em>{digReward} $RBITS</em>
          </h4>
          <h4>
            Digger BPS: <em>{(parseFloat(diggerBps) / 100.0).toFixed(3)}%</em>
          </h4>
          <h1 style={{ color: "var(--limeGreen)" }}>Stats</h1>
          <h4>
            Holes: <em>{holes}</em>
            {" > "}Rabbits: <em>{rabbits}</em>
            {" > "}Depth: <em>{depth}</em>
          </h4>
          <StyledBox>
            <FontAwesomeIcon
              icon={faInfoCircle}
              onClick={() => props.onClose(true)}
            />
          </StyledBox>
        </div>
      </div>

      {props.modal && (
        <FlowModal modal={props.modal} onClose={() => props.onClose(false)} />
      )}
    </>
  );
}

export const StyledBox = styled.div`
  position: absolute;
  top: 1rem;
  right: 1rem;
  font-size: clamp(10px, 4vw, 25px);
  cursor: pointer;

  &:hover {
    color: var(--limeGreen);
  }
`;
