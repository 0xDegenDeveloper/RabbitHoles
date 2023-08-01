import React from "react";
import Modal from "./Modal";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faFireFlameCurved,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useState } from "react";
import { stringToFelts } from "../utils/Utils";
export default function BurnModal(props) {
  const [msg, setMsg] = useState("");
  const felts = stringToFelts(msg);

  function handleBurning() {
    alert(
      "Thank you for your support, but our contracts are still under development!"
    );
    console.log("burning...");
  }
  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <StyledBox className="dark-box-600w">
        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={() => props.onClose(false)}
          className="x"
        />
        <h2>
          <span>Hole </span># {props.hole.id} {props.hole.title}
        </h2>
        <textarea
          placeholder="burn a rabbit..."
          onChange={(event) => setMsg(event.target.value)}
          onKeyDown={(event) => {
            if (event.key == "Enter") {
              handleBurning();
            }
          }}
        ></textarea>
        <p>
          <span>depth: </span>
          {stringToFelts(msg).length}
          <img src={"/logo-full-lime.png"} alt="logo" className="logo" />
          <FontAwesomeIcon
            className="burn"
            icon={faFireFlameCurved}
            onClick={() => handleBurning()}
          />
        </p>
        {/* <div className="w"></div> */}
      </StyledBox>
    </Modal>
  );
}

const StyledBox = styled.div`
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
  /* max-width: 500px; */
  white-space: pre-wrap;
  max-width: 600px;
  cursor: default;

  img {
    /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
    height: clamp(27px, 3vw, 32px);
    padding: 0;
    margin: 0;
  }
  h1 {
    margin: 0.5rem 0;
  }
  p {
    display: flex;
    align-items: center;
  }

  textarea {
    min-height: 100px;
    background-color: rgba(0, 0, 0, 0);
    border: none;
    resize: vertical;

    ::placeholder {
      color: var(--greyGreen);
    }
    color: var(--limeGreen);
    :focus {
      outline: none;
    }
    font-family: inherit;
    width: 100%;
  }

  span {
    color: var(--lightGreen);
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

    &.burn {
      margin-left: auto;
      position: relative;
      /* bottom: 1rem;
      right: 1rem; */
    }
  }
`;
