import React from "react";
import Modal from "./global/Modal";
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

  const maxIndex = 3;

  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
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
              In return the digger is minted the <span>dig reward</span>{" "}
              ($RBITS)
            </p>
          </>
        )}
        {index === 2 && (
          <>
            <h1>Burning a Rabbit</h1>
            <p>
              A <span>Rabbit</span> is a user's comment in a <span>Hole</span>.
              This comment is an array of felts. The length of this array is
              referred to as the <span>Rabbit</span>'s <span>depth</span>.
            </p>
            <p>
              To burn a <span>Rabbit</span>, a user will spend some of their
              $RBITS
            </p>
            <p>
              <span className="blue">
                {" > "}The cost to leave a Rabbit is 1.000000 $RBITS for each
                felt stored
              </span>
            </p>
          </>
        )}
        {index === 3 && (
          <>
            <h1>...</h1>
            <p>
              When a user burns a <span>Rabbit</span>, the <span>Hole</span>'s
              digger receives a percentage of the spent $RBITS, the rest are
              burned.
            </p>
            <p>
              The <span>digger BPS</span> determines how many of these $RBITS
              are sent to the digger.
            </p>
            <p>
              <span className="blue">
                {" > "}"the following message that is 43 characters" would span
                2 felts, costing 2.000000 $RBITS
              </span>
            </p>
            <p>
              <span className="blue">
                {" > "}With a digger BPS of 25%, 0.500000 are sent to the
                digger, 1.500000 are burned
              </span>
            </p>
          </>
        )}
        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={props.onClose}
          className="x"
        />
        <FontAwesomeIcon
          icon={faArrowCircleLeft}
          onClick={() => setIndex(index == 1 ? index : index - 1)}
          className={`bottom left ${index == 1 ? "fill" : ""}`}
        />
        {/* <FontAwesomeIcon icon={faChevronLeft} className="bottom" /> */}
        {/* <FontAwesomeIcon icon={faChevronRight} className="bottom" /> */}
        <div id="bottom" className="bottom">
          <p>
            {index} / {maxIndex}
          </p>
        </div>
        <FontAwesomeIcon
          icon={faArrowCircleRight}
          onClick={() => setIndex(index == maxIndex ? index : index + 1)}
          className={`bottom right ${index == maxIndex ? "fill" : ""}`}
        />
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
  min-height: 300px;
  height: fit-content;

  p {
    color: var(--lightGreen);
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

    position: absolute;
    font-size: 1.5rem;

    &:hover {
      color: var(--limeGreen);
      transform: scale(1.05); /* Example of scaling on hover */

      &.fill {
        color: var(--forrestGreen);
        cursor: default;
      }
    }

    &.x {
      top: 1rem;
      right: 1rem;
    }

    &.bottom {
      bottom: 1rem;

      &.left {
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
      }
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
