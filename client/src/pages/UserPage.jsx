import React, { useState } from "react";
import styled from "styled-components";
import { useNavigate, useParams } from "react-router-dom";
import UserSearchBar from "../components/UserSearchBar";
import fetchUserData from "../components/hooks/fetchUserData";

export default function UserPage(props) {
  const { key } = useParams();

  const [isHoles, setIsHoles] = useState(true);

  const user = key ? key : "0x1234...abcd";

  const navigate = useNavigate();
  const userData = fetchUserData(user);

  return (
    <>
      <div className="container">
        <Wrapper isHoles={isHoles}>
          <UserSearchBar user={user} />
          {/* DEMO USER H OR R */}
          {isHoles && !key && (
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
          )}
          {!isHoles && !key && (
            <div className="user-holes-section">
              <div className="clear-box-dark-border user-holes" id="clear-box">
                {userData.rabbits.map((rabbit, index) => (
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
          )}
          {/* NO USER */}
          {key && (
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
          )}
          <div className="wrapper3">
            <h1
              onClick={() => {
                setIsHoles(true);
              }}
              className={`a sel ${isHoles ? "active" : ""}`}
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
          </div>
          <div className="wrapper2">
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
                      parseInt(userData.rabbits.length)}{" "}
                  RBIT
                </em>
              </h4>
            </div>
          </div>
        </Wrapper>
      </div>
    </>
  );
}

const Bar = styled.div`
  width: 100%;
  margin: 1rem auto;
  border-bottom: 1px solid var(--forrestGreen);
`;

const Wrapper = styled.div`
  display: grid;
  grid-template-columns: auto;
  gap: 1rem;
  color: var(--forrestGreen);
  place-items: center;
  place-content: center;
  user-select: none;
  width: clamp(200px, 60%, 400px);

  .wrapper2 {
    display: grid;
    grid-template-columns: auto auto auto;
    gap: 1rem;

    &:hover {
      cursor: default;
    }
  }

  .sel {
    color: var(--forrestGreen);

    h1 {
      margin: 0;
    }
  }

  .active {
    color: var(--lightGreen);
  }

  .activeR {
    color: var(--limeGreen);
  }

  .activeH {
    color: var(--lightGreen);
  }

  .wrapper3 {
    display: grid;
    grid-template-columns: auto auto auto;
    gap: 0.5rem;
    font-size: clamp(9px, 3vw, 14px);
    height: fit-content;

    .a {
      margin-left: auto;
    }
    .b {
      margin-right: auto;
    }

    h1:hover {
      cursor: pointer;
    }

    h1 {
      margin: 0.5rem;
    }
  }

  @media only screen and (max-width: 760px) {
    .wrapper2 {
      grid-template-columns: auto auto;
    }

    .tt {
      margin: 0 auto;
      grid-column: 1/-1;
    }
  }

  h4 {
    margin: 0;
    /* padding: 0; */
    padding-bottom: 0.5rem;
  }

  .stat {
    padding: 0.75rem;
    font-size: clamp(9px, 3vw, 14px);
    border: none;
    box-shadow: 0px 0px 5px 0px var(--forrestGreen);
    color: var(--lightGreen);

    h4 {
      padding: 0;
    }
  }

  h2 {
    color: var(--limeGreen);
  }

  .hole-link {
    padding: 1rem;
    &:hover {
      cursor: pointer;
      color: var(--lightGreen);
      background-color: var(--forrestGreen);

      border-radius: 1rem;
      em {
        color: var(--limeGreen);
      }
    }
  }

  #clear-box {
    width: clamp(200px, 40vw, 600px);
  }

  .user-holes {
    max-height: 200px;
    overflow-y: scroll;
    display: grid;
    grid-template-columns: auto;
    gap: 0rem;
    margin: 0 auto;
    width: fit-content;
    margin-top: 1rem;

    color: var(--forrestGreen);
    em {
      color: var(--lightGreen);
    }
  }
`;

const VBar = styled.div`
  width: 0;
  height: 50%;
  margin: auto auto;
  border-left: 2px solid var(--forrestGreen);
`;
