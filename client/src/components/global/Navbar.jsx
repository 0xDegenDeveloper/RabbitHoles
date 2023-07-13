import { Link, useMatch, useResolvedPath, useLocation } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEarthAmerica,
  faCircleInfo,
  faChartSimple,
  faSearch,
} from "@fortawesome/free-solid-svg-icons";
import { faCircleUser } from "@fortawesome/free-regular-svg-icons";
import styled from "styled-components";

export default function Navbar(props) {
  const location = useLocation();

  const handleArchiveClick = () => {
    if (!location.pathname.startsWith("/archive")) {
      return `/archive/`;
    }
  };

  const handleUserClick = () => {
    if (!location.pathname.startsWith("/user")) {
      return `/user/`;
    }
  };

  return (
    <>
      <Nav>
        <NavLinks>
          <NavLink to="/" icon={faSearch}></NavLink>
          <NavLink to="/stats" icon={faChartSimple}></NavLink>
          <NavLink to={handleArchiveClick()} icon={faEarthAmerica}></NavLink>
          <NavLink icon={faCircleUser} to={handleUserClick()}></NavLink>
          <NavLink to="/info" icon={faCircleInfo}></NavLink>
        </NavLinks>
      </Nav>
    </>
  );
}

function NavLink({ to, children, icon }) {
  const resolvedPath = useResolvedPath(to);
  const isActive = useMatch({ path: resolvedPath.pathname, end: true });

  return (
    <NavLinksLi className={isActive ? "active" : ""}>
      <NavLinkEl className={isActive ? "active" : ""} to={to}>
        <FontAwesomeIcon icon={icon} />
      </NavLinkEl>
    </NavLinksLi>
  );
}

const Nav = styled.nav`
  position: absolute;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  align-items: left;
  font-size: clamp(7px, 3vw, 17px);
  position: fixed;
  left: 0;
  bottom: 0;
  border-radius: 1rem;
`;

const NavLinks = styled.ul`
  margin-top: auto;
  margin-bottom: 1rem;
  margin-left: 1rem;
  display: flex;
  bottom: 0;
  left: 0;
  flex-direction: column;
  padding: 0;
  list-style: none;
  font-size: clamp(15px, 5vw, 25px);

  @media only screen and (max-width: 760px) {
    margin-left: 0.5rem;
    margin-bottom: 0.5rem;
  }
`;

const NavLinksLi = styled.li`
  padding: 1rem;

  &.active,
  &.active:hover {
    color: var(--greyGreen);
    border-left: 2px solid var(--limeGreen);
    padding-left: 1.5rem;
  }

  @media only screen and (max-width: 760px) {
    padding: 0.5rem;
  }
`;

const NavLinkEl = styled(Link)`
  text-decoration: none;
  color: var(--forrestGreen);
  &:hover {
    color: var(--greyGreen);
  }
  &.active {
    color: var(--greyGreen);
  }
`;
