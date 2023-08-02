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
        <Wrap
          className="dark-box-600w"
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
            gap: "0",
            position: "relative",
            textAlign: "center",
            cursor: "default",
            // minWidth: "clamp(75px, 55vw, 500px)",
            // minWidth: "clamp(75px, 55vw, 500px)",
          }}
        >
          <h1 style={{ color: "var(--limeGreen)" }}>Metrics</h1>
          <h4>
            Supply::<em> {totalSupply}</em>
            <img src={`/logo-full-lime.png`} />
          </h4>
          <h4>
            Dig Fee/Reward::
            <em>
              {digFee}Ξ/{digReward}
            </em>
            <img src={`/logo-full-lime.png`} />
          </h4>
          <h4>
            Digger BPS::<em>{(parseFloat(diggerBps) / 100.0).toFixed(0)}%</em>
          </h4>
          <h1 style={{ color: "var(--limeGreen)" }}>Stats</h1>
          <h4>
            Holes::<em>{holes}</em>
            {"::"}Rabbits::<em>{rabbits}</em>
            {"::"}Depth::<em>{depth}</em>
          </h4>
          <StyledBox>
            <FontAwesomeIcon
              icon={faInfoCircle}
              onClick={() => props.onClose(true)}
            />
          </StyledBox>
        </Wrap>
      </div>

      {props.modal && (
        <FlowModal
          modal={props.modal}
          onClose={() => props.onClose(false)}
          mobile={props.mobile}
        />
      )}
    </>
  );
}

const Wrap = styled.div`
  /* width: clamp(100px, 55vw, 500px); */

  img {
    height: clamp(22px, 3vw, 32px);
  }

  h4 {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;

    /// center vertically
  }
`;

export const StyledBox = styled.div`
  position: absolute;
  top: 1rem;
  right: 1rem;
  font-size: clamp(10px, 4vw, 25px);
  cursor: pointer;

  &:hover {
    color: var(--limeGreen);
  }

  img {
    height: clamp(27px, 3vw, 32px);
  }
`;
