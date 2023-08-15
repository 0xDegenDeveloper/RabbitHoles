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
  faSearch,
  faUser,
  faUserCircle,
} from "@fortawesome/free-solid-svg-icons";
import { ArchivePageStyled, Rabbit } from "./ArchivePage";

function Hole({ hole, setUseJump, setModals }) {
  return (
    <div
      className="hole spinnerY"
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

  const { isHoles, setIsHoles, opt, setOpt } = props;
  const { address } = useAccount();
  const addr = address ? address : "0x1234...5678";
  const user = `${addr.slice(0, 6)}...${addr.slice(-4)}`;

  const userArchive = props.userArchive; // fetchUserStatistics(addr) if user is not the one connected (searching)

  const chunkSize = 10;
  const thisArchive =
    opt == "rabbits" ? userArchive.rabbits : userArchive.holes;
  const thisChunkArray = thisArchive.slice(
    (index - 1) * chunkSize,
    index * chunkSize
  );

  let start = ((index - 1) * 10 + 1).toString().padStart(3, "0");
  let end = Math.min(
    parseInt(start) + 9,
    opt == "rabbit" ? userArchive.totalRabbits : userArchive.totalHoles
  )
    .toString()
    .padStart(3, "0");

  /// when connected to contract
  /// add check for userSearch == address,
  /// if false, use userArchive, else replace userArchive with fetchUserArchive(userSearch)

  const opts = ["depth", "holes", "rabbits"];

  return (
    <>
      <ArchivePageStyled
        className="container"
        isHoles={isHoles}
        opt={opt}
        mobile={props.mobile}
      >
        <div className="uw">
          <div className="user-head">
            <input placeholder={user} className="input-box"></input>
            <FontAwesomeIcon icon={faSearch} />
          </div>
        </div>

        {/* <div className="stats">
          <FontAwesomeIcon
            icon={faUser}
            className={`${props.opt == "depth" ? "active" : ""}`}
            onClick={() => {
              setOpt("depth");
            }}
          />
          <FontAwesomeIcon
            icon={faDigging}
            className={`${props.opt == "holes" ? "active" : ""}`}
            onClick={() => {
              setOpt("holes");
            }}
          />
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            className={`${props.opt == "rabbits" ? "active" : ""}`}
            onClick={() => {
              setOpt("rabbits");
            }}
          />
        </div> */}
        {opt == "rabbits" && (
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
        {opt == "holes" && (
          <div className="dark-box rabbits">
            {thisChunkArray.map((hole, index) => (
              <div key={index} className="rw">
                <Hole hole={hole} {...props} />
                <div className="bar"></div>
              </div>
            ))}
          </div>
        )}
        {opt == "depth" && <div className="dark-box depth"></div>}
        <div className="sels">
          {/* {opt != "depth" && ( */}
          {/* <> */}
          <FontAwesomeIcon
            icon={faArrowCircleLeft}
            onClick={() => {
              setIndex(index == 1 ? index : index - 1);
            }}
            className={`bottom left ${index == 1 ? "fill" : ``}`}
            style={opt == "depth" ? { color: "rgba(0,0,0,0)" } : {}}
          />
          <div id="bottom" className="bottom">
            <p style={opt == "depth" ? { color: "rgba(0,0,0,0)" } : {}}>
              {start}-{end} /{" "}
              {opt == "holes"
                ? userArchive.totalHoles.toString().padStart(3, "0")
                : userArchive.totalRabbits.toString().padStart(3, "0")}
            </p>
          </div>
          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() => {
              setIndex(
                (index - 1) * 10 + 10 >=
                  (opt == "holes"
                    ? userArchive.totalHoles
                    : userArchive.totalRabbits)
                  ? index
                  : index + 1
              );
            }}
            className={`bottom right ${
              (index - 1) * 10 + 10 >=
              (opt == "holes"
                ? userArchive.totalHoles
                : userArchive.totalRabbits)
                ? "fill"
                : ``
            }`}
            style={opt == "depth" ? { color: "rgba(0,0,0,0)" } : {}}
          />
        </div>
        <div className="stats sels3">
          <FontAwesomeIcon
            icon={faUser}
            className={`${props.opt == "depth" ? "active" : ""} bottom left`}
            onClick={() => {
              setOpt("depth");
              setIndex(1);
            }}
          />
          <FontAwesomeIcon
            icon={faDigging}
            className={`${props.opt == "holes" ? "active" : ""}`}
            onClick={() => {
              setOpt("holes");
              setIndex(1);
            }}
          />
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            className={`${props.opt == "rabbits" ? "active" : ""}`}
            onClick={() => {
              setOpt("rabbits");
              setIndex(1);
            }}
          />
        </div>
        {/* <div className="sels3">
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            className={`bottom hidden`}
          />
        </div> */}
      </ArchivePageStyled>
    </>
  );
}
