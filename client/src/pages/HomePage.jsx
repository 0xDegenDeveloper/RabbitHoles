import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faMagnifyingGlass } from "@fortawesome/free-solid-svg-icons";
import { useState } from "react";
import styled from "styled-components";
import { useNavigate } from "react-router-dom";

export default function HomePage() {
  const [input, setInput] = useState("");
  const navigate = useNavigate();

  function passInput() {
    let url = "";

    if (input.toLocaleUpperCase() == "JEFFERY EPSTEIN") url = "/archive/4";
    else if (input.toLocaleUpperCase() == "BREATHWORK") url = "/archive/2";
    else if (input.toLocaleUpperCase() == "SHOWER THOUGHTS") url = "/archive/1";
    else if (input.toLocaleUpperCase() == "CONSPIRACY THEORIES")
      url = "/archive/3";
    else url = "/dig-hole/" + input.toUpperCase();

    navigate(url);
  }

  function setTheInput(_input) {
    setInput(_input);
  }

  return (
    <>
      <div className="container">
        {/* <SearchBox>
          <SearchBar
            placeholder="Enter the RabbitHole..."
            onChange={(event) => setTheInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key == "Enter") {
                passInput();
              }
            }}
          ></SearchBar>
          <SearchBtn className={input == "" ? "one" : "two"}>
            <FontAwesomeIcon
              icon={faMagnifyingGlass}
              onClick={() => {
                passInput();
              }}
            ></FontAwesomeIcon>
          </SearchBtn>
        </SearchBox> */}
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
