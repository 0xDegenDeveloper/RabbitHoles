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
      color: var(--lightGreen);
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
