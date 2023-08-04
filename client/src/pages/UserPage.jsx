import React, { useState } from "react";
import styled from "styled-components";
import fetchUserStatistics from "../components/hooks/fetchUserStatistics";
import { useAccount } from "@starknet-react/core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowCircleLeft,
  faArrowCircleRight,
  faDigging,
  faFireFlameCurved,
} from "@fortawesome/free-solid-svg-icons";
import { ArchivePageStyled, Rabbit } from "./ArchivePage";

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
  const [index, setIndex] = useState(1);
  const { isHoles, setIsHoles } = props;
  const { address } = useAccount();
  const addr = address ? address : "0x1234...5678";
  const user = `${addr.slice(0, 6)}...${addr.slice(-4)}`;

  const userArchive = props.userArchive; // fetchUserStatistics(addr) if user is not the one connected (searching)

  const chunkSize = 10;
  const thisArchive = isHoles ? userArchive.holes : userArchive.rabbits;
  const thisChunkArray = thisArchive.slice(
    (index - 1) * chunkSize,
    index * chunkSize
  );

  let start = ((index - 1) * 10 + 1).toString().padStart(3, "0");
  let end = Math.min(
    parseInt(start) + 9,
    isHoles ? userArchive.totalHoles : userArchive.totalRabbits
  )
    .toString()
    .padStart(3, "0");

  /// when connected to contract
  /// add check for userSearch == address,
  /// if false, use userArchive, else replace userArchive with fetchUserArchive(userSearch)

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
            setIndex(1);
            setIsHoles(!isHoles);
          }}
        >
          <div className="top">
            <h1>{user}</h1>
            <div className="stats">
              {!props.mobile && <p>{props.userArchive.totalHoles}</p>}
              <FontAwesomeIcon
                icon={faDigging}
                className={`${isHoles ? "active" : ""}`}
              />
              {!props.mobile && <p>{props.userArchive.totalRabbits}</p>}
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
            {thisChunkArray.map((rabbit, index) => (
              <div key={index} className="rw">
                <Rabbit
                  rabbit={rabbit}
                  hole={props.userArchive.holes[rabbit.holeId - 1]}
                  isGlobalRabbit={false}
                  {...props}
                />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        {isHoles && (
          <div className="dark-box rabbits">
            {thisChunkArray.map((hole, index) => (
              <div key={index} className="rw">
                <Hole hole={hole} {...props} />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        <div className="sels">
          <FontAwesomeIcon
            icon={faArrowCircleLeft}
            onClick={() => {
              setIndex(index == 1 ? index : index - 1);
            }}
            className={`bottom left ${index == 1 ? "fill" : ``}`}
          />
          <div id="bottom" className="bottom">
            <p>
              {start}-{end} /{" "}
              {isHoles
                ? userArchive.totalHoles.toString().padStart(3, "0")
                : userArchive.totalRabbits.toString().padStart(3, "0")}
            </p>
          </div>
          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() => {
              setIndex(
                (index - 1) * 10 + 10 >=
                  (isHoles ? userArchive.totalHoles : userArchive.totalRabbits)
                  ? index
                  : index + 1
              );
            }}
            className={`bottom right ${
              (index - 1) * 10 + 10 >=
              (isHoles ? userArchive.totalHoles : userArchive.totalRabbits)
                ? "fill"
                : ``
            }`}
          />
        </div>
        <div className="sels3">
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            className={`bottom hidden`}
          />
        </div>
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
