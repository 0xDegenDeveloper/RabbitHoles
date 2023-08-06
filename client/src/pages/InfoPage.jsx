import {
  faArrowUpRightFromSquare,
  faInfoCircle,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import styled from "styled-components";
import { StyledBox } from "./StatsPage";
import FlowModal from "../components/cards/FlowCard";
import { faGithub, faTwitter } from "@fortawesome/free-brands-svg-icons";

import tokenLogo from "/logo-main.png";

export default function InfoPage(props) {
  return (
    <>
      <Wrapper className="container" mobile={props.mobile}>
        <div
          className="dark-box-600w"
          id="special"
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            gap: "0",
            position: "relative",
            textAlign: "center",
            maxWidth: "500px",
            width: "clamp(75px, 55vw, 500px)",
            overflow: "scroll",
            padding: "2rem",
          }}
        >
          <h1 style={{ color: "var(--limeGreen)" }}>RabbitHoles</h1>
          <h4>
            A discussion platform built on Starknet, offering a space for
            permanent and censorship-resistant conversations
          </h4>
          <h4>
            We are currently under development and will be launching soon, treat
            this as a demo for now.
          </h4>
          <p>
            <FontAwesomeIcon
              icon={faInfoCircle}
              onClick={() => props.onClose(true)}
              className="info-icon"
            />{" "}
            <a target="_blank" href="https://twitter.com/degendeveloper">
              <FontAwesomeIcon
                icon={faTwitter}
                style={{
                  cursor: "pointer",
                }}
              />
            </a>{" "}
            <a
              target="_blank"
              href="https://www.github.com/0xDegenDeveloper/RabbitHoles"
            >
              <FontAwesomeIcon
                icon={faGithub}
                style={{
                  cursor: "pointer",
                }}
              />
            </a>
          </p>
          <img
            src={tokenLogo}
            onClick={() => {
              props.setDarkMode(!props.darkMode);
            }}
          />
        </div>
      </Wrapper>
      {/* {props.modal && (
        <FlowModal modal={props.modal} onClose={() => props.onClose(false)} />
      )} */}
    </>
  );
}

const Wrapper = styled.div`
  display: grid;
  place-items: center;
  align-content: center;
  overflow: scroll;

  .info-icon {
    position: absolute;
    top: 1rem;
    right: 1rem;
    font-size: clamp(10px, 4vw, 25px);
    cursor: pointer;
    margin: 0;
    color: var(--lightGreen);

    &:hover {
      cursor: pointer;
      color: var(--limeGreen);
      scale: 1.05;
    }
  }

  svg {
    color: var(--limeGreen);
    font-size: clamp(15px, 5vw, 25px);
    margin: 0 1rem;

    :hover {
      cursor: pointer;
      /* animation: rotate360 3s infinite ease-in-out; */
      color: var(--lightGreen);
      scale: 1.05;
    }
  }

  img {
    margin-top: 1rem;
    width: clamp(70px, 10vw, 100px);
    border-radius: 50%;
    box-shadow: 0px 0px 5px 0px var(--greyGreen);

    :hover {
      cursor: pointer;
      scale: 1.05;

      animation: rotate360 3s infinite ease-in-out;
    }
  }

  .dark-box-600w {
    margin: 0;

    /* justify-content: top; */
  }

  #special {
    min-height: 200px;
    height: ${(props) => (props.mobile ? "200px" : "fit-content")};
    overflow: scroll;
  }
`;
