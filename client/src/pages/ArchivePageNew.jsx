import React, { useMemo } from "react";

import { useState } from "react";
import styled from "styled-components";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowCircleDown,
  faArrowCircleLeft,
  faArrowCircleRight,
  faArrowCircleUp,
  faChevronCircleDown,
  faChevronCircleUp,
  faFireFlameCurved,
} from "@fortawesome/free-solid-svg-icons";
import RabbitModal from "../components/global/RabbitModal";
import HoleModal from "../components/global/HoleModal";
import fetchHolesData from "../components/hooks/fetchHoleData";
import { useNavigate, useParams } from "react-router-dom";
import BurnModal from "../components/global/BurnModal";

export default function ArchivePageNew(props) {
  const { key } = useParams();
  const [burnModal, setBurnModal] = useState(false);
  const [rabbitModal, setRabbitModal] = useState(false);
  const [holeModal, setHoleModal] = useState(false);
  const [id, setId] = useState(!key || parseInt(key) == 0 ? 1 : parseInt(key));
  const [index, setIndex] = useState(1);

  const holeData = useMemo(() => {
    const array = Array.from({ length: 111 }, (_, i) => i + 1);
    return fetchHolesData(array);
  }, [id]);

  const hole = holeData[id - 1];
  const [rabbit, setRabbit] = useState(hole.rabbits[0]);

  let start = (index - 1) * 10 + 1;
  let end = start + 9;
  if (start < 10) start = "0" + start;
  if (end > hole.digs) end = hole.digs;
  if (end < 10) end = "0" + end;

  const chunkSize = 10;
  const twoDArray = [];
  for (let i = 0; i < hole.rabbits.length; i += chunkSize) {
    const chunk = hole.rabbits.slice(i, i + chunkSize);
    twoDArray.push(chunk);
  }
  const thisChunkArray = twoDArray.length == 0 ? [] : twoDArray[index - 1];

  return (
    <>
      <ArchivePageStyled
        className="container"
        props={props}
        mobile={props.mobile}
      >
        <div
          className="hole-head"
          onClick={() => {
            setHoleModal(true);
          }}
        >
          <div className="top">
            <h1>{hole.title}</h1>
            <div className="stats">
              <p>{hole.digs}</p> <FontAwesomeIcon icon={faFireFlameCurved} />
              <p>{hole.depth}</p>
              <div className="w">
                <img src={"/logo-full-dark.png"} alt="logo" className="logo" />
              </div>
            </div>
          </div>
        </div>
        <div className="dark-box rabbits">
          {thisChunkArray.map((rabbit, id) => (
            <div key={rabbit.msg} className="rw">
              <div
                className="rabbit"
                onClick={() => {
                  setRabbit(rabbit);
                  setRabbitModal(true);
                }}
              >
                <p>{rabbit.msg}</p>
                <div className="r-stats">
                  <p>- {rabbit.burner}</p>
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
              {start}-{end} / {hole.digs < 10 ? "0" + hole.digs : hole.digs}
            </p>
          </div>
          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() =>
              setIndex((index - 1) * 10 + 9 >= hole.digs ? index : index + 1)
            }
            className={`bottom right ${
              (index - 1) * 10 + 9 >= hole.digs ? "fill" : ``
            }`}
          />
        </div>
        <div className="sels2">
          <FontAwesomeIcon
            icon={faArrowCircleUp}
            onClick={() => {
              setIndex(1);
              // setRabbit(thisChunkArray[0]);
              setId(id <= 10 ? 1 : id - 10);
              // setHole(holes[id <= 10 ? 1 : id - 10]);
            }}
            className={`bottom left ${id == 1 ? "fill" : ``}`}
          />
          <FontAwesomeIcon
            icon={faChevronCircleUp}
            onClick={() => {
              setIndex(1);
              // setRabbit(thisChunkArray[0]);
              setId(id == 1 ? id : id - 1);
              // setHole(holes[id == 1 ? id : id - 1]);
            }}
            className={`bottom left ${id == 1 ? "fill" : ``}`}
          />
          <div id="bottom" className="bottom">
            <p>{id < 100 ? (id < 10 ? "00" + id : "0" + id) : id}</p>
          </div>
          <FontAwesomeIcon
            icon={faChevronCircleDown}
            onClick={() => {
              // console.log("currnet id", id);
              setId(id + 1 > holeData.length ? id : id + 1);
              // setRabbit(thisChunkArray[0]);
              setIndex(1);
            }}
            className={`bottom right ${id + 1 > holeData.length ? "fill" : ``}`}
          />
          <FontAwesomeIcon
            icon={faArrowCircleDown}
            onClick={() => {
              setId(id + 10 > holeData.length ? holeData.length : id + 10);
              // setRabbit(thisChunkArray[0]);
              setIndex(1);
            }}
            className={`bottom right ${id + 1 > holeData.length ? "fill" : ``}`}
          />
        </div>
        <div className="sels3">
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            onClick={() => {
              setBurnModal(true);
            }}
            className={`bottom`}
          />
        </div>
        {rabbitModal && (
          <RabbitModal
            onClose={setRabbitModal}
            modal={rabbitModal}
            rabbit={rabbit}
            rabbits={1234}
            hole={holeData[id - 1]}
            holes={holeData.length}
          />
        )}
        {holeModal && (
          <HoleModal
            onClose={setHoleModal}
            modal={holeModal}
            hole={holeData[id - 1]}
            holes={holeData.length}
          />
        )}
        {burnModal && (
          <BurnModal
            onClose={setBurnModal}
            modal={burnModal}
            hole={holeData[id - 1]}
          />
        )}
      </ArchivePageStyled>
    </>
  );

  function openRabbit(rabbit) {
    // setRabbit(rabbit);
    setRabbitModal(true);
  }
}

export const ArchivePageStyled = styled.div`
  display: flex;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  flex-direction: column;
  align-items: left;
  justify-content: center;
  width: clamp(75px, 60vw, 600px);
  margin: 0;
  gap: ${(props) => (props.mobile ? "0" : "1rem")};
  /* overflow: scroll; */
  /* gap: ${(props) => (props.mobile ? "0rem" : "1rem")}; */
  /* margin-right: auto; */
  .toggler {
    :hover {
      cursor: pointer;
    }
  }

  .sels {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    color: var(--forrestGreen);
    margin-top: 1rem;

    .left,
    .right {
      :hover {
        color: var(--limeGreen);
        cursor: pointer;
      }
    }

    .fill {
      color: rgba(0, 0, 0, 0);
      :hover {
        color: rgba(0, 0, 0, 0);
        cursor: default;
      }
    }
  }

  .sels2 {
    position: absolute;
    right: -3.5rem;
    top: 50%;
    transform: translateY(-50%);

    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    color: var(--forrestGreen);
    /* writing-mode: vertical-lr; */
    text-align: right;

    .left,
    .right {
      :hover {
        color: var(--limeGreen);
        cursor: pointer;
      }
    }

    .fill {
      color: rgba(0, 0, 0, 0);
      :hover {
        color: rgba(0, 0, 0, 0);
        cursor: default;
      }
    }
  }

  .sels3 {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    color: var(--lightGreen);
    font-size: 1.5rem;
    margin-top: ${(props) => (props.mobile ? "1rem" : "0rem")};

    :hover {
      color: var(--limeGreen);
      cursor: pointer;
    }
  }

  /* .left {
    :hover {
      color: var(--limeGreen);
    }
  } */

  .dark-box {
    background-color: var(--forrestGreen);
    color: var(--lightGreen);
    font-size: clamp(12px, 3vw, 18px);

    font-family: "Andale Mono", monospace;
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    width: 100%;
    min-height: ${(props) => (props.mobile ? "200px" : "400px")};
    border-radius: 1rem;
    padding: 2rem 1rem;
    /* gap: 0; */
    /* overflow: scroll; */
  }

  .rabbits {
    color: var(--limeGreen);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: top;
    gap: 1rem;
    overflow: scroll;
    /* overflow: auto; */
  }

  .bar {
    width: 100%;
    margin: 1rem auto;
    border-bottom: 1px dashed var(--lightGreen);
  }

  h1,
  p {
    padding: 0;
    margin: 0;

    text-align: left;
  }

  .hole-head {
    display: flex;
    width: 100%;
    flex-direction: column;
    justify-content: center;
    align-items: left;
    gap: 0;
    /* text-align */
    /* padding: 1rem; */
    color: var(--forrestGreen);
    h1 {
      color: var(--lightGreen);
      font-size: clamp(15px, 3vw, 40px);
    }

    h2 {
      font-size: clamp(8px, 3vw, 15px);
    }

    p {
      font-size: clamp(8px, 3vw, 15px);
    }

    svg {
      font-size: clamp(8px, 3vw, 18px);
      padding: 0 0.5rem;
    }
    padding: 1rem;
    margin: ${(props) => (props.mobile ? "0" : "1rem")};

    :hover {
      cursor: pointer;
      backdrop-filter: blur(10px);
      border-radius: 1rem;
      /* padding: 1rem; */
      box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    }

    .top {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .stats {
      display: flex;
      justify-content: center;
      align-items: center;
      font-family: "Lato";
      gap: 1rem;
      gap: clamp(2px, 1vw, 10px);

      .w {
        height: clamp(18px, 3vw, 32px);
      }

      .active {
        color: var(--greyGreen);
      }

      img {
        /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
        height: 100%;
        padding: 0;
        margin: 0;
      }
    }
  }

  .r-stats {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-family: "Lato";
    gap: 1rem;
    gap: clamp(2px, 1vw, 10px);
    width: 100%;
    color: var(--lightGreen);

    .ww {
      display: flex;
      /* justify-content: space-between; */
      align-items: center;
    }

    .w {
      height: clamp(27px, 3vw, 32px);
    }

    img {
      /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
      height: 100%;
      padding: 0;
      margin: 0;
    }

    p {
      color: var(--lightGreen);
    }

    /* p:hover,
    &:hover {
      color: var(--forrestGreen);
    } */
  }

  .hole {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    font-family: "Andale Mono", monospace;
    gap: 1rem;
    gap: clamp(2px, 1vw, 10px);
    /* width: 100%; */
    color: var(--lightGreen);
    padding: 1rem;

    /* flex-direction: column; */
    /* align-items: left; */
    /* justify-content: center; */
    gap: 1rem;
    padding: 1rem;
    border-radius: 1rem;

    border: 0.5px solid var(--forrestGreen);

    &:hover {
      cursor: pointer;
      /* color: var(--forrestGreen); */
      /* background-color: var(--greyGreen); */
      border: 0.5px solid var(--lightGreen);

      p {
        /* color: var(--forrestGreen); */
      }
    }

    .h-stats {
      display: flex;
      /* flex-direction: row; */
      justify-content: left;
      align-items: center;
      font-family: "Lato";
      gap: 1rem;
      gap: clamp(2px, 1vw, 10px);
      /* width: 100%; */
      color: var(--limeGreen);
      margin-left: auto;

      .ww {
        display: flex;
        /* justify-content: space-between; */
        align-items: center;
      }

      .w {
        height: clamp(27px, 3vw, 32px);
      }

      img {
        /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
        height: 100%;
        padding: 0;
        margin: 0;
      }

      p {
        color: var(--limeGreen);
      }
    }

    .ww {
      display: flex;
      /* justify-content: space-between; */
      align-items: center;
    }

    .w {
      height: clamp(27px, 3vw, 32px);
    }

    img {
      /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
      height: 100%;
      padding: 0;
      margin: 0;
    }

    p {
      color: var(--lightGreen);
    }

    /* p:hover,
    &:hover {
      color: var(--forrestGreen);
    } */
  }
  .bottom svg:hover {
    color: var(--limeGreen);
  }

  .rw {
    width: 100%;
    text-align: left;
  }

  .rabbit {
    display: flex;
    flex-direction: column;
    align-items: left;
    justify-content: center;
    gap: 1rem;
    padding: 1rem;
    border-radius: 1rem;

    border: 0.5px solid var(--forrestGreen);

    &:hover {
      cursor: pointer;
      /* color: var(--forrestGreen); */
      /* background-color: var(--greyGreen); */
      border: 0.5px solid var(--lightGreen);

      p {
        /* color: var(--forrestGreen); */
      }
    }
  }
`;
