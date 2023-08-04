import React from "react";
import styled from "styled-components";
import { useParams } from "react-router-dom";

import HoleSearching from "../components/digging/HoleSearching";
import HoleExists from "../components/digging/HoleExists";
import HoleDoesNotExists from "../components/digging/HoleDoesNotExist";
import HoleErrror from "../components/digging/HoleError";
import HoleTitleEmpty from "../components/digging/HoleTitleEmpty";
import fetchIdFromTitle from "../components/hooks/fetchIdFromTitle";

import HoleTitleTooBig from "../components/digging/HoleTitleTooBig";

export default function MiddleMan() {
  const { key } = useParams();
  // const { data, isLoading, isError } = fetchIdFromTitle(key); ** use when starknet-react updated
  const { id } = fetchIdFromTitle(key);

  return (
    <div className="container">
      <div
        style={{
          left: "50%",
          top: "50%",
          position: "absolute",
          transform: "translate(-50%, -50%)",
        }}
      >
        {key == undefined ? (
          <HoleTitleEmpty />
        ) : key.length > 31 ? (
          <>
            <HoleTitleTooBig />
          </>
        ) : (
          <>
            {/* {isError && <HoleErrror isError={isError} title={key} />}
            {isLoading && <HoleSearching />}
            {data &&
              (key == 0 ? (
                <HoleDoesNotExists title={key} />
              ) : (
                <HoleExists title={key} data={data} id={id} />
              ))} */}
            {id == 0 ? (
              <>
                <HoleDoesNotExists title={key} />
              </>
            ) : (
              <>
                <HoleExists title={key} id={id} />
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}

export const StyledBox = styled.div`
  color: var(--limeGreen);
  text-align: center;
  display: flex;
  flex-direction: column;
  /* justify-content: center; */
  cursor: default;

  min-width: clamp(75px, 55vw, 500px);
  min-height: 200px;
  padding: 1rem 2rem;

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
