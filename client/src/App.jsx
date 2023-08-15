import {
  Route,
  Routes,
  BrowserRouter,
  useParams,
  useLocation,
} from "react-router-dom";
import { useState, useEffect, createContext } from "react";

import GlobalStyles from "./components/global/GlobalStyles";
import TopComponents from "./components/global/TopComponents";
import HomePage from "./pages/HomePage";
import DiggingPage from "./pages/DiggingPage";
import StatsPage from "./pages/StatsPage";
import UserPage from "./pages/UserPage";
import InfoPage from "./pages/InfoPage";
import ArchivePage from "./pages/ArchivePage";
import Graphics from "./components/graphics/Graphics";
import Modals from "./components/global/Modals";

import fetchGlobalStatistics from "./components/hooks/fetchGlobalStatistics";
import fetchGlobalArchive from "./components/hooks/fetchGlobalArchive";
import fetchUserArchive from "./components/hooks/fetchUserArchive";
import { useAccount } from "@starknet-react/core";

function App() {
  const { address } = useAccount();
  const [mobile, setMobile] = useState(false);
  const [modals, setModals] = useState({
    diggingModal: false,
    accountModal: false,
    infoModal: false,
    holeModal: false,
    rabbitModal: false,
    burningModal: false,
    darkMode: false,
    hole: null,
    rabbit: null,
  });
  const [lookupTitle, setLookupTitle] = useState("");
  const [useJump, setUseJump] = useState(false);

  const [opt, setOpt] = useState("depth");

  const globalStatistics = fetchGlobalStatistics();

  const archive = fetchGlobalArchive(
    globalStatistics.holes > 111 ? 111 : globalStatistics.holes
  );

  const userArchive = fetchUserArchive(address);

  const modalSetters = {
    setDiggingModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, diggingModal: value }));
    },
    setAccountModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, accountModal: value }));
    },
    setInfoModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, infoModal: value }));
    },
    setHoleModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, holeModal: value }));
    },
    setRabbitModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, rabbitModal: value }));
    },
    setBurningModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, burningModal: value }));
    },
    setDarkMode: (value) => {
      setModals((prevModals) => ({ ...prevModals, darkMode: value }));
    },
    setHole: (value) => {
      setModals((prevModals) => ({ ...prevModals, hole: value }));
    },
    setRabbit: (value) => {
      setModals((prevModals) => ({ ...prevModals, rabbit: value }));
    },
  };

  useEffect(() => {
    document
      .querySelector("#favicon-link")
      .setAttribute("href", `/logo-main.png`);

    const handleResize = () => {
      setMobile(window.innerWidth < 760);
    };
    handleResize();

    window.addEventListener("resize", handleResize);
    return () => {
      window.removeEventListener("resize", handleResize);
    };
  }, []);

  // mobile uses bg no shift always.

  // const location = useLocation();

  return (
    <>
      <BrowserRouter>
        <AppInner
          props={{
            mobile,
            modals,
            modalSetters,
            globalStatistics,
            archive,
            userArchive,
            useJump,
            setUseJump,
            opt,
            setOpt,
            lookupTitle,
            setLookupTitle,
          }}
        />
      </BrowserRouter>
    </>
  );
}

function AppInner(props) {
  const {
    mobile,
    modals,
    modalSetters,
    globalStatistics,
    archive,
    userArchive,
    useJump,
    setUseJump,
    opt,
    setOpt,
    lookupTitle,
    setLookupTitle,
  } = props.props;

  const location = useLocation();

  return (
    <>
      <GlobalStyles mobile={mobile} modals={modals} path={location.pathname} />

      <TopComponents
        mobile={mobile}
        setAccountModal={modalSetters.setAccountModal}
        accountModal={modals.accountModal}
        setDarkMode={modalSetters.setDarkMode}
        darkMode={modals.darkMode}
      />
      <Routes>
        {/* Home Page */}
        <Route
          path="/"
          element={
            <HomePage
              modals={modals}
              setModals={modalSetters}
              setLookupTitle={setLookupTitle}
              lookupTitle={lookupTitle}
            />
          }
        ></Route>
        {/* Statistics Page  */}
        <Route
          path="/stats"
          element={
            <StatsPage
              modal={modals.infoModal}
              setModals={modalSetters}
              // onClose={modalSetters.setInfoModal}
              globalStatistics={globalStatistics}
            />
          }
        ></Route>
        {/* Archive Page */}
        <Route
          path="/archive"
          element={
            <ArchivePage
              mobile={mobile}
              modals={modals}
              setModals={modalSetters}
              globalStatistics={globalStatistics}
              holes={archive}
              setUseJump={setUseJump}
            />
          }
        />
        <Route
          path="/archive/:key"
          element={
            <ArchivePage
              mobile={mobile}
              modals={modals}
              setModals={modalSetters}
              globalStatistics={globalStatistics}
              holes={archive}
              setUseJump={setUseJump}
            />
          }
        />
        {/* User Page */}
        <Route
          path="/user"
          element={
            <UserPage
              mobile={mobile}
              setModals={modalSetters}
              userArchive={userArchive}
              setUseJump={setUseJump}
              opt={opt}
              setOpt={setOpt}
            />
          }
        />
        <Route
          path="/user/:key"
          element={
            <UserPage
              mobile={mobile}
              setModals={modalSetters}
              userArchive={userArchive}
              setUseJump={setUseJump}
              opt={opt}
              setOpt={setOpt}
            />
          }
        />
        {/* Info Page */}
        <Route
          path="/info"
          element={
            <InfoPage
              modal={modals.infoModal}
              onClose={modalSetters.setInfoModal}
              setDarkMode={modalSetters.setDarkMode}
              darkMode={modals.darkMode}
            />
          }
        ></Route>

        <Route
          path="/digging/"
          element={<DiggingPage setModals={modalSetters} />}
        />
        <Route
          path="/digging/:key"
          element={<DiggingPage setModals={modalSetters} />}
        />
      </Routes>
      <Modals
        globalStatistics={globalStatistics}
        useJump={useJump}
        modals={modals}
        setModals={modalSetters}
        mobile={mobile}
        lookupTitle={lookupTitle}
      />
      <Graphics path={location.pathname} />
    </>
  );
}

export default App;
