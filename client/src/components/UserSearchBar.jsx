import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faMagnifyingGlass,
  faUser,
  faUserAlt,
  faUserAltSlash,
  faUserAstronaut,
} from "@fortawesome/free-solid-svg-icons";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

export default function UserSearchBar(props) {
  const [input, setInput] = useState("");
  const navigate = useNavigate();

  const addr = "0x1234...abcd";

  function passInput() {
    navigate(`/user/${input}`);
  }

  useEffect(() => {
    document.getElementById("search-input").placeholder = props.user;
  }, [props.user]);

  return (
    <>
      <div className="dark-search-bar">
        <input
          className="dark-search-bar-input"
          id="search-input"
          placeholder={props.user == addr ? "Discorver users..." : props.user}
          onChange={(event) => setInput(event.target.value)}
          onKeyDown={(event) => {
            if (event.key == "Enter") {
              passInput();
            }
          }}
        ></input>
        <div id="h" className={`dark-search-bar-button ${"two"}`}>
          <FontAwesomeIcon
            icon={faUserAstronaut}
            onClick={() => {
              passInput();
            }}
          ></FontAwesomeIcon>
        </div>
      </div>
    </>
  );
}
