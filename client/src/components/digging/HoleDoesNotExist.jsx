import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faDigging, faRotateBack } from "@fortawesome/free-solid-svg-icons";
import { StyledBox } from "../../pages/DiggingPage";
import { useNavigate } from "react-router-dom";

export default function HoleDoesNotExist(props) {
  const navigate = useNavigate();
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
      <div className="btn-container top-right">
        <FontAwesomeIcon
          icon={faRotateBack}
          onClick={() => {
            navigate(`/`);
          }}
        ></FontAwesomeIcon>
      </div>
    </StyledBox>
  );
}
