import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faMagnifyingGlass } from "@fortawesome/free-solid-svg-icons";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function HomePage(props) {
  const [input, setInput] = useState("");
  const navigate = useNavigate();

  function searchForHole() {
    if (input.length > 31) return;
    props.setLookupTitle(input);
    props.setModals.setDiggingModal(true);
    // navigate("/digging/" + input.toUpperCase());
  }

  return (
    <>
      <div className="container">
        <div className="dark-search-bar">
          <input
            className="dark-search-bar-input"
            placeholder="Enter the RabbitHole..."
            onChange={(event) => setInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key == "Enter") {
                searchForHole();
              }
            }}
            maxLength={31}
          ></input>
          <div className={`dark-search-bar-button two`}>
            <FontAwesomeIcon
              icon={faMagnifyingGlass}
              onClick={() => {
                searchForHole();
              }}
            ></FontAwesomeIcon>
          </div>
        </div>
      </div>
    </>
  );
}
