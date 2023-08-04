import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { StyledBox } from "../../pages/DiggingPage";
import { faRotateBack } from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

export default function HoleTitleEmpty() {
  const navigate = useNavigate();

  return (
    <StyledBox className="dark-box-600w">
      <h2>Oops!</h2>
      <h4>Are you sure you entered a title?</h4>
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
