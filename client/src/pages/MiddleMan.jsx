import React from "react";
import styled from "styled-components";
import { useState, useEffect, useMemo } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { stringToFelts } from "../components/utils/Utils";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faArrowsToCircle, faDigging } from "@fortawesome/free-solid-svg-icons";

import {
  useContractRead,
  useContract,
  useBlockNumber,
} from "@starknet-react/core";
import REGISTRY_ABI from "../assets/rabbitholes_ERC20.sierra.json";

const ABI = REGISTRY_ABI.abi;

const MANAGER_ADDRESS =
  "0x026a60f9b16975e44c11550c2baff45ac4c52d399cdccab5532dccc73ffa3298";
const RBITS_ADDRESS =
  "0x06a3e59fce87072a652e7d67df0782e89b337b65ff50f1d8553e990dd3c95cef";
const REGISTRY_ADDRESS =
  "0x026377bcc9b973eae8500eca7f916e42a645ffd4b15146e62b69e57e958502fc";
const V1_ADDRESS =
  "0x01c8ca977ca1c5721fb5150f63b1ae5b75e6155ef9b4e0f19acc9082d8c7fff3";

function fetchID(title) {
  //   const { data, isLoading, error, refetch } = useContractRead({
  //     address: REGISTRY_ADDRESS,
  //     abi: ABI,
  //     functionName: "is_minting",
  //     args: [],
  //     // args: [stringToFelts(title)],
  //     watch: true,
  //     blockIdentifier: "11111",
  //   });

  const { data, isLoading, isError } = useBlockNumber({
    refetchInterval: false,
  });

  //   useMemo(() => {
  //     if (isLoading) return;
  //     if (isError) return;

  //     /// delay 2 seconds
  //     setTimeout(() => {
  //       console.log("waiting...");

  //       setTheData(data);
  //     }, 2000);
  //   }, [data, isError]);

  //   useEffect(() => {
  //     setTheData(data);
  //   }, [theData]);

  return { data, isLoading, isError };
}

export default function MiddleMan() {
  const { key } = useParams();
  const { data, isLoading, isError } = fetchID(key);
  const navigate = useNavigate();

  console.log("data fetched", data);

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
        {isError && (
          <StyledBox className="dark-box-600w">
            <h2 style={{ color: "var(--limeGreen)" }}>Error</h2>
            <h4>{isError}</h4>
          </StyledBox>
        )}

        {isLoading && (
          <StyledBox className="dark-box-600w">
            <h2 style={{ color: "var(--limeGreen)" }}>Verifying...</h2>
            <h4>A hole can be dug only once</h4>
          </StyledBox>
        )}

        {data &&
          (data == 0 ? (
            <StyledBox className="dark-box-600w">
              <h2>Not Dug Yet!</h2>
              <h4>"{key}" has not been dug yet, do you want to dig it?</h4>
              <div className="btn-container">
                <FontAwesomeIcon
                  icon={faDigging}
                  onClick={() => {
                    //   handleDigging();
                    console.log("digging...");
                  }}
                ></FontAwesomeIcon>
              </div>
            </StyledBox>
          ) : (
            <StyledBox className="dark-box-600w">
              <h2>Already Dug!</h2>
              <h4>
                "{key}" is hole {data} / 999999
              </h4>
              <div className="btn-container">
                <FontAwesomeIcon
                  icon={faArrowsToCircle}
                  onClick={() => {
                    navigate(`/archive/${data}`);
                  }}
                ></FontAwesomeIcon>
              </div>
            </StyledBox>
          ))}
      </div>
    </div>
  );
}

const StyledBox = styled.div`
  color: var(--limeGreen);

  text-align: center;

  /* .btn-container {
    display: flex;
    justify-content: right;
    align-items: center;
  } */

  h4 {
    color: var(--lightGreen);
  }

  svg {
    color: var(--lightGreen);
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
`;
