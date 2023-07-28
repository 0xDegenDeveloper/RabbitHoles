import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { StyledBox } from "../../pages/DiggingPage";

export default function HoleError(props) {
  return (
    <StyledBox className="dark-box-600w">
      <h2 style={{ color: "var(--limeGreen)" }}>
        Error looking up hole "{props.title}"
      </h2>
      <h4>{props.isError}</h4>
    </StyledBox>
  );
}
