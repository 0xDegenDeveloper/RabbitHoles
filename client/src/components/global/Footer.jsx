import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowUpRightFromSquare,
  faChevronDown,
} from "@fortawesome/free-solid-svg-icons";
import React, { useState } from "react";
import { faGithub, faTwitter } from "@fortawesome/free-brands-svg-icons";
import styled from "styled-components";

export default function Footer(props) {
  const [isFooterOpen, setIsFooterOpen] = useState(false);

  return (
    <>
      <FooterWrapper
        onMouseEnter={() => setIsFooterOpen(true)}
        onMouseLeave={() => setIsFooterOpen(false)}
        darkMode={props.darkMode}
      >
        <FooterTop
          darkMode={props.darkMode}
          onClick={() => props.setDarkMode(!props.darkMode)}
        >
          <Link onClick={() => setIsFooterOpen(!isFooterOpen)}>
            Powered By Novemberfork
          </Link>
          <FontAwesomeIcon
            icon={faChevronDown}
            style={{ paddingLeft: "0.5rem" }}
            onClick={() => setIsFooterOpen(!isFooterOpen)}
          ></FontAwesomeIcon>
        </FooterTop>
        {isFooterOpen && (
          <FooterBottom darkMode={props.darkMode}>
            <Link to="https://twitter.com/degendeveloper" target="_blank">
              <FontAwesomeIcon
                icon={faTwitter}
                className="footers"
              ></FontAwesomeIcon>
            </Link>
            <Link to="https://github.com/0xDegenDeveloper" target="_blank">
              <FontAwesomeIcon icon={faGithub}></FontAwesomeIcon>
            </Link>
            <Link to="https://novemberfork.io" target="_blank">
              <FontAwesomeIcon
                icon={faArrowUpRightFromSquare}
              ></FontAwesomeIcon>
            </Link>
          </FooterBottom>
        )}
      </FooterWrapper>
    </>
  );
}

const FooterWrapper = styled.div`
  position: fixed;
  margin-top: auto;
  bottom: -0.1rem;
  right: 0.3rem;
  z-index: 1000;
  padding: 0.5rem 0.8rem 0.5rem 1rem;
  font-family: "Cairo";
  letter-spacing: 0.5px;
  border-color: rgba(0, 0, 0, 0);
  border-style: solid;
  /* color: var(--forrestGreen); */
  color: ${(props) =>
    props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
  border-radius: 1rem 1rem 0 0;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  -moz-backdrop-filter: blur(10px);
  -o-backdrop-filter: blur(10px);
  -ms-backdrop-filter: blur(10px);
  box-shadow: 0px 0px 5px 0px var(--forrestGreen);
  font-size: clamp(8px, 3vw, 20px);
  /* background-color: rgba(255, 255, 255, 0.01); */
  background-color: ${(props) =>
    props.darkMode ? "var(--forrestGreen)" : "none"};
  backdrop-filter: blur(2px);
  -webkit-backdrop-filter: blur(2px);
  -moz-backdrop-filter: blur(2px);
  -o-backdrop-filter: blur(2px);
  -ms-backdrop-filter: blur(2px);
  /* box-shadow: 0px 0px 25px 0px rgba(0, 0, 0, 0.3); */
  overflow: hidden;

  &:hover {
    /* background-color: var(--lightGreen); */
  }

  /* writing-mode: vertical-rl; */
  /* transform: rotate(180deg); */

  a {
    /* color: var(--forrestGreen); */
    color: ${(props) =>
      props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
    text-decoration: none;

    font-family: "Lato";

    /* padding: 1rem; */
  }

  a:hover {
    font-style: italic;
  }
`;

const FooterTop = styled.div`
  /* color: var(--forrestGreen); */
  color: ${(props) =>
    props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};

  svg {
    cursor: pointer;
  }
`;

const FooterBottom = styled.div`
  display: flex;
  justify-content: space-evenly;
  color: ${(props) =>
    props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
  margin-top: 1rem;

  a {
    padding: 0;
    font-size: clamp(13px, 4vw, 20px);
  }

  svg {
    color: ${(props) =>
      props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
  }

  svg:hover {
    cursor: pointer;
    color: ${(props) =>
      props.darkMode ? "var(--limeGreen)" : "var(--limeGreen)"};
  }
`;
