import React from "react";
import styled from "styled-components";
import { useParams, useNavigate } from "react-router-dom";

import fetchIdFromTitle from "../components/hooks/fetchIdFromTitle";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faRotateBack,
  faDigging,
} from "@fortawesome/free-solid-svg-icons";

export default function MiddleMan(props) {
  const { key } = useParams();
  const navigate = useNavigate();
  // const { data, isLoading, isError } = fetchIdFromTitle(key); ** use when starknet-react updated
  const { id } = fetchIdFromTitle(key);

  return (
    <Wrapper className="container">
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
          cursor: "default",
        }}
      >
        {key == undefined ? (
          <>
            <h2>Oops!</h2>
            <h4>Are you sure you entered a title?</h4>
          </>
        ) : key.length > 31 ? (
          <>
            <h2>Oops!</h2>
            <h4>Your title is too long to fit into 1 felt</h4>
          </>
        ) : (
          <>
            {/* {isError && (
              <>
                <h2>Error looking up hole "{title}"</h2>
                <h4>{isError}</h4>
              </>
            )}
            {isLoading && (
            <>
              <h2>Error looking up hole "{props.title}"</h2>
      <h4>{props.isError}</h4>
            </>
            )
            } */}
            {/* {data &&(*/}
            {/* replace id with data in conditional */}
            {id == 0 ? (
              <>
                <h2>Not Dug Yet!</h2>
                <h4>"{key}" has not been dug yet, do you want to dig it?</h4>
                <div className="btn-container">
                  <FontAwesomeIcon
                    icon={faDigging}
                    onClick={() => {
                      alert(
                        "Thank you for your support, but our contracts are still under development!"
                      );
                      navigate(`/`);
                    }}
                    className="bottom"
                  ></FontAwesomeIcon>
                </div>
              </>
            ) : (
              <>
                <h2>Already Dug!</h2>
                <h4>
                  "{key}" is hole {id} / 111
                </h4>
                <div className="btn-container">
                  <FontAwesomeIcon
                    icon={faArrowsToCircle}
                    onClick={() => {
                      navigate(`/archive/${id}`);
                    }}
                    className="bottom"
                  ></FontAwesomeIcon>
                </div>
              </>
            )}
            {/* )} */}
          </>
        )}
        <div className="btn-container top-right">
          <FontAwesomeIcon
            icon={faRotateBack}
            onClick={() => {
              navigate(`/`);
            }}
          ></FontAwesomeIcon>
        </div>
      </div>
    </Wrapper>
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

  .dark-box-600w {
    text-align: center;
    position: relative;
    /* height: fit-content; */
    h4 {
      color: var(--lightGreen);
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
    }
  }
`;

export const StyledBox = styled.div`
  color: var(--limeGreen);
  text-align: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  cursor: default;

  min-width: clamp(75px, 55vw, 500px);
  /* min-height: 200px; */
  /* padding: 1rem 2rem; */
  width: clamp(75px, 60vw, 600px);

  /* .wrapper {
    width: clamp(75px, 60vw, 600px);
  } */

  h4 {
    color: var(--lightGreen);
  }

  h2 {
    color: var(--limeGreen);
  }

  .bottom {
    position: fixed;
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
  }
`;
