import React from "react";
import Modal from "../global/Modal";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowCircleLeft,
  faArrowCircleRight,
  faChevronLeft,
  faChevronRight,
  faDiceOne,
  faX,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";

import { useState } from "react";

export default function FlowModal(props) {
  const [index, setIndex] = useState(1);

  const maxIndex = 4;
  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w" mobile={props.mobile}>
        {index === 1 && (
          <>
            <h1>Digging a Hole</h1>
            <p>
              A <span>Hole</span> is a topic of discussion, stored in the
              contract as a felt.
            </p>
            <p>
              <span className="blue">
                {" > "}A felt can store at most 31 characters
              </span>
            </p>
            <p>
              To dig a <span>Hole</span>, a user must pay the{" "}
              <span>dig fee</span> ($ETH, $STRK, etc.)
            </p>
            <p>
              In return the digger is minted the <span>dig reward </span>
              ($RBITS).
            </p>
          </>
        )}
        {index === 2 && (
          <>
            <h1>Burning a Rabbit</h1>
            <p>
              A <span>Rabbit</span> is a user's msg in a <span>Hole</span>. This
              msg is an array of felts.
            </p>
            <p>
              The length of this array is referred to as the <span>Rabbit</span>
              's <span>depth</span>.
            </p>
            <p>
              To burn a <span>Rabbit</span>, a user will spend some of their
              $RBITS.
            </p>
            <p className="token spinnerY">
              <span className="blue">
                {" > "}cost = 1.000000
                <img src={`/logo-cropped-lime.png`} />
                &nbsp;per felt
              </span>
            </p>
          </>
        )}
        {index === 3 && (
          <>
            <h1>Cont.</h1>
            <p>
              For every <span>Rabbit</span> burned, its <span>Hole</span>'s
              digger receives a % of the spent $RBITS, the rest are burned.
            </p>
            <p>
              The <span>digger BPS</span> determines this %.
            </p>
            <p>
              <span className="blue">
                {" > "}If a msg is 32 characters, it fills 2 felts
              </span>
            </p>
            <p className="token spinnerY">
              <span className="blue">
                {" > "}cost = 2.000000
                <img src={`/logo-cropped-lime.png`} />
              </span>
            </p>
            <p>
              <span className="blue">
                {" > "}If BPS == 25%, 0.500000 are sent to the digger & 1.500000
                are burned
              </span>
            </p>
          </>
        )}
        {index === 4 && (
          <>
            <h1>Disclaimer</h1>
            <p>
              <span>$RBITS</span> are platform-specific utility tokens, and
              should not be considered securities.
            </p>
            <p>Fees collected from digs are for extending the project.</p>
            <img
              src={"/logo-main.png"}
              className="token-logo"
              onClick={() => {
                props.setDarkMode(!props.darkMode);
              }}
            />
          </>
        )}
        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={() => {
            props.onClose(false);
          }}
          className="x"
        />
        <div className="bottom indexer">
          <FontAwesomeIcon
            icon={faArrowCircleLeft}
            onClick={() => setIndex(index == 1 ? index : index - 1)}
            className={`${index == 1 ? "fill" : ""}`}
            // className={`bottom left ${index == 1 ? "fill" : ""}`}
          />

          <p>
            {index} / {maxIndex}
          </p>

          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() => setIndex(index == maxIndex ? index : index + 1)}
            className={`${index == maxIndex ? "fill" : ""}`}
            // className={`bottom right ${index == maxIndex ? "fill" : ""}`}
          />
        </div>
      </ContainerStyled>
    </Modal>
  );
}

const ContainerStyled = styled.div`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: var(--forrestGreen);
  color: var(--limeGreen);
  box-shadow: 0px 0px 25px 0px var(--forrestGreen);
  padding: 2rem;
  z-index: 2000;
  /* display: grid;
  grid-template-columns: 1fr; */
  /* flex-direction: column; */
  justify-content: center;
  border-radius: 1.5rem;
  max-width: 500px;
  width: clamp(100px, 55vw, 500px);
  text-align: center;
  white-space: pre-wrap;
  /* height: fit-content; */
  /* min-height: clamp(150px, 50vh, 400px); */
  min-height: ${(props) => (props.mobile ? "250px" : "375px")};
  /* height: fit-content; */
  cursor: default;

  .indexer {
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    /* width: 50%; */
    justify-content: center;
    align-items: center;
    gap: 1rem;
    margin: 0;
    padding: 0;
    font-size: clamp(10px, 3vw, 20px);
    /* padding-top: auto; */
    height: fit-content;
  }

  .token-logo {
    /* img { */
    margin-top: 1rem;
    width: clamp(70px, 10vw, 100px);
    height: clamp(70px, 10vw, 100px);
    border-radius: 50%;
    box-shadow: 0px 0px 5px 0px var(--greyGreen);

    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
      scale: 1.05;
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

  h1 {
    margin: 0;
  }

  p {
    color: var(--lightGreen);
    padding: 0;
    font-size: clamp(6px, 3vw, 18px);
  }

  span {
    color: var(--limeGreen);
  }

  svg {
    color: var(--lightGreen);
    cursor: pointer;

    &.fill {
      color: var(--forrestGreen);
    }

    /* position: absolute */
    &.x {
      font-size: clamp(10px, 4vw, 25px);
    }

    &:hover {
      color: var(--limeGreen);
      transform: scale(1.05); /* Example of scaling on hover */
      scale: 1.05;

      &.fill {
        color: var(--forrestGreen);
        cursor: default;
      }
    }

    &.x {
      position: absolute;
      top: 1rem;
      right: 1rem;
    }

    &.bottom {
      bottom: 1rem;

      /* &.left {
        left: 2rem;
        z-index: 2;
      }
      &.right {
        right: 2rem;
        z-index: 2;
      }
      &.center {
        position: absolute;
        bottom: 0;
        z-index: 0;
      } */
    }
  }

  #bottom {
    position: absolute;
    bottom: 0;
    left: 0;
    display: flex;
    justify-content: center;
    width: 100%;
    /* transform: translate(-50%, -50%); */
    /* margin: 0 auto; */
  }

  img {
    height: clamp(22px, 3vw, 32px);
    /* :hover {
      cursor: pointer;
    } */
  }

  .token span {
    /* display: ${(props) => (props.mobile ? "flex" : "flex")};
    align-items: ${(props) => (props.mobile ? "center" : "center")};
    justify-content: ${(props) => (props.mobile ? "center" : "center")};
    text-align: ${(props) => (props.mobile ? "center" : "center")}; */
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
  }

  /* .spinner {
    :hover {
      cursor: pointer;

      animation: rotate360Y 3s infinite ease-in-out;

      .token-logo {
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

    @keyframes rotate360Y {
      0% {
        transform: rotateY(0deg);
      }
      50%,
      52% {
        transform: rotateY(720deg);
      }

      75%,
      100% {
        transform: rotateY(0deg);
      }
    }
  } */

  /* .blue {
      color: var(--lightGreen);
    } */

  /* h1 {
    font-size: clamp(12px, 3vw, 25px);
  } */

  h2 {
    /* text-align: center; */
    font-size: clamp(8px, 3vw, 15px);
    color: var(--greyGreen);
    /* padding: 0.5rem; */
    /* margin: 0; */
  }
`;
