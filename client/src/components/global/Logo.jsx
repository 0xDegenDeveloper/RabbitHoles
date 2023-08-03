import styled from "styled-components";
import { Link, useLocation } from "react-router-dom";
import { useState, useEffect } from "react";

export default function Logo(props) {
  const [toggled, setToggled] = useState(false);

  useEffect(() => {
    let timer;
    if (toggled) {
      timer = setTimeout(() => {
        setToggled(false);
      }, 4000);
    }
    return () => clearTimeout(timer);
  }, [toggled]);

  return (
    <>
      <LogoStyle
        darkMode={props.darkMode}
        toggled={toggled}
        onClick={() => {
          props.setDarkMode(!props.darkMode);
          setToggled(!toggled);
        }}
        // onMouseEnter={startSpinner} // start the spinner after 5 seconds
        onMouseLeave={() => {
          setToggled(false);
        }} // stop the spinner
        // className={`${toggled ? "toggled" : ""}`}
      >
        <Link
          // to={location.pathname == "/" ? "/info" : "/"}
          to={"/"}
          className={props.mobile ? "mobile" : "non-mobile"}
        >
          <img
            src={
              props.darkMode
                ? toggled
                  ? "/logo-full-light.png"
                  : "/logo-light.png"
                : toggled
                ? "/logo-full-dark.png"
                : "/logo-dark.png"
            }
            alt="logo"
            className="logo"
          />
        </Link>
      </LogoStyle>
    </>
  );
}

const LogoStyle = styled.div`
  position: absolute;
  z-index: 1000;
  overflow: hidden;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  -moz-backdrop-filter: blur(10px);
  -o-backdrop-filter: blur(10px);
  -ms-backdrop-filter: blur(10px);
  border-radius: 0 0 50% 0;
  border: 2px solid;
  border-color: rgba(0, 0, 0, 0);
  background-color: ${(props) =>
    props.darkMode ? "var(--forrestGreen)" : "none"};

  text-decoration: none;
  font-weight: bold;
  align-items: center;
  font-size: clamp(20px, 6vw, 40px);
  margin-left: auto;
  padding: 0;
  font-weight: 700;
  box-shadow: 0px 0px 5px 0px var(--forrestGreen);
  justify-self: center;
  aspect-ratio: 1/1;

  width: clamp(90px, 8vw, 250px);
  height: clamp(90px, 8vw, 250px);
  img {
    width: clamp(90px, 8vw, 250px);
    height: clamp(90px, 8vw, 250px);
  }

  a {
    text-decoration: none;
    color: ${(props) =>
      props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
  }

  top: -2px;
  left: -2px;

  top: ${(props) => (props.toggled ? "1rem" : "-2px")};
  left: ${(props) => (props.toggled ? "1rem" : "-2px")};
  border-radius: ${(props) => (props.toggled ? "50%" : "0 0 50% 0")};

  // Add transition property for smooth hover effect
  transition: all 0.05s 0s ease-in-out;

  /* .toggled {
    animation: rotate360 1.5s ease-in-out;
  } */

  /* @keyframes rotate360 {
    0% {
      transform: rotate(0deg);
    }
    50%,
    52% {
      transform: rotate(720deg);
    }

    75%,
    100% {
      transform: rotate(0deg);
    }
  } */

  ${(props) =>
    props.toggled &&
    `
    animation: infinite rotate360 3s ease-in-out;
    animation-delay: 1s;
  `}

  @keyframes rotate360 {
    0% {
      transform: rotate(0deg);
    }
    50%,
    52% {
      transform: rotate(720deg);
    }

    75%,
    100% {
      transform: rotate(0deg);
    }
  }
`;
