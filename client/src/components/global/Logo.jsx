import styled from "styled-components";
import { Link } from "react-router-dom";
import { useState, useEffect } from "react";

export default function Logo(props) {
  const [toggled, setToggled] = useState(false);
  const [isHovered, setIsHovered] = useState(false);

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  // darkMode -> toggled

  useEffect(() => {}, [props.darkMode]);

  return (
    <>
      {/* <Wrapper> */}
      <LogoStyle
        darkMode={props.darkMode}
        onClick={() => {
          props.setDarkMode(!props.darkMode);
        }}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        // ./src/assets/
      >
        <Link to={"/"} className={props.mobile ? "mobile" : "non-mobile"}>
          {/* {props.mobile ? "RBITS" : "RabbitHoles"} */}
          <img
            src={
              props.darkMode
                ? isHovered
                  ? "/logo-full-light.png"
                  : "/logo-light.png"
                : isHovered
                ? "/logo-full-dark.png"
                : "/logo-dark.png"
            }
            alt="logo"
            className="logo"
          />
        </Link>
      </LogoStyle>

      {/* </Wrapper> */}
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
  top: -2px;
  left: -2px;
  text-decoration: none;
  font-weight: bold;
  align-items: center;
  font-size: clamp(20px, 6vw, 40px);
  margin-left: auto;
  /* padding: 0.5rem 1rem;  */
  padding: 0;
  font-weight: 700;
  box-shadow: 0px 0px 5px 0px var(--forrestGreen);
  /* border-top: none;
  border-right: none; */
  aspect-ratio: 1/1;
  img {
    width: clamp(60px, 8vw, 300px);
    height: clamp(60px, 8vw, 300px);
  }

  a {
    text-decoration: none;
    color: ${(props) =>
      props.darkMode ? "var(--greyGreen)" : "var(--forrestGreen)"};
  }

  &:hover {
    /* border-top: 2px solid;
    border-right: 2px solid; */

    border-radius: 50%;
    /* border: ${(props) =>
      props.darkMode
        ? "5px solid var(--greyGreen)"
        : "5px solid var(--forrestGreen)"}; */
    top: 1rem;
    left: 1rem;
  }

  // Add transition property for smooth hover effect
  transition: all 0.05s 0s ease-in-out;
`;

// const LogoStyle = styled.div`
//   position: absolute;
//   z-index: 1000;
//   overflow: hidden;
//   backdrop-filter: blur(10px);
//   -webkit-backdrop-filter: blur(10px);
//   -moz-backdrop-filter: blur(10px);
//   -o-backdrop-filter: blur(10px);
//   -ms-backdrop-filter: blur(10px);
//   border-radius: 2rem;
//   border-top-right-radius: 0;
//   border-bottom-right-radius: 0;
//   border-top-left-radius: 0;
//   border: 2px solid;
//   border-color: none;
//   color: var(--forrestGreen);
//   top: 0;
//   right: 0;
//   text-decoration: none;
//   font-weight: bold;
//   align-items: center;
//   font-size: clamp(20px, 6vw, 40px);
//   margin-left: auto;
//   padding: 0.5rem 1rem;
//   font-weight: 700;
//   box-shadow: 0px 0px 5px 0px var(--forrestGreen);
//   border-top: none;
//   border-right: none;

//   a {
//     text-decoration: none;
//     color: var(--forrestGreen);
//   }

//   :hover {
//     border-bottom-left-radius: 2rem;
//     border-top-left-radius: 2rem;
//     border-bottom-right-radius: 2rem;
//     border-top-right-radius: 2rem;
//     margin-top: 1rem;
//     margin-right: 1rem;
//     border-top: 2px solid;
//     border-right: 2px solid;
//   }
// `;
