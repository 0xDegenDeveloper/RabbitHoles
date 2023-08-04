import { faInfoCircle } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import FlowModal from "../components/cards/FlowCard";

import styled from "styled-components";
import fetchGlobalStatistics from "../components/hooks/fetchGlobalStatistics";
import fetchGlobalMetrics from "../components/hooks/fetchGlobalMetrics";

export default function StatsPage(props) {
  const { holes, rabbits, depth } = props.globalStatistics;
  const { totalSupply, digFee, digReward, diggerBps } = fetchGlobalMetrics();

  console.log(props);

  return (
    <>
      <div className="container">
        <Wrap
          // className="dark-box-600w"
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
            gap: "0",
            position: "relative",
            textAlign: "center",
            cursor: "default",
          }}
        >
          <div
            className="statss dark-box-600w"
            style={{
              display: "flex",
              flexDirection: "column",
              justifyContent: "center",
              alignItems: "center",
              gap: "0",
              position: "relative",
              textAlign: "center",
              cursor: "default",
            }}
          >
            <h1 style={{ color: "var(--limeGreen)" }}>Metrics</h1>
            <h4>
              Supply::<em> {totalSupply}</em>
              <img className="spinner" src={`/logo-full-lime.png`} />
            </h4>
            <h4>
              Fee/Reward::
              <em>
                {digFee}Ξ/{digReward}
              </em>
              <img className="spinner" src={`/logo-full-lime.png`} />
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
                onClick={() => props.setModals.setInfoModal(true)}
              />
            </StyledBox>
          </div>
          <img src={"/logo-main.png"} className="token-logo" />
        </Wrap>
      </div>
    </>
  );
}

const WW = styled.div``;

const Wrap = styled.div`
  img {
    height: clamp(22px, 3vw, 32px);
  }

  .token-logo {
    /* img { */
    margin-top: 1rem;
    width: clamp(70px, 10vw, 100px);
    height: clamp(70px, 10vw, 100px);

    :hover {
      /* cursor: pointer; */
      animation: rotate360 3s infinite ease-in-out;
    }
  }

  h4 {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
  }

  .spinner {
    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
    }

    @keyframes rotate360 {
      0% {
        transform: rotate(0deg);
      }
      50%,
      52% {
        transform: rotate(720deg);
      }

      75%,
      100% {
        transform: rotate(0deg);
      }
    }
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
`;
