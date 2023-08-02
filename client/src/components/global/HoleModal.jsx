import React from "react";
import Modal from "./Modal";

import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowsToCircle,
  faXmarkCircle,
} from "@fortawesome/free-solid-svg-icons";
import { useNavigate } from "react-router-dom";

import { ContainerStyled } from "./RabbitModal";

export default function HoleModal(props) {
  const navigate = useNavigate();
  const { digger, id, digs, depth, timestamp, title } = props.hole;
  const holes = props.holes;
  return (
    <Modal modal={props.modal} onClose={props.onClose}>
      <ContainerStyled className="dark-box-600w">
        <h1>
          <span>Hole</span> #{id}/{holes}
        </h1>

        <p
          onClick={() => {
            props.onClose(false);
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
