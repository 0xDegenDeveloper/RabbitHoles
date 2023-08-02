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

  const [isHoles, setIsHoles] = useState(true);
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
              <p>{userData.holes.length}</p>{" "}
              <FontAwesomeIcon
                icon={faDigging}
                className={`${isHoles ? "active" : ""}`}
              />
              <p>{userData.rabbits.length}</p>{" "}
              <FontAwesomeIcon
                icon={faFireFlameCurved}
                className={`${!isHoles ? "active" : ""}`}
              />
              <p>{depth}</p>
              <div className="w">
                <img src={"/logo-full-dark.png"} alt="logo" className="logo" />
              </div>
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
                    // console.log(id, "id");
                    // console.log("rabbit clicked:", rabbit);
                    // setIndex(id + 1);
                    // setRabbit(rabbit);
                    // setRabbitModal(true);
                    navigate(`/archive/${rabbit.holeId}`);
                  }}
                >
                  <p>{rabbit.msg}</p>
                  <div className="r-stats">
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
                          src={`/logo-full-blue.png`}
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
                    // console.log(id, "id");
                    // console.log("rabbit clicked:", rabbit);
                    // setIndex(id + 1);
                    // setHole(hole);
                    // setHoleModal(true);
                    navigate(`/archive/${hole.id}`);
                  }}
                >
                  <p>{hole.title}</p>
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
        {/* <input
              className="dark-search-bar-input"
              id="search-input"
              placeholder={user ? user : "Discorver users..."}
              onChange={(event) => setInput(event.target.value)}
              onKeyDown={(event) => {
                if (event.key == "Enter") {
                  passInput();
                }
              }}
            ></input> */}
        {/* <div id="h" className={`dark-search-bar-button ${"two"}`}>
              <FontAwesomeIcon
                icon={faMagnifyingGlass}
                onClick={() => {
                  passInput();
                }}
              />
            </div> */}
        {/* <FontAwesomeIcon
              icon={faDigging}
              className="dark-search-bar-button one"
            /> */}
        {/* {isHoles && !key && (
            <div className="user-holes-section">
              <div className="clear-box-dark-border user-holes" id="clear-box">
                {userData.holes.map((hole, index) => (
                  <React.Fragment key={"hole" + index}>
                    <div
                      className="hole-link"
                      onClick={() => {
                        navigate(`/archive/${hole.id}`);
                      }}
                    >
                      <h4>
                        &gt; Hole #{hole.id} <em>"{hole.title}"</em>
                      </h4>
                      <h4>
                        &gt; Depth: <em>{hole.depth}</em>
                      </h4>
                    </div>
                    <Bar />
                  </React.Fragment>
                ))}
              </div>
            </div>
          )} */}

        {/* {!isHoles && !key && (
            <div className="user-holes-section">
              <div className="clear-box-dark-border user-holes" id="clear-box">
                {userData.holes.map((rabbit, index) => (
                  <React.Fragment key={"rabbit" + index}>
                    <div
                      className="hole-link"
                      onClick={() => {
                        navigate(`/archive/${rabbit.hole_id}/${rabbit.id}`);
                      }}
                    >
                      <h4>
                        &gt; Rabbit <em>#{rabbit.global_id}</em>
                      </h4>
                      <h4>
                        &gt; Hole :<em>"{rabbit.title}"</em>
                      </h4>
                      <h4>
                        &gt; Msg: <em>{rabbit.msg}</em>
                      </h4>
                    </div>
                    <Bar />
                  </React.Fragment>
                ))}
              </div>
            </div>
          )} */}
        {/* NO USER */}
        {/* {key && (
            <div className="user-holes-section">
              <div className="clear-box-dark-border user-holes">
                <div
                  className="hole-link"
                  onClick={() => {
                    navigate(`/archive/1`);
                  }}
                >
                  &gt;
                </div>
                <Bar />
                <div
                  className="hole-link"
                  onClick={() => {
                    navigate(`/archive/1`);
                  }}
                >
                  &gt;
                </div>
              </div>
            </div>
          )} */}
        {/* <div className="wrapper3">
          <h1
            onClick={() => {
              // setIsHoles(true);
            }}
            // className={`a sel ${isHoles ? "active" : ""}`}
          >
            Holes
          </h1>
          <VBar />
          <h1
            onClick={() => {
              setIsHoles(false);
            }}
            className={`b sel ${isHoles ? "" : "active"}`}
          >
            Rabbits
          </h1>
        </div> */}
        {/* <div className="wrapper2">
            <div
              className="dark-button-small stat"
              onClick={() => {
                setIsHoles(true);
              }}
            >
              <h4>
                Digs: <em>{key ? 0 : userData.holes.length}</em>
              </h4>
            </div>

            <div
              className="dark-button-small stat"
              onClick={() => {
                setIsHoles(false);
              }}
            >
              <h4>
                Burns: <em>{key ? 0 : userData.rabbits.length}</em>
              </h4>
            </div>
            <div
              className="dark-button-small stat tt"
              onClick={() => {
                navigate(`/info/`);
              }}
            >
              <h4>
                Balance:{" "}
                <em>
                  {key
                    ? 0
                    : parseInt(userData.holes.length) * 25 -
                      parseInt(userData.rabbits.length)}
                  RBIT
                </em>
              </h4>
            </div>
          </div> */}

        {/* {holeModal && (
          <HoleModal
            onClose={setHoleModal}
            modal={holeModal}
            hole={hole}
            holes={111}
          />
        )}
        {rabbitModal && (
          <RabbitModal
            onClose={setRabbitModal}
            modal={rabbitModal}
            hole={hole}
            rabbit={rabbit}
          />
        )} */}
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
