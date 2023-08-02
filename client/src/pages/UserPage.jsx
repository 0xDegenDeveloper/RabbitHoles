import React, { useEffect, useState } from "react";
import styled from "styled-components";
import { useNavigate, useParams } from "react-router-dom";
import UserSearchBar from "../components/UserSearchBar";
import fetchUserData from "../components/hooks/fetchUserData";
import { useAccount } from "@starknet-react/core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faDigging,
  faFireFlameCurved,
  faMagnifyingGlass,
} from "@fortawesome/free-solid-svg-icons";
import { ArchivePageStyled } from "./ArchivePageNew";

function Rabbit({
  rabbit,
  userData,
  setUseJump,
  setHole,
  setRabbit,
  setRabbitModal,
}) {
  const [isHovered, setIsHovered] = useState(false);

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  return (
    <div
      className="rabbit"
      onClick={() => {
        setUseJump(true);
        setHole(userData.holes[rabbit.holeId - 1]);
        setRabbit(rabbit);
        setRabbitModal(true);
      }}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <p>{rabbit.msg}</p>
      <div className="r-stats">
        <p>{userData.holes[rabbit.holeId - 1].title}</p>
        <div className="ww">
          <div className="w">
            <img src={`/logo-full-dark.png`} alt="logo" />
          </div>
        </div>
        <div className="ww">
          <p>{rabbit.depth}</p>
          <div className="w">
            <img
              src={`/logo-full-lime.png`}
              alt="logo"
              className={`logo ${isHovered ? "spinner" : ""}`}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

function Hole({ hole, setUseJump, setHole, setHoleModal }) {
  const [isHovered, setIsHovered] = useState(false);

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };
  return (
    <div
      className="hole"
      onClick={() => {
        setUseJump(true);
        setHole(hole);
        setHoleModal(true);
      }}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <p className="ital">{hole.title}</p>
      <div className="h-stats">
        <p>{hole.rabbits.length}</p>
        <FontAwesomeIcon icon={faFireFlameCurved} />
        <p>{hole.depth}</p>
        <div className="w">
          <img
            src={"/logo-full-lime.png"}
            alt="logo"
            className={`logo ${isHovered ? "spinner" : ""}`}
          />
        </div>
      </div>
    </div>
  );
}

export default function UserPage(props) {
  const [isHovered, setIsHovered] = useState(false);
  const { isHoles, setIsHoles } = props;
  const { address } = useAccount();
  const addr = address ? address : "0x1234...5678";
  const user = `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  const userData = fetchUserData(addr);

  const depth = userData.rabbits.reduce(
    (totalDepth, rabbit) => totalDepth + rabbit.depth,
    0
  );

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  return (
    <>
      <ArchivePageStyled
        className="container"
        isHoles={isHoles}
        mobile={props.mobile}
      >
        <div
          className="hole-head"
          onClick={() => {
            setIsHoles(!isHoles);
          }}
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
        >
          <div className="top">
            <h1>{user}</h1>
            <div className="stats">
              {!props.mobile && <p>{userData.holes.length}</p>}
              <FontAwesomeIcon
                icon={faDigging}
                className={`${isHoles ? "active" : ""}`}
              />
              {!props.mobile && <p>{userData.rabbits.length}</p>}
              <FontAwesomeIcon
                icon={faFireFlameCurved}
                className={`${!isHoles ? "active" : ""}`}
              />
              {!props.mobile && (
                <>
                  <p>{depth}</p>
                  <div className="w">
                    <img
                      src={"/logo-full-dark.png"}
                      alt="logo"
                      className={`logo ${isHovered ? "spinner" : ""}`}
                    />
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
        {!isHoles && (
          <div className="dark-box rabbits">
            {userData.rabbits.map((rabbit, index) => (
              <div key={index} className="rw">
                <Rabbit rabbit={rabbit} userData={userData} {...props} />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        {isHoles && (
          <div className="dark-box rabbits">
            {userData.holes.map((hole, index) => (
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
