import React from "react";
import Modal from "./global/Modal";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faX, faXmarkCircle } from "@fortawesome/free-solid-svg-icons";

export default function StatisticsInfoModal(props) {
  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
        <p>
          To dig a <span>hole</span>, a user will pay a <span>fee</span>, in
          return they are minted a <span>reward</span>. Burning a{" "}
          <span>rabbit</span> will cost the user $RBITS
        </p>
        <p>
          <span className="blue">
            {" > "}A rabbit is a message stored as an array of felts
          </span>
        </p>
        <p>
          <span className="blue">
            {" > "}A felt can store at most 31 characters
          </span>
        </p>

        <p>
          <span className="blue">
            {" > "}
            The cost to leave a rabbit is 1.000000 $RBITS for each felt stored
          </span>
        </p>
        <p>
          The number of felts a message fills is referred to as its{" "}
          <span>depth</span>.
        </p>
        <p>
          The <span>digger bps</span> determines how many of these $RBITS are
          sent to the hole's digger, the rest are burned.
        </p>
        <FontAwesomeIcon icon={faXmarkCircle} onClick={props.onClose} />
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
  width: clamp(100px, 40vw, 500px);
  text-align: center;
  /* white-space: pre-wrap; */

  white-space: pre-wrap;

  p {
    color: var(--lightGreen);
  }

  span {
    color: var(--limeGreen);
  }

  svg {
    color: var(--lightGreen);
    cursor: pointer;
    top: 1rem;
    right: 1rem;
    position: absolute;
    font-size: 1.5rem;

    &:hover {
      color: var(--limeGreen);
      transform: scale(1.05); /* Example of scaling on hover */
    }
  }

  /* .blue {
      color: var(--lightGreen);
    } */

  h2 {
    /* text-align: center; */
    font-size: clamp(8px, 4vw, 15px);
    color: var(--greyGreen);
    /* padding: 0.5rem; */
    /* margin: 0; */
  }
`;
