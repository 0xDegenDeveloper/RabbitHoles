import React from "react";
import Modal from "./Modal";

import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

export default function RabbitModal(props) {
  const navigate = useNavigate();
  const { burner, id, depth, timestamp, msg } = props.rabbit;
  const rabbits = props.rabbits;
  const hole = props.hole;

  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
        <h1>
          <span>Rabbit</span> #{id}/{rabbits}
        </h1>
        <p
          onClick={() => {
            props.onClose(false);
            props.setIsHoles(false);
            navigate(`/user/${burner}`);
          }}
          className="toggler"
        >
          <span>burner </span>
          {burner}
        </p>
        <p
          className="toggler"
          onClick={() => {
            props.onClose(false);
            props.setIsHoles(true);
            navigate(`/archive/${hole.id}`);
          }}
        >
          <span>hole</span> #{props.hole.id} {hole.title}
        </p>
        <p>
          <span>depth </span>
          {depth}
        </p>
        <p>
          <span>msg </span>
          {msg}
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
        {props.useJump && (
          <div className="jump">
            <FontAwesomeIcon
              icon={faArrowsToCircle}
              onClick={() => {
                props.onClose(false);
                navigate(`/archive/${hole.id}`);
              }}
            />
          </div>
        )}
      </ContainerStyled>
    </Modal>
  );
}

export const ContainerStyled = styled.div`
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
  width: clamp(75px, 55vw, 500px);
  p {
    /* padding: 0.5rem 0rem; */
  }

  .jump {
    position: absolute;
    bottom: 1rem;
    left: 50%;
    padding: 2rem;
    transform: translateX(-50%);
    display: flex;
    justify-content: center;
    /* align-items: center; */
    width: 10%;

    svg {
      margin: 0 auto;
      color: var(--limeGreen);
      padding: 0.5rem;
      font-size: clamp(10px, 5vw, 20px);
      text-align: center;
    }

    svg:hover {
      color: var(--limeGreen);
      cursor: pointer;
      box-shadow: 0 0 5px var(--limeGreen);
      border-radius: 33%;
    }
  }

  .toggler {
    cursor: pointer;
    border: 1px solid var(--forrestGreen);
    border-style: dashed;
    border-bottom-color: var(--limeGreen);
    /* border-width: 30px; */
    :hover {
      border: 1px solid var(--limeGreen);
      /* border-radius: 0.5rem; */
    }
  }
  h1 {
    margin: 0.5rem 0;
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
`;
