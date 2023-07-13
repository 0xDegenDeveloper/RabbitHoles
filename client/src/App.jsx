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

function App() {
  const [mobile, setMobile] = useState(false);
  const totalDigs = 1111;

  useEffect(() => {
    const faviconPath = `/logo.png`;
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
        <TopComponents totalDigs={totalDigs} mobile={mobile} />
        <Routes>
          {/* Main routes */}
          <Route path="/" element={<HomePage />}></Route>
          <Route path="/stats" element={<StatsPage />}></Route>
          <Route path="/info" element={<InfoPage />}></Route>
          <Route path="/user" element={<UserPage mobile={mobile} />} />
          <Route path="/archive" element={<ArchivePage mobile={mobile} />} />
          <Route path="/dig-hole" element={<DigHolePage mobile={mobile} />} />
          <Route
            path="/burn-rabbit"
            element={<BurnRabbitPage mobile={mobile} />}
          />
          {/* Param routes */}
          <Route
            path="/archive/:key"
            element={<ArchivePage mobile={mobile} />}
          />
          <Route
            path="/archive/:key/:key2"
            element={<ArchivePage mobile={mobile} />}
          />
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
        </Routes>
      </BrowserRouter>
    </>
  );
}

export default App;
