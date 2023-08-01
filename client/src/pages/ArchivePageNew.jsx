import React from "react";

import { useState } from "react";
import styled from "styled-components";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowCircleLeft,
  faArrowCircleRight,
  faDigging,
  faFireFlameCurved,
  faUser,
} from "@fortawesome/free-solid-svg-icons";
import RabbitModal from "../components/global/RabbitModal";
import HoleModal from "../components/global/HoleModal";

export default function ArchivePageNew() {
  const [isHovered, setIsHovered] = useState(false);
  const [rabbitModal, setRabbitModal] = useState(false);
  const [holeModal, setHoleModal] = useState(false);
  const [index, setIndex] = useState(1);

  const title = "SHOWER THOUGHTS";
  const digger = "0x1234...5678";
  const depth = 123;
  const rabbits = 555;
  const digs = 62;
  const holes = 420;
  const timestamp = "1/1/23";
  const msg =
    "This is an example of a rabbit burned inside of a hole using example content that takes up a bunch of space. I could have just used the Lorem plugin thing but this will do for now lol.";

  const r_array = Array.from({ length: digs }, (_, index) => ({
    burner: digger,
    r_index: index,
    h_index: 1,
    timestamp: "4/20/23",
    depth: 3,
    digger,
    title,
    rabbits,
    msg,
  }));

  const hole = {
    h_index: index,
    timestamp: "4/20/23",
    // random # 1-30
    depth,

    digs,
    digger,
    title,
    holes,
  };
  const chunkSize = 10;
  const twoDArray = [];

  for (let i = 0; i < r_array.length; i += chunkSize) {
    const chunk = r_array.slice(i, i + chunkSize);
    twoDArray.push(chunk);
  }

  console.log(twoDArray);

  const thisChunkArray = twoDArray[index - 1];

  const [rabbit, setRabbit] = useState({
    burner: "0x1234...5678",
    r_index: 33,
    h_index: 1,
    timestamp: "4/20/23",
    depth: 3,
    title,
    rabbits,
  });

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  let start = (index - 1) * 10 + 1;
  let end = start + 9;
  end = end >= rabbits ? digs : end;
  start = start < 10 ? "0" + start : start;

  return (
    <>
      <ArchivePageStyled className="container">
        <div
          className="hole-head"
          onClick={() => {
            setHoleModal(true);
          }}
        >
          <div className="top">
            <h1>{title}</h1>
            <div className="stats">
              <p>{digs}</p> <FontAwesomeIcon icon={faFireFlameCurved} />
              <p>{depth}</p>
              <div className="w">
                <img src={"/logo-full-dark.png"} alt="logo" className="logo" />
              </div>
            </div>
          </div>
        </div>
        <div className="dark-box rabbits">
          {thisChunkArray.map(({ r_index, digger, depth }) => (
            <div key={r_index}>
              <div
                className="rabbit"
                onMouseEnter={handleMouseEnter}
                onMouseLeave={handleMouseLeave}
                onClick={() => {
                  setRabbit(r_array[r_index]);
                  setRabbitModal(true);
                }}
              >
                <p>
                  {" > "}
                  {msg}
                </p>
                <div className="r-stats">
                  <p>- {digger}</p>
                  <div className="ww">
                    <p>{depth}</p>
                    <div className="w">
                      <img
                        src={`/logo-full-${isHovered ? "blue" : "blue"}.png`}
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
              console.log(index);
            }}
            className={`bottom left ${index == 1 ? "fill" : ``}`}
          />
          <div id="bottom" className="bottom">
            <p>
              {start}-{end} / {digs}
              {/* -{(index - 1) * 10 + 9} / {rabbits} */}
            </p>
          </div>
          <FontAwesomeIcon
            icon={faArrowCircleRight}
            onClick={() =>
              setIndex((index - 1) * 10 + 9 >= digs ? index : index + 1)
            }
            className={`bottom right ${
              (index - 1) * 10 + 9 >= digs ? "fill" : ``
            }`}
          />
        </div>
        {rabbitModal && (
          <RabbitModal
            onClose={setRabbitModal}
            modal={rabbitModal}
            rabbit={rabbit}
          />
        )}
        {holeModal && (
          <HoleModal onClose={setHoleModal} modal={holeModal} hole={hole} />
        )}
      </ArchivePageStyled>
    </>
  );
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

  /* .left {
    :hover {
      color: var(--limeGreen);
    }
  } */

  .dark-box {
    background-color: var(--forrestGreen);
    color: var(--lightGreen);
    font-family: "Andale Mono", monospace;
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    width: 100%;
    min-height: 200px;
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
    justify-content: left;
    align-items: left;
    gap: 0;
    /* text-align */
    /* padding: 1rem; */
    color: var(--forrestGreen);
    h1 {
      color: var(--lightGreen);
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

  .rabbit {
    display: flex;
    flex-direction: column;
    align-items: center;
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
