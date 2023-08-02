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
import HoleModal from "../components/global/HoleModal";
import BurnModal from "../components/global/BurnModal";
import RabbitModal from "../components/global/RabbitModal";

export default function UserPage(props) {
  const navigate = useNavigate();
  const { key } = useParams();

  const [isHovered, setIsHovered] = useState(false);
  const [rabbitModal, setRabbitModal] = useState(false);
  const [holeModal, setHoleModal] = useState(false);

  // const [isHoles, setIsHoles] = useState(true);
  const { isHoles, setIsHoles } = props;
  const { address } = useAccount();

  const addr = address ? address : "0x1234...5678";
  const user = `${addr.slice(0, 6)}...${addr.slice(-4)}`;

  const userData = fetchUserData(addr);

  const [hole, setHole] = useState(userData.holes[0]);
  const [rabbit, setRabbit] = useState(userData.rabbits[0]);

  const depth = userData.rabbits.reduce(
    (totalDepth, rabbit) => totalDepth + rabbit.depth,
    0
  );

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
                      className="logo"
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
                <div
                  className="rabbit"
                  onClick={() => {
                    props.setUseJump(true);
                    props.setHole(userData.holes[rabbit.holeId - 1]);
                    props.setRabbit(rabbit);
                    props.setRabbitModal(true);
                  }}
                >
                  <p>{rabbit.msg}</p>
                  <div className="r-stats">
                    <p>{userData.holes[rabbit.holeId - 1].title}</p>
                    <div className="ww">
                      <div className="w">
                        <img
                          src={`/logo-full-dark.png`}
                          alt="logo"
                          className="logo"
                        />
                      </div>
                    </div>
                    <div className="ww">
                      <p>{rabbit.depth}</p>
                      <div className="w">
                        <img
                          src={`/logo-full-lime.png`}
                          // src={`/logo-full-${isHovered ? "dark" : "blue"}.png`}
                          alt="logo"
                          className="logo"
                        />
                      </div>
                    </div>
                  </div>
                </div>
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        {isHoles && (
          <div className="dark-box rabbits">
            {userData.holes.map((hole, index) => (
              <div key={index} className="rw">
                <div
                  className="hole"
                  onClick={() => {
                    props.setUseJump(true);
                    props.setHole(hole);
                    props.setHoleModal(true);
                  }}
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
                        className="logo"
                      />
                    </div>
                  </div>
                </div>
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
      </ArchivePageStyled>
      {/* </div> */}
    </>
  );
}

const VBar = styled.div`
  width: 0;
  height: 50%;
  margin: auto auto;
  border-left: 2px solid var(--forrestGreen);
`;
