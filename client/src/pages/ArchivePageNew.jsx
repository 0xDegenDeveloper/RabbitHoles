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

export default function ArchivePageNew() {
  const title = "SHOWER THOUGHTS";
  const digger = "0x1234...5678";
  const depth = 123;
  const rabbits = 55;
  const timestamp = "1/1/23";

  return (
    <>
      <ArchivePageStyled className="container">
        <div className="hole-head">
          <div className="top">
            <h2>1/999999</h2>
            <h1>{title}</h1>
          </div>
          <div className="meta">
            <p>{digger}</p>
            <div className="stats">
              <p>{rabbits}</p> <FontAwesomeIcon icon={faFireFlameCurved} />
              <p>{depth}</p>
              <div className="w">
                <img src={"/logo-full-dark.png"} alt="logo" className="logo" />
              </div>
            </div>
          </div>
        </div>
        <div className="dark-box rabbits">
          <div className="rabbit">
            <p>
              This is an example of a rabbit burned inside of a hole using
              example content that takes up a bunch of space. I could have just
              used the Lorem plugin thing but this will do for now lol.
            </p>
            <div className="r-stats">
              <p>{digger}</p>
              <div className="ww">
                <p>{3}</p>
                <div className="w">
                  <img
                    src={"/logo-full-blue.png"}
                    alt="logo"
                    className="logo"
                  />
                </div>
              </div>
            </div>
            <div className="bar"></div>
          </div>
          <div className="rabbit">
            <p>
              This is an example of a rabbit burned inside of a hole using
              example content that takes up a bunch of space. I could have just
              used the Lorem plugin thing but this will do for now lol.
            </p>
            <div className="r-stats">
              <p>{digger}</p>
              <div className="ww">
                <p>{3}</p>
                <div className="w">
                  <img
                    src={"/logo-full-blue.png"}
                    alt="logo"
                    className="logo"
                  />
                </div>
              </div>
            </div>
            <div className="bar"></div>
          </div>{" "}
          <div className="rabbit">
            <p>
              This is an example of a rabbit burned inside of a hole using
              example content that takes up a bunch of space. I could have just
              used the Lorem plugin thing but this will do for now lol.
            </p>
            <div className="r-stats">
              <p>{digger}</p>
              <div className="ww">
                <p>{3}</p>
                <div className="w">
                  <img
                    src={"/logo-full-blue.png"}
                    alt="logo"
                    className="logo"
                  />
                </div>
              </div>
            </div>
            <div className="bar"></div>
          </div>{" "}
          <div className="rabbit">
            <p>
              This is an example of a rabbit burned inside of a hole using
              example content that takes up a bunch of space. I could have just
              used the Lorem plugin thing but this will do for now lol.
            </p>
            <div className="r-stats">
              <p>{digger}</p>
              <div className="ww">
                <p>{3}</p>
                <div className="w">
                  <img
                    src={"/logo-full-blue.png"}
                    alt="logo"
                    className="logo"
                  />
                </div>
              </div>
            </div>
            <div className="bar"></div>
          </div>
          <div className="sels">
            <FontAwesomeIcon
              icon={faArrowCircleLeft}
              // onClick={() => setIndex(index == 1 ? index : index - 1)}
              className={`bottom left'`}
            />
            <div id="bottom" className="bottom">
              <p>1-10/123</p>
            </div>
            <FontAwesomeIcon
              icon={faArrowCircleRight}
              // onClick={() => setIndex(index == maxIndex ? index : index + 1)}
              className={`bottom right`}
            />
          </div>
        </div>
      </ArchivePageStyled>
      <div>hdifdhfdi</div>
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
  /* margin-right: auto; */

  .sels {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: 1rem;
  }

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

    .sels {
      color: var(--lightGreen);
    }

    .bottom {
      &:hover {
        color: var(--limeGreen);
      }
    }
  }

  .rabbit {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1rem;
  }

  .bar {
    width: 100%;
    margin: 1rem auto;
    border-bottom: 1px dashed var(--limeGreen);
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

    .top {
      display: flex;
      justify-content: left;
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
  }
`;
