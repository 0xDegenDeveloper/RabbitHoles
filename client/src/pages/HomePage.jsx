import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faMagnifyingGlass } from "@fortawesome/free-solid-svg-icons";
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { stringToFelts } from "../components/utils/Utils";

import { useContractRead, useContract } from "@starknet-react/core";
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

export default function HomePage() {
  const [input, setInput] = useState("");
  const [submittedInput, setSubmittedInput] = useState("");
  const navigate = useNavigate();

  function passInput() {
    let url = "";

    if (input.length > 31) return;

    // fetch hole id from title

    // if (input.toLocaleUpperCase() == "JEFFERY EPSTEIN") url = "/archive/4";
    // else if (input.toLocaleUpperCase() == "BREATHWORK") url = "/archive/2";
    // else if (input.toLocaleUpperCase() == "SHOWER THOUGHTS") url = "/archive/1";
    // else if (input.toLocaleUpperCase() == "CONSPIRACY THEORIES")
    //   url = "/archive/3";
    // else url = "/dig-hole/" + input.toUpperCase();

    navigate("/middle/" + input.toUpperCase());
  }

  // const navigate = useNavigate();

  function setTheInput(_input) {
    setInput(_input);
  }

  return (
    <>
      {/* <fetchHoleIdFromTitle title={submittedInput} /> */}
      <div className="container">
        <div className="dark-search-bar">
          <input
            className="dark-search-bar-input"
            placeholder="Enter the RabbitHole..."
            onChange={(event) => setTheInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key == "Enter") {
                passInput();
              }
            }}
            maxLength={31}
          ></input>
          <div
            className={`dark-search-bar-button ${input == "" ? "one" : "two"}`}
          >
            <FontAwesomeIcon
              icon={faMagnifyingGlass}
              onClick={() => {
                passInput();
              }}
            ></FontAwesomeIcon>
          </div>
        </div>
      </div>
    </>
  );
}
