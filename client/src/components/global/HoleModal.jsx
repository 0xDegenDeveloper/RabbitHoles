import React from "react";
import Modal from "./Modal";

import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

export default function HoleModal(props) {
  const navigate = useNavigate();
  const { digger, id, digs, depth, timestamp, title } = props.hole;
  const holes = props.holes;
  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
        <h1>
          <span>Hole</span> #{id}/{holes}
        </h1>
        <p>
          <span>title </span>
          {title}
        </p>
        <p
          onClick={() => {
            navigate("/user");
          }}
          className="toggler"
        >
          <span>digger </span>
          {digger}
        </p>
        <p>
          <span>digs </span>
          {digs}
        </p>
        <p>
          <span>depth </span>
          {depth}
        </p>

        <p>
          <span>timestamp </span>
          {timestamp}
        </p>

        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={() => props.onClose(false)}
          className="x"
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
  /* max-width: 500px; */
  white-space: pre-wrap;
  max-width: 600px;
  cursor: default;
  h1 {
    margin: 0.5rem 0;
  }

  .toggler {
    cursor: pointer;
    border: 1px solid var(--forrestGreen);
    :hover {
      border: 1px solid var(--limeGreen);
      /* border-radius: 0.5rem; */
    }
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
  }

  /* svg {
    color: var(--limeGreen);
    padding: 0.5rem;
    font-size: clamp(10px, 5vw, 25px);
    text-align: center;
  }

  svg:hover {
    color: var(--limeGreen);
    cursor: pointer;
    box-shadow: 0 0 5px var(--limeGreen);
    border-radius: 33%;
  }

  .top-right {
    position: absolute;
    top: 1rem;
    right: 1rem;

    svg {
      color: var(--lightGreen);

      &:hover {
        color: var(--limeGreen);
      }
    }
  } */
`;
