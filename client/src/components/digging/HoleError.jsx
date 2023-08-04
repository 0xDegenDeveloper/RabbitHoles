import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { StyledBox } from "../../pages/DiggingPage";
import { faRotateBack } from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

export default function HoleError(props) {
  const navigate = useNavigate();
  return (
    <StyledBox className="dark-box-600w">
      <h2>Error looking up hole "{props.title}"</h2>
      <h4>{props.isError}</h4>
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
