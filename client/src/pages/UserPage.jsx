import React, { useState } from "react";
import styled from "styled-components";
import fetchUserStatistics from "../components/hooks/fetchUserStatistics";
import { useAccount } from "@starknet-react/core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faDigging,
  faFireFlameCurved,
  faMagnifyingGlass,
} from "@fortawesome/free-solid-svg-icons";
import { ArchivePageStyled } from "./ArchivePage";

function Rabbit({ rabbit, userArchive, setUseJump, setModals }) {
  return (
    <div
      className="rabbit spinner"
      onClick={() => {
        setUseJump(true);
        setModals.setHole(userArchive.holes[rabbit.holeId - 1]);
        setModals.setRabbit(rabbit);
        setModals.setRabbitModal(true);
      }}
    >
      <p>{rabbit.msg}</p>
      <div className="r-stats">
        <p>{userArchive.holes[rabbit.holeId - 1].title}</p>
        <div className="ww">
          <div className="w">
            <img src={`/logo-full-dark.png`} alt="logo" />
          </div>
        </div>
        <div className="ww">
          <p>{rabbit.depth}</p>
          <div className="w">
            <img src={`/logo-full-lime.png`} alt="logo" className={`logo`} />
          </div>
        </div>
      </div>
    </div>
  );
}

function Hole({ hole, setUseJump, setModals }) {
  return (
    <div
      className="hole spinner"
      onClick={() => {
        setUseJump(true);
        setModals.setHole(hole);
        setModals.setHoleModal(true);
      }}
    >
      <p className="ital">{hole.title}</p>
      <div className="h-stats">
        <p>{hole.rabbits.length}</p>
        <FontAwesomeIcon icon={faFireFlameCurved} />
        <p>{hole.depth}</p>
        <div className="w">
          <img src={"/logo-full-lime.png"} alt="logo" className={`logo`} />
        </div>
      </div>
    </div>
  );
}

export default function UserPage(props) {
  const { isHoles, setIsHoles } = props;
  const { address } = useAccount();
  const addr = address ? address : "0x1234...5678";
  const user = `${addr.slice(0, 6)}...${addr.slice(-4)}`;

  return (
    <>
      <ArchivePageStyled
        className="container"
        isHoles={isHoles}
        mobile={props.mobile}
      >
        <div
          className="hole-head spinner"
          onClick={() => {
            setIsHoles(!isHoles);
          }}
        >
          <div className="top">
            <h1>{user}</h1>
            <div className="stats">
              {!props.mobile && <p>{props.userArchive.holes.length}</p>}
              <FontAwesomeIcon
                icon={faDigging}
                className={`${isHoles ? "active" : ""}`}
              />
              {!props.mobile && <p>{props.userArchive.rabbits.length}</p>}
              <FontAwesomeIcon
                icon={faFireFlameCurved}
                className={`${!isHoles ? "active" : ""}`}
              />
              {!props.mobile && (
                <>
                  <p>{props.userArchive.totalDepth}</p>
                  <div className="w">
                    <img
                      src={"/logo-full-dark.png"}
                      alt="logo"
                      className={`logo`}
                    />
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
        {!isHoles && (
          <div className="dark-box rabbits">
            {props.userArchive.rabbits.map((rabbit, index) => (
              <div key={index} className="rw">
                <Rabbit
                  rabbit={rabbit}
                  userArchive={props.userArchive}
                  {...props}
                />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        {isHoles && (
          <div className="dark-box rabbits">
            {props.userArchive.holes.map((hole, index) => (
              <div key={index} className="rw">
                <Hole hole={hole} {...props} />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
      </ArchivePageStyled>
    </>
  );
}

const VBar = styled.div`
  width: 0;
  height: 50%;
  margin: auto auto;
  border-left: 2px solid var(--forrestGreen);
`;
