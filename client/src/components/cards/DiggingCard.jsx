import React from "react";
import Modal from "../global/Modal";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faDigging,
  faFireFlameCurved,
  faRotateBack,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useState } from "react";
import { stringToFelts } from "../utils/Utils";
import { useNavigate } from "react-router-dom";
import fetchIdFromTitle from "../hooks/fetchIdFromTitle";

export default function DiggingCard(props) {
  //   const { key } = useParams();
  const key = props.lookupTitle.toUpperCase();
  const navigate = useNavigate();
  //   // const { data, isLoading, isError } = fetchIdFromTitle(key); ** use when starknet-react updated
  const { id } = fetchIdFromTitle(key);

  console.log(props);

  return (
    <Modal modal={props.modals.diggingModal} onClose={props.onClose}>
      <Wrapper
      //   className="container"
      >
        <div
          className="dark-box-600w"
          style={{
            display: "flex",
            flexDirection: "column",
            // justifyContent: "center",
            alignItems: "center",
            gap: "0",
            position: "relative",
            textAlign: "center",
            whiteSpace: "wrap",
            cursor: "default",
            maxWidth: "500px",
            whiteSpace: "pre-wrap",
          }}
        >
          {key == "" ? (
            <>
              <h1>Oops!</h1>
              <p>Are you sure you entered a title?</p>
            </>
          ) : key.length > 31 ? (
            <>
              <h1>Oops!</h1>
              <p>Your title is too long to fit into 1 felt</p>
            </>
          ) : (
            <>
              {/* {isError && (
              <>
                <h1>Error looking up hole "{title}"</h1>
                <p>{isError}</p>
              </>
            )}
            {isLoading && (
            <>
              <h1>Error looking up hole "{props.title}"</h1>
      <p>{props.isError}</p>
            </>
            )
            } */}
              {/* {data &&(*/}
              {/* replace id with data in conditional */}
              {id == 0 ? (
                <>
                  <h1>Not Dug Yet</h1>
                  <p>"{key}" has not been dug yet, do you want to dig it?</p>
                  <div className="btn-container">
                    <FontAwesomeIcon
                      icon={faDigging}
                      onClick={() => {
                        alert(
                          "Thank you for your support, but our contracts are still under development!"
                        );
                        props.onClose(false);
                      }}
                      className="bottom rounded"
                    ></FontAwesomeIcon>
                  </div>
                </>
              ) : (
                <>
                  <h1>Already Dug!</h1>
                  <p>
                    "{key}" is hole {id} / 111
                  </p>
                  <div className="btn-container">
                    <FontAwesomeIcon
                      icon={faArrowsToCircle}
                      onClick={() => {
                        props.setModals.setDiggingModal(false);
                        navigate(`/archive/${id}`);
                      }}
                      className="bottom rounded"
                    ></FontAwesomeIcon>
                  </div>
                </>
              )}
              {/* )} */}
            </>
          )}
          <div className="btn-container top-right">
            <FontAwesomeIcon
              icon={faXmarkCircle}
              onClick={() => {
                props.setModals.setDiggingModal(false);
                props.onClose(false);
              }}
            ></FontAwesomeIcon>
          </div>
        </div>
      </Wrapper>
    </Modal>
  );
}

const Wrapper = styled.div`
  /* display: flex;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  flex-direction: column;
  align-items: left;
  justify-content: center;
  width: clamp(75px, 60vw, 600px);
  margin: 0; */
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 2000;

  .dark-box-600w {
    text-align: center;
    position: relative;
    padding: 2rem;

    p {
      /* font-size: clamp(12px, 3vw, 18px); */
      /* font-size: clamp(7px, 2.5vw, 18px); */
      font-size: clamp(10px, 3vw, 18px);
    }

    /* height: fit-content; */
    h4 {
      color: var(--lightGreen);
    }

    h1 {
      color: var(--limeGreen);
    }

    h2 {
      color: var(--limeGreen);
    }

    .bottom {
      position: absolute;
      bottom: 1rem;
      left: 50%;
      transform: translateX(-50%);
    }

    svg {
      color: var(--limeGreen);
      padding: 0.5rem;
      font-size: clamp(10px, 5vw, 20px);
      text-align: center;
    }

    svg:hover {
      color: var(--limeGreen);
      cursor: pointer;

      scale: 1.05;

      &.rounded {
        box-shadow: 0 0 5px var(--limeGreen);
        border-radius: 33%;
      }
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
    }
  }
`;

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
  /* white-space: pre-wrap; */
  max-width: 600px;
  cursor: default;

  img {
    /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
    /* height: clamp(27px, 3vw, 32px); */
    height: clamp(18px, 3vw, 32px);

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
