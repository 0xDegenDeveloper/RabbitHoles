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

const h_array = [];
const holes = 420;
// const rabbits = 1234;
const digger = "0x1234...5678";
const burner = "0xabcd...beef";
const title = "SHOWER THOUGHTS";
const timestamp = "4/20/21";
for (let i = 0; i < holes; i++) {
  const digs = Math.floor(Math.random() * 100) + (i + 1);
  const depth = 3 * digs;
  h_array.push({
    digger,
    timestamp,
    digs,
    depth,
    holes,
    h_index: i + 1,
    title,
  });
}

const msg =
  "This is an example of a rabbit burned inside of a hole using example content that takes up a bunch of space. I could have just used the Lorem plugin thing but this will do for now lol.";

const r_array = [];
let rabbits = 0;
for (let i = 0; i < holes; i++) {
  let holeDepth = Math.floor(Math.random() * 33);
  h_array[i].digs = holeDepth;
  h_array[i].depth = holeDepth * 3;
  for (let j = 0; j < holeDepth; j++) {
    rabbits += 1;
    r_array.push({
      burner,
      r_index: rabbits,
      h_index: i + 1,
      timestamp: "4/20/23",
      depth: 3,
      digger,
      title,
      rabbits,
      msg,
    });
  }
}

for (let i = 0; i < r_array.length; i++) {
  r_array[i].rabbits = rabbits;
}

function rabbitsInHole(holeId) {
  let rabbits = [];
  for (let i = 0; i < r_array.length; i++) {
    if (r_array[i].h_index === holeId) {
      rabbits.push(r_array[i]);
    }
  }
  return rabbits;
}

export default function ArchivePageNew(props) {
  // const navigate = useNavigate();
  const [burnModal, setBurnModal] = useState(false);
  const [rabbitModal, setRabbitModal] = useState(false);
  const [holeModal, setHoleModal] = useState(false);
  const [id, setId] = useState(
    !props.holeId || parseInt(props.holeId) == 0 ? 1 : props.holeId
  );
  const [index, setIndex] = useState(
    !props.rabbitIndex || parseInt(props.rabbitIndex) == 0
      ? 1
      : props.rabbitIndex
  );

  const holeData = useMemo(() => {
    const array = Array.from({ length: 111 }, (_, i) => i + 1);
    return fetchHolesData(array);
  }, [id]);

  const { title, digs, depth, digger, timestamp, rabbits } =
    holeData[index - 1]; //h_array[id - 1];

  // const [rabbit, setRabbit] = useState(rabbits[0]);
  const hole = holeData[id - 1];

  const [rabbit, setRabbit] = useState(hole.rabbits[0]);

  let start = (index - 1) * 10 + 1;
  let end = start + 9;
  end = end >= hole.digs ? hole.digs : end;
  start = start < 10 ? "0" + start : start;

  // const hole =

  const chunkSize = 10;
  const twoDArray = [];
  for (let i = 0; i < hole.rabbits.length; i += chunkSize) {
    const chunk = hole.rabbits.slice(i, i + chunkSize);
    twoDArray.push(chunk);
  }
  const thisChunkArray = twoDArray.length == 0 ? [] : twoDArray[index - 1];

  console.log(index, id);

  console.log("this chunk", thisChunkArray, twoDArray);

  return (
    <>
      <ArchivePageStyled className="container" props={props}>
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
                  console.log(id, "id");
                  console.log("rabbit clicked:", rabbit);
                  // setIndex(id + 1);
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
              {start}-{end} / {hole.digs}
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
              setId(id + 1 > holes ? id : id + 1);
              // setRabbit(thisChunkArray[0]);
              setIndex(1);
            }}
            className={`bottom right ${id + 1 > holes ? "fill" : ``}`}
          />
          <FontAwesomeIcon
            icon={faArrowCircleDown}
            onClick={() => {
              setId(id + 10 > holes ? id : id + 10);
              // setRabbit(thisChunkArray[0]);
              setIndex(1);
            }}
            className={`bottom right ${id + 1 > holes ? "fill" : ``}`}
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

const ArchivePageStyled = styled.div`
  display: flex;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  flex-direction: column;
  align-items: left;
  justify-content: center;
  width: clamp(75px, 55vw, 600px);
  margin: 0;
  gap: 1rem;
  /// depends on props:
  /* gap: ${(props) => (props.mobile ? "0rem" : "1rem")}; */

  /* margin-right: auto; */

  .sels {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    color: var(--forrestGreen);

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
    right: -3rem;
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
    min-height: 400px;
    border-radius: 1rem;
    padding: 2rem 1rem;
  }

  .rabbits {
    color: var(--limeGreen);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: top;
    gap: 1rem;
    overflow: scroll;
    max-height: 400px;
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

    padding: ${(props) => (props.props.mobile ? "0" : "1rem")};

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

      /* align-items: bottom; */

      /* margin-bottom: 0; */

      /* :hover {
        margin-bottom: 1rem;
      } */
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
        height: clamp(27px, 3vw, 32px);
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
