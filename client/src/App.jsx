import { Route, Routes, BrowserRouter, useParams } from "react-router-dom";
import { useState, useEffect } from "react";

import GlobalStyles from "./components/global/GlobalStyles";
import TopComponents from "./components/global/TopComponents";
import HomePage from "./pages/HomePage";
import StatsPage from "./pages/StatsPage";
import UserPage from "./pages/UserPage";
import InfoPage from "./pages/InfoPage";
import DigHolePage from "./pages/DigHolePage";
import BurnRabbitPage from "./pages/BurnRabbitPage";
import ArchivePage from "./pages/ArchivePage";
import Graphics from "./components/graphics/Graphics";
// import MiddleMan from "./pages/MiddleMan";
import DiggingPage from "./pages/DiggingPage";
import ArchivePageNew from "./pages/ArchivePageNew";

import AccountModal from "./components/global/AccountModal";

function App() {
  const [mobile, setMobile] = useState(false);

  const [accountModal, setAccountModal] = useState(false);

  const [infoModalOpen, setInfoModalOpen] = useState(false);
  const totalDigs = 1111;

  useEffect(() => {
    const faviconPath = `/logo-main.png`;
    const faviconLink = document.querySelector("#favicon-link"); // Use the id attribute
    faviconLink.setAttribute("href", faviconPath);

    const handleResize = () => {
      const isMobile = window.innerWidth < 760;
      setMobile(isMobile);
    };
    window.addEventListener("resize", handleResize);

    handleResize();
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
          totalDigs={totalDigs}
          mobile={mobile}
          setAccountModal={setAccountModal}
          accountModal={accountModal}
        />
        <Routes>
          {/* Middle route for fetching then passing to final destination */}
          <Route path="/digging/" element={<DiggingPage />} />
          <Route path="/digging/:key" element={<DiggingPage />} />
          {/* Main routes */}
          <Route path="/" element={<HomePage />}></Route>
          <Route
            path="/stats"
            element={
              <StatsPage modal={infoModalOpen} onClose={setInfoModalOpen} />
            }
          ></Route>
          <Route
            path="/info"
            element={
              <InfoPage modal={infoModalOpen} onClose={setInfoModalOpen} />
            }
          ></Route>
          <Route path="/user" element={<UserPage mobile={mobile} />} />
          <Route
            path="/archive"
            element={<ArchivePageNew mobile={mobile} holeId={2} />}
          />
          <Route path="/dig-hole" element={<DigHolePage mobile={mobile} />} />
          <Route
            path="/burn-rabbit"
            element={<BurnRabbitPage mobile={mobile} />}
          />
          {/* Param routes */}
          <Route
            path="/archive/:key"
            element={<ArchivePageNew mobile={mobile} />}
          />
          {/* <Route
            path="/archive/:key/:key2"
            element={<ArchivePageNew mobile={mobile} />}
          /> */}
          <Route
            path="/dig-hole/:key"
            element={<DigHolePage mobile={mobile} />}
          />
          <Route
            path="/burn-rabbit/:key"
            element={<BurnRabbitPage mobile={mobile} />}
          />
          <Route path="/user/:key" element={<UserPage mobile={mobile} />} />
          <Route
            path="/user/:key/:key2"
            element={<UserPage mobile={mobile} />}
          />
          <Route path="/new/" element={<ArchivePageNew />} />
        </Routes>
        {accountModal && (
          <AccountModal onClose={setAccountModal} modal={accountModal} />
        )}
      </BrowserRouter>
    </>
  );
}

export default App;
