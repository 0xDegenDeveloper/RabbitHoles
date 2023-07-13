import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCheck, faDigging, faX } from "@fortawesome/free-solid-svg-icons";
import { useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import { stringToFelts } from "../components/utils/Utils";

export default function DigHolePage(props) {
  const { key } = useParams();
  const [holeTitle, setHoleTitle] = useState(key ? key : "");
  const [checkOne, setCheckOne] = useState(
    holeTitle.length > 0 && holeTitle.length <= 31 ? true : false
  );
  const [checkTwo, setCheckTwo] = useState(true);

  const f = stringToFelts(holeTitle);
  const felts = Array.isArray(f) ? f[0] : f;

  function handleDigging() {
    console.log("trying to dig hole: ", holeTitle);
    console.log("checking format...");
    console.log("checking if hole exists...");
    console.log("simulating transaction...");

    console.log("doing txn");

    alert(
      "Thank you for your support, but our contracts are still under development!"
    );
  }

  function handleChecks() {
    setCheckOne(holeTitle.length > 0 && holeTitle.length <= 31 ? true : false);

    if (
      holeTitle == "JEFFERY EPSTEIN" ||
      holeTitle == "BREATHWORK" ||
      holeTitle == "CONSPIRACY THEORIES" ||
      holeTitle == "SHOWER THOUGHTS" ||
      holeTitle == ""
    ) {
      setCheckTwo(false);
    } else {
      setCheckTwo(true);
    }
  }

  useEffect(() => {
    handleChecks();
  }, [holeTitle]);

  return (
    <>
      <div className="container">
        <Wrapper>
          <div className="dark-search-bar">
            <input
              className="dark-search-bar-input"
              placeholder={holeTitle == "" ? "Dig a hole..." : holeTitle}
              onChange={(event) =>
                setHoleTitle(event.target.value.toUpperCase())
              }
              onKeyDown={(event) => {
                if (event.key == "Enter") {
                  handleDigging();
                }
              }}
            ></input>
            <div
              className={`dark-search-bar-button ${
                holeTitle == "" ? "one" : "two"
              }`}
              id="h"
            >
              <FontAwesomeIcon
                icon={faDigging}
                onClick={() => {
                  handleDigging();
                }}
              ></FontAwesomeIcon>
            </div>
          </div>
          <div className="clear-box-dark-border info" id="info">
            <h1>Dig Check</h1>
            <h4>
              &gt; Fits into a single felt252 ?{" "}
              <FontAwesomeIcon
                icon={checkOne ? faCheck : faX}
                style={
                  checkOne
                    ? {
                        color: "var(--lightGreen)",
                      }
                    : { color: "var(--limeGreen)" }
                }
              />
            </h4>
            <h4>
              &gt; Unique title ?{" "}
              <FontAwesomeIcon
                icon={checkTwo ? faCheck : faX}
                style={
                  checkTwo
                    ? {
                        color: "var(--lightGreen)",
                      }
                    : { color: "var(--limeGreen)" }
                }
              />
            </h4>
            {!props.mobile && (
              <div className="felts">
                <h6>&lt;{felts}&gt;</h6>
              </div>
            )}
          </div>
        </Wrapper>
      </div>
    </>
  );
}

const Wrapper = styled.div`
  user-select: none;
  display: grid;
  grid-template-columns: auto;
  grid-template-rows: auto auto;
  gap: 2rem;
  text-align: center;
  max-height: 60%;
  place-content: center;
  place-items: center;

  .felts {
    max-height: 100px;
    overflow-y: scroll;
    padding: 1rem 0;
  }

  h6 {
    font-size: clamp(2px, 1vw, 8px);
    margin: 0;
    padding: 0;
    color: var(--forrestGreen);
  }

  em {
    color: var(--forrestGreen);
  }

  .info {
    margin: 0 auto;
    font-size: clamp(6px, 2vw, 10px);
  }

  .info h1 {
    color: var(--forrestGreen);
  }

  input,
  textarea {
    font-size: clamp(5px, 3vw, 12px);
    :focus {
      outline: none;
    }
    /* width: 100%; */
  }
`;

const SearchBox = styled.div`
  display: flex;
  gap: 1rem;
  font-size: clamp(25px, 4vw, 50px);
  align-items: center;
  border-radius: 2rem;
  padding: 0.3rem 1rem;
  border: 3px solid var(--forrestGreen);
  background-color: var(--forrestGreen);
  color: var(--limeGreen);
  width: clamp(150px, 55vw, 500px);
  font-family: "Andale Mono", monospace;
  box-shadow: 0px 0px 5px 0px var(--forrestGreen);
  margin: 0 auto;
`;

const SearchBar = styled.input`
  border: none;
  background-color: rgba(0, 0, 0, 0);
  color: var(--lightGreen);
  font-family: "Andale Mono", monospace;
  text-transform: uppercase;
  height: 10px;
  min-height: 10px;
  resize: vertical;
  overflow: hidden;

  ::placeholder {
    color: var(--limeGreen);
  }

  @media only screen and (max-width: 760px) {
    min-height: 30px;
  }
`;

const SearchBtn = styled.div`
  color: var(--limeGreen);
  font-size: clamp(15px, 4vw, 20px);

  padding-right: 0.5rem;
  padding-left: 0.5rem;
  margin-left: auto;

  :hover {
    cursor: pointer;
    color: var(--lightGreen);
  }
`;
