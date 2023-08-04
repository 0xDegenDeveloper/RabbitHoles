import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faRotateBack,
} from "@fortawesome/free-solid-svg-icons";
import { StyledBox } from "../../pages/DiggingPage";
import { useNavigate, useParams } from "react-router-dom";

export default function HoleExists(props) {
  const navigate = useNavigate();
  console.log(props);
  return (
    <StyledBox className="dark-box-600w">
      <h2>Already Dug!</h2>
      <h4>
        "{props.title}" is hole {props.id} / 111
      </h4>
      <div className="btn-container">
        <FontAwesomeIcon
          icon={faArrowsToCircle}
          onClick={() => {
            navigate(`/archive/${props.id}`);
          }}
          className="bottom"
        ></FontAwesomeIcon>
        <div className="btn-container top-right">
          <FontAwesomeIcon
            icon={faRotateBack}
            onClick={() => {
              navigate(`/`);
            }}
          ></FontAwesomeIcon>
        </div>
      </div>
    </StyledBox>
  );
}
