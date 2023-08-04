import { Route, Routes, BrowserRouter, useParams } from "react-router-dom";
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
    accountModal: false,
    infoModal: false,
    holeModal: false,
    rabbitModal: false,
    burningModal: false,
    infoModal: false,
    hole: null,
    rabbit: null,
  });

  const [useJump, setUseJump] = useState(false);
  const [isHoles, setIsHoles] = useState(true);

  const globalStatistics = fetchGlobalStatistics();

  const archive = fetchGlobalArchive(
    globalStatistics.holes > 111 ? 111 : globalStatistics.holes
  );

  const userArchive = fetchUserArchive(address);

  const modalSetters = {
    setAccountModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, accountModal: value }));
    },
    setInfoModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, infoModalOpen: value }));
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
    setInfoModal: (value) => {
      setModals((prevModals) => ({ ...prevModals, infoModal: value }));
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

  return (
    <>
      <Graphics />
      <GlobalStyles mobile={mobile} />
      <BrowserRouter>
        <TopComponents
          mobile={mobile}
          setAccountModal={modalSetters.setAccountModal}
          accountModal={modals.accountModal}
        />
        <Routes>
          {/* Home Page */}
          <Route path="/" element={<HomePage />}></Route>
          {/* Statistics Page  */}
          <Route
            path="/stats"
            element={
              <StatsPage
                modal={modals.infoModal}
                onClose={modalSetters.setInfoModal}
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
                isHoles={isHoles}
                setIsHoles={setIsHoles}
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
                isHoles={isHoles}
                setIsHoles={setIsHoles}
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
          setIsHoles={setIsHoles}
          modals={modals}
          setModals={modalSetters}
        />
      </BrowserRouter>
    </>
  );
}

export default App;
