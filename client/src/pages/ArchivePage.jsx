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
  faSearch,
} from "@fortawesome/free-solid-svg-icons";
import { useParams } from "react-router-dom";
import { useEffect } from "react";

export function Rabbit({
  rabbit,
  setModals,
  setUseJump,
  isGlobalRabbit,
  hole,
}) {
  const onClickHandler = () => {
    if (isGlobalRabbit) {
      setUseJump(false);
      setModals.setRabbitModal(true);
      setModals.setRabbit(rabbit);
    } else {
      setUseJump(true);
      setModals.setHole(hole);
      setModals.setRabbit(rabbit);
      setModals.setRabbitModal(true);
    }
  };

  return (
    <div className="rabbit spinnerY" onClick={onClickHandler}>
      <p>{rabbit.msg}</p>
      <div className="r-stats">
        <p>{isGlobalRabbit ? rabbit.burner : hole.title}</p>
        <div className="ww">
          <p>{rabbit.depth}</p>
          <div className="w">
            <img src={`/logo-cropped-lime.png`} alt="logo" className={`logo`} />
          </div>
        </div>
      </div>
    </div>
  );
}

export default function ArchivePage(props) {
  const { key } = useParams();
  const [id, setId] = useState(!key || parseInt(key) == 0 ? 1 : parseInt(key));
  const [index, setIndex] = useState(1);
  const [burnModal, setBurnModal] = useState(false);

  const hole = props.holes.length > 0 ? props.holes[id - 1] : {};

  useEffect(() => {
    if (hole) {
      props.setModals.setHole(hole);
      props.setModals.setRabbit(hole.rabbits[0]);
    }
  }, [hole]);

  let start = ((index - 1) * 10 + 1).toString().padStart(3, "0");
  let end = Math.min(parseInt(start) + 9, hole == 0 ? 0 : hole.digs)
    .toString()
    .padStart(3, "0");

  const chunkSize = 10;
  const thisChunkArray = hole.rabbits.slice(
    (index - 1) * chunkSize,
    index * chunkSize
  );

  return (
    <>
      <ArchivePageStyled
        className="container"
        props={props}
        mobile={props.mobile}
      >
        <div
          onClick={() => {
            props.setModals.setHole(hole);
            props.setUseJump(false);
            props.setModals.setHoleModal(true);
          }}
          className={`hole-head spinner`}
        >
          <div className="top">
            <h1>{hole.title}</h1>
            <div className="stats">
              <p>{hole.digs}</p> <FontAwesomeIcon icon={faFireFlameCurved} />
              <p>{hole.depth}</p>
              <div className="w">
                <img src={"/logo-cropped-dark.png"} alt="logo" />
              </div>
            </div>
          </div>
        </div>

        <div className="dark-box rabbits">
          {thisChunkArray.map((rabbit, id) => (
            <div key={rabbit.msg + id} className="rw">
              <Rabbit
                rabbit={rabbit}
                setModals={props.setModals}
                setRabbit={props.setModals.setRabbit}
                setUseJump={props.setUseJump}
                isGlobalRabbit={true}
              />
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
              {start}-{end} / {hole.digs.toString().padStart(3, "0")}
            </p>
          </div>
          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() =>
              setIndex((index - 1) * 10 + 10 >= hole.digs ? index : index + 1)
            }
            className={`bottom right ${
              (index - 1) * 10 + 10 >= hole.digs ? "fill" : ``
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
              const newId = id + 1 > props.holes.length ? id : id + 1;
              setId(newId);
              setIndex(1);
              props.setModals.setHole(props.holes[newId - 1]);
            }}
            className={`bottom right ${
              id + 1 > props.holes.length ? "fill" : ``
            }`}
          />
          <FontAwesomeIcon
            icon={faArrowCircleDown}
            onClick={() => {
              const newId =
                id + 10 > props.holes.length ? props.holes.length : id + 10;
              setId(newId);
              setIndex(1);
              props.setModals.setHole(props.holes[newId - 1]);
            }}
            className={`bottom right ${
              id + 1 > props.holes.length ? "fill" : ``
            }`}
          />
        </div>
        <div className="sels3">
          <FontAwesomeIcon
            icon={faFireFlameCurved}
            onClick={() => {
              props.setModals.setBurningModal(true);
            }}
            className={`bottom`}
          />
        </div>
      </ArchivePageStyled>
    </>
  );
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

  svg {
    :hover {
      scale: 1.1;
    }
  }

  .sels {
    /* position: fixed; */
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
        color: var(--greyGreen);
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
        color: var(--greyGreen);
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
    color: var(--forrestGreen);
    font-size: 1.5rem;
    margin-top: ${(props) => (props.mobile ? "1rem" : "0rem")};

    :hover {
      color: var(--limeGreen);
      cursor: pointer;
    }

    &.stats {
      color: var(--forrestGreen);
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
    .ital {
      font-family: "Lato", sans-serif;
    }
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    width: 100%;
    min-height: ${(props) => (props.mobile ? "271px" : "462px")};
    border-radius: 1rem;
    padding: 1rem 1rem;
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
    /* height: ${(props) => (props.mobile ? "250px" : "350px")}; */
  }

  .bar {
    width: 100%;
    margin: 1rem auto;
    border-bottom: 1px dashed var(--greyGreen);
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
    margin: ${(props) => (props.mobile ? "0.5rem" : "0.5rem")};
    cursor: pointer;
    backdrop-filter: blur(10px);
    border-radius: 1rem;
    /* padding: 1rem; */
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);

    :hover {
      /* cursor: pointer; */
      /* backdrop-filter: blur(10px); */
      /* border-radius: 1rem; */
      /* padding: 1rem; */
      /* box-shadow: 0px 0px 5px 0px var(--forrestGreen); */
    }

    .top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      h1 {
        color: var(--greyGreen);
      }
    }

    .meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  }

  .uw {
    display: flex;
    width: 100%;
    flex-direction: column;
    justify-content: center;
    align-items: left;
    gap: 0;
    color: var(--forrestGreen);
    /* padding: 1rem; */
    margin: ${(props) => (props.mobile ? "0.5rem" : "0.5rem")};
    /* cursor: pointer; */
    backdrop-filter: blur(10px);
    border-radius: 1rem;
    padding: 1rem;
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);

    &.stats {
      margin-bottom: 0.5rem;
    }
  }

  .user-head {
    display: flex;
    width: 100%;
    /* flex-direction: column; */
    justify-content: space-between;
    /* height: 100%; */
    align-items: center;
    gap: 1rem;
    color: var(--forrestGreen);
    margin: 0;

    svg:hover {
      cursor: pointer;
      color: var(--greyGreen);
    }

    font-size: clamp(15px, 3vw, 30px);
  }

  .input-box {
    color: var(--greyGreen);
    background-color: rgba(0, 0, 0, 0);
    border: none;
    font-family: "Andale Mono", monospace;
    font-size: clamp(15px, 3vw, 40px);
    width: 100%;
    height: 100%;

    /* padding: 1rem; */
    /* margin: 0.5rem 0; */
    /* cursor: pointer; */
    /* backdrop-filter: blur(10px); */
    /* border-radius: 1rem; */
    /* padding: 1rem; */
    /* box-shadow: 0px 0px 5px 0px var(--forrestGreen); */

    ::placeholder {
      color: var(--greyGreen);
    }
  }

  .stats {
    display: flex;
    justify-content: left;
    align-items: center;
    font-family: "Lato";
    gap: 1rem;
    gap: clamp(2px, 1vw, 10px);
    /* height: 100%; */
    text-align: left;
    /* font-size: clamp(12px, 3vw, 18px); */
    font-size: 1.25rem;
    /* -left: auto; */

    svg {
      padding: 0 0.5rem;
    }

    :hover {
      cursor: pointer;
    }

    .w {
      height: clamp(18px, 3vw, 32px);
      display: grid;
      align-items: center;
    }

    .active {
      color: var(--greyGreen);
      p {
        color: var(--greyGreen);
      }
    }

    img {
      /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
      height: 100%;
      padding: 0;
      margin: 0;
      height: clamp(20px, 3vw, 32px);
    }

    &.sels3 {
      /* right: -3rem; */
      font-size: 1.5rem;
      /* gap: 1rem; */
      /* margin: 0 0.5rem; */
      display: flex;
      gap: 1.5rem;
      /* color: var(--greyGreen); */

      svg {
        :hover {
          color: var(--limeGreen);
          scale: 1.1;
        }

        &.active {
          color: var(--greyGreen);
          :hover {
            scale: 1;
          }
        }
        /* padding: 0.5rem 0; */
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

    .w {
      height: clamp(18px, 3vw, 32px);
    }

    .ww {
      display: flex;
      /* justify-content: space-between; */
      align-items: center;
      justify-content: center;
    }

    img {
      /* width: clamp(10px, 2vw, 30px);
        height: clamp(10px, 2vw, 30px); */
      height: 100%;
      padding: 0;
      margin: 0;
      height: clamp(18px, 3vw, 32px);
    }

    p {
      color: var(--limeGreen);
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
      scale: 1.01;

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

      height: clamp(18px, 3vw, 32px);
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

  .hidden {
    color: rgba(0, 0, 0, 0);
    cursor: default;
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

    p {
      color: var(--lightGreen);
    }

    .r-stats {
      p {
        color: var(--limeGreen);
      }
    }

    &:hover {
      cursor: pointer;
      /* color: var(--forrestGreen); */
      /* background-color: var(--greyGreen); */
      border: 0.5px solid var(--lightGreen);
      scale: 1.01;

      p {
        /* color: var(--forrestGreen); */
      }
    }
  }
`;
