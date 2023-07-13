import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faFireAlt } from "@fortawesome/free-solid-svg-icons";
import { useNavigate, useParams } from "react-router-dom";
import { useState } from "react";
import { stringToFelts } from "../components/utils/Utils";

export default function BurnRabbitPage(props) {
  const { key } = useParams();
  const holeTitle = key ? key.toUpperCase() : "";

  const [msg, setMsg] = useState("");
  const felts = stringToFelts(msg);

  function handleBurning() {
    alert(
      "Thank you for your support, but our contracts are still under development!"
    );
  }

  if (holeTitle == "")
    return (
      <>
        <div className="container">
          <div className="dark-box-600w info">
            <h2 style={{ color: "var(--limeGreen)" }}>
              &gt; Oops that hole isn't dug yet
            </h2>
          </div>
        </div>
      </>
    );

  return (
    <>
      <div className="container">
        <Wrapper>
          <div className="dark-box-600w info">
            <h2>&gt; Hole: "{holeTitle}"</h2>
            <textarea
              placeholder={"burn a rabbit..."}
              onChange={(event) => setMsg(event.target.value)}
              onKeyDown={(event) => {
                if (event.key == "Enter") {
                  handleBurning();
                }
              }}
            ></textarea>

            {!props.mobile && (
              <div className="felts">
                {Array.isArray(felts) ? (
                  felts.map((felt, index) => (
                    <h6 key={index} style={{ color: "var(--lightGreen)" }}>
                      &lt;{felt}&gt;
                    </h6>
                  ))
                ) : (
                  <h6 style={{ color: "var(--lightGreen)" }}>
                    &lt;{felts}&gt;
                  </h6>
                )}
              </div>
            )}

            <SearchBtn>
              <FontAwesomeIcon
                icon={faFireAlt}
                onClick={() => {
                  handleBurning();
                }}
              ></FontAwesomeIcon>
            </SearchBtn>
          </div>
        </Wrapper>
      </div>
    </>
  );
}

const Wrapper = styled.div`
  display: grid;
  grid-template-columns: auto;
  grid-template-rows: auto auto;
  gap: 1rem;
  text-align: center;
  margin: auto 0;
  user-select: none;

  em {
    color: var(--forrestGreen);
  }

  .info h1 {
    color: var(--lightGreen);
  }

  h6 {
    font-size: clamp(0.5px, 0.75vw, 10px);
    margin: 0;
    padding: 0;
  }

  .felts {
    max-height: 50px;
    overflow-y: scroll;
    padding: 1rem 0;
  }

  .info {
    input,
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
  }
`;

const SearchBtn = styled.div`
  color: var(--limeGreen);
  font-size: 1.5rem;
  padding-right: 0.5rem;
  margin-left: auto;
  display: grid;

  :hover {
    cursor: pointer;
    color: var(--lightGreen);
  }

  svg {
    margin-left: auto;
  }
`;
