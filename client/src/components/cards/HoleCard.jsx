import React from "react";
import Modal from "../global/Modal";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

import { ContainerStyled } from "./RabbitCard";

export default function HoleModal(props) {
  const navigate = useNavigate();
  const { digger, id, digs, timestamp, title, depth } = props.modals.hole;
  const { holes } = props.globalStatistics;

  return (
    <Modal modal={props.modals.hole} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
        <h1>
          <span>Hole</span> #{id}/{holes}
        </h1>

        <p
          onClick={() => {
            props.onClose(false);
            props.setIsHoles(true);
            navigate(`/user/${digger}`);
          }}
          className="toggler"
        >
          <span>digger </span>
          {digger}
        </p>
        <p>
          <span>title </span>
          {title}
        </p>
        <p>
          <span>digs </span>
          {digs}
        </p>
        <p>
          <span>depth </span>
          {depth}
        </p>

        <p>
          <span>timestamp </span>
          {timestamp}
        </p>

        <FontAwesomeIcon
          icon={faXmarkCircle}
          onClick={() => props.onClose(false)}
          className="x"
        />
        {props.useJump && (
          <div className="jump">
            <FontAwesomeIcon
              icon={faArrowsToCircle}
              onClick={() => {
                props.onClose(false);
                navigate(`/archive/${id}`);
              }}
            />
          </div>
        )}
      </ContainerStyled>
    </Modal>
  );
}
