import {
  faArrowUpRightFromSquare,
  faInfoCircle,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import styled from "styled-components";
import { StyledBox } from "./StatsPage";
import FlowModal from "../components/FlowModal";
import {
  faGit,
  faGithub,
  faTwitch,
  faTwitter,
} from "@fortawesome/free-brands-svg-icons";

const W = styled(StyledBox)`
  svg {
  }
`;

export default function InfoPage(props) {
  return (
    <>
      {/* <div className="container">
        <Wrapper className="">
          <div className="dark-box-600w box">
            <div className="section-one">
              <h1>&gt; RabbitHoles</h1>
              <h4>
                - $RBITS are ERC-20 tokens abstracted to create a permanent and
                censorship-resistant discussion board. Users dig holes and burn
                rabbits.
              </h4>
              <h4>- Digging a hole creates a discussion topic.</h4>
              <h4>- Burning a rabbit adds a message to the discussion.</h4>
            </div>
            <div className="section-two">
              <h1>&gt; Technicals</h1>
              <h3 style={{ color: "var(--limeGreen)" }}>::Holes</h3>
              <h4>- Each dig will cost approximately 0.001Ξ.</h4>
              <h4>- Each dig will mint around 25.0 RBITS to the digger.</h4>           
              <h4>
                - A hole's title must fit into a single <em>felt252</em> (31
                characters or less).
              </h4>
              <h3 style={{ color: "var(--limeGreen)" }}>::Rabbits</h3>
              <h4>
                - A rabbit's message will fill consecutive slots in a global
                LegacyMap(<em>u64</em> =&gt; <em>felt252</em>).
              </h4>
              <h4>
                - To burn a rabbit, users will need to burn some of their RBITS.
              </h4>
              <h4>
                - For every <em>felt252</em> slot filled by a rabbit's message,
                1.0 RBIT will be burned.
              </h4>
            </div>
            <div className="section-three">
              <h1>
                <em>&gt; Further</em>
              </h1>
              <h4>
                -Additional details and the contract progress can be tracked{" "}
                <a
                  target="_blank"
                  href="https://github.com/0xDegenDeveloper/RabbitHoles"
                >
                  here <FontAwesomeIcon icon={faArrowUpRightFromSquare} />
                </a>
              </h4>
            </div>
          </div>
         
        </Wrapper>
      </div> */}
      <Wrapper className="container">
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
            maxWidth: "600px",
            width: "clamp(100px, 55vw, 500px)",
            overflow: "hidden",

            padding: "2rem",
          }}
        >
          <h1 style={{ color: "var(--limeGreen)" }}>RabbitHoles</h1>
          <h4>
            A discussion platform built on Starknet, offering a space for
            permanent and censorship-resistant conversations
          </h4>
          <h4>
            We are currently under development and will be launching soon. An
            off-chain demo can be found at{" "}
            <a
              target="_blank"
              href="https://demo.rbits.space"
              style={{ color: "var(--limeGreen)" }}
            >
              demo.rbits.space
            </a>
          </h4>
          <p>
            <FontAwesomeIcon
              icon={faInfoCircle}
              onClick={() => props.onClose(true)}
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
        </div>
        <img src="/logo-main.png" />
      </Wrapper>
      {props.modal && (
        <FlowModal modal={props.modal} onClose={() => props.onClose(false)} />
      )}
    </>
  );
}

const ImgWrapper = styled.div`
  margin-top: 1rem;
  display: grid;
  place-items: center;

  img {
    width: clamp(50px, 30vw, 100px);

    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
    }
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
`;

const Wrapper = styled.div`
  display: grid;
  place-items: center;
  align-content: center;

  svg {
    color: var(--limeGreen);
    font-size: clamp(15px, 5vw, 25px);
    margin: 0 1rem;

    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
    }
  }

  img {
    margin-top: 3rem;
    width: clamp(50px, 30vw, 100px);

    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
    }
  }

  .dark-box-600w {
    margin: 0;
  }

  .token-logo {
    margin-top: 1rem;
    display: grid;
    place-items: center;

    img {
      width: clamp(50px, 30vw, 100px);

      :hover {
        cursor: pointer;
        animation: rotate360 3s infinite ease-in-out;
      }
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
