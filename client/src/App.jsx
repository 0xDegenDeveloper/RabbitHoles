import { Route, Routes, BrowserRouter, useParams } from "react-router-dom";
import { useState, useEffect, createContext } from "react";

import GlobalStyles from "./components/global/GlobalStyles";
import TopComponents from "./components/global/TopComponents";
import HomePage from "./pages/HomePage";
import StatsPage from "./pages/StatsPage";
import UserPage from "./pages/UserPage";
import InfoPage from "./pages/InfoPage";
import DiggingPage from "./pages/DiggingPage";
import ArchivePage from "./pages/ArchivePage";
import Graphics from "./components/graphics/Graphics";

import AccountModal from "./components/cards/AccountCard";
import HoleModal from "./components/cards/HoleCard";
import RabbitModal from "./components/cards/RabbitCard";
import fetchGlobalStatistics from "./components/hooks/fetchGlobalStatistics";
import fetchGlobalMetrics from "./components/hooks/fetchGlobalMetrics";

export const ModalContext = createContext();

function Modals({
  globalStatistics,
  globalMetrics,
  totalHoles,
  totalBurns,
  useJump,
  setIsHoles,
  accountModal,
  setAccountModal,
  holeModal,
  setHoleModal,
  rabbitModal,
  setRabbitModal,
  hole,
  rabbit,
}) {
  return (
    <>
      {accountModal && (
        <AccountModal onClose={setAccountModal} modal={accountModal} />
      )}
      {holeModal && (
        <HoleModal
          key={hole + rabbit}
          onClose={setHoleModal}
          modal={holeModal}
          hole={hole}
          setIsHoles={setIsHoles}
          useJump={useJump}
          globalStatistics={globalStatistics}
          globalMetrics={globalMetrics}
        />
      )}
      {rabbitModal && (
        <RabbitModal
          key={rabbit + hole}
          onClose={setRabbitModal}
          modal={rabbitModal}
          hole={hole}
          rabbit={rabbit}
          useJump={useJump}
          setIsHoles={setIsHoles}
          globalStatistics={globalStatistics}
          globalMetrics={globalMetrics}
        />
      )}
    </>
  );
}

function App() {
  const [mobile, setMobile] = useState(false);
  const [accountModal, setAccountModal] = useState(false);
  const [infoModalOpen, setInfoModalOpen] = useState(false);
  const [holeModal, setHoleModal] = useState(false);
  const [rabbitModal, setRabbitModal] = useState(false);
  const [hole, setHole] = useState(1);
  const [rabbit, setRabbit] = useState(0);
  const [useJump, setUseJump] = useState(false);
  const [isHoles, setIsHoles] = useState(true);

  const { totalHoles, totalBurns } = {
    totalHoles: 111,
    totalBurns: 555,
  };

  const globalStatistics = fetchGlobalStatistics();
  const globalMetrics = fetchGlobalMetrics();

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
          setAccountModal={setAccountModal}
          accountModal={accountModal}
        />
        <Routes>
          {/* Home Page */}
          <Route path="/" element={<HomePage />}></Route>
          {/* Statistics Page  */}
          <Route
            path="/stats"
            element={
              <StatsPage modal={infoModalOpen} onClose={setInfoModalOpen} />
            }
          ></Route>
          {/* Archive Page */}
          <Route
            path="/archive"
            element={
              <ArchivePage
                mobile={mobile}
                setHoleModal={setHoleModal}
                setRabbitModal={setRabbitModal}
                setHole={setHole}
                setRabbit={setRabbit}
                setUseJump={setUseJump}
              />
            }
          />
          <Route
            path="/archive/:key"
            element={
              <ArchivePage
                mobile={mobile}
                setHoleModal={setHoleModal}
                setRabbitModal={setRabbitModal}
                setHole={setHole}
                setRabbit={setRabbit}
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
                setHoleModal={setHoleModal}
                setRabbitModal={setRabbitModal}
                setHole={setHole}
                setRabbit={setRabbit}
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
                setHoleModal={setHoleModal}
                setRabbitModal={setRabbitModal}
                setHole={setHole}
                setRabbit={setRabbit}
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
              <InfoPage modal={infoModalOpen} onClose={setInfoModalOpen} />
            }
          ></Route>

          <Route path="/digging/" element={<DiggingPage />} />
          <Route path="/digging/:key" element={<DiggingPage />} />
        </Routes>
        <Modals
          globalStatistics={globalStatistics}
          globalMetrics={globalMetrics}
          totalHoles={totalHoles}
          totalBurns={totalBurns}
          useJump={useJump}
          setIsHoles={setIsHoles}
          accountModal={accountModal}
          setAccountModal={setAccountModal}
          holeModal={holeModal}
          setHoleModal={setHoleModal}
          rabbitModal={rabbitModal}
          setRabbitModal={setRabbitModal}
          hole={hole}
          rabbit={rabbit}
        />
      </BrowserRouter>
    </>
  );
}

export default App;
