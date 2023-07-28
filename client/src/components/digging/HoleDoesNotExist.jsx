import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faDigging } from "@fortawesome/free-solid-svg-icons";
import { StyledBox } from "../../pages/DiggingPage";

export default function HoleDoesNotExist(props) {
  return (
    <StyledBox className="dark-box-600w">
      <h2>Not Dug Yet!</h2>
      <h4>"{props.title}" has not been dug yet, do you want to dig it?</h4>
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
  );
}
