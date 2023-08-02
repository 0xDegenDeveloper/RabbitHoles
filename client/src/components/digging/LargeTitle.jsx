import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { StyledBox } from "../../pages/DiggingPage";
import { faRotateBack } from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

export default function LargeTitle() {
  const navigate = useNavigate();

  return (
    <StyledBox className="dark-box-600w">
      <h2 style={{ color: "var(--limeGreen)" }}>Oops!</h2>
      <h4>Your title is too long to fit into 1 felt</h4>
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
