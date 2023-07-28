import React from "react";
import styled from "styled-components";
import { useState, useEffect, useMemo } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { stringToFelts } from "../components/utils/Utils";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import HoleSearching from "../components/digging/HoleSearching";
import HoleExists from "../components/digging/HoleExists";
import HoleDoesNotExists from "../components/digging/HoleDoesNotExist";
import HoleErrror from "../components/digging/HoleError";
import EmptyTitle from "../components/digging/EmptyTitle";

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
        {key == undefined ? (
          <EmptyTitle />
        ) : (
          <>
            {isError && <HoleErrror isError={isError} title={key} />}
            {isLoading && <HoleSearching />}
            {data &&
              (data == 0 ? (
                <HoleDoesNotExists title={key} />
              ) : (
                <HoleExists title={key} data={data} />
              ))}
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
  justify-content: center;

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
