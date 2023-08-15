import AccountModal from "../cards/AccountCard";
import BurnModal from "../cards/BurningCard";
import DiggingCard from "../cards/DiggingCard";
import FlowModal from "../cards/FlowCard";
import HoleModal from "../cards/HoleCard";
import RabbitModal from "../cards/RabbitCard";

export default function Modals({
  globalStatistics,
  useJump,
  setIsHoles,
  modals,
  setModals,
  mobile,
  lookupTitle,
}) {
  return (
    <>
      {modals.accountModal && (
        <AccountModal
          onClose={setModals.setAccountModal}
          modal={modals.accountModal}
          modals={modals}
          setModals={setModals}
        />
      )}
      {modals.holeModal && (
        <HoleModal
          onClose={setModals.setHoleModal}
          modals={modals}
          //   hole={modals.hole}
          setIsHoles={setIsHoles}
          useJump={useJump}
          globalStatistics={globalStatistics}
          setDiggingModal={setModals.setDiggingModal}
        />
      )}
      {modals.rabbitModal && (
        <RabbitModal
          onClose={setModals.setRabbitModal}
          modals={modals}
          useJump={useJump}
          setIsHoles={setIsHoles}
          globalStatistics={globalStatistics}
          setDiggingModal={setModals.setDiggingModal}
        />
      )}
      {modals.infoModal && (
        <FlowModal
          modal={modals.infoModal}
          onClose={setModals.setInfoModal}
          mobile={mobile}
          darkMode={modals.darkMode}
          setDarkMode={setModals.setDarkMode}
        />
      )}
      {modals.burningModal && (
        <BurnModal
          onClose={setModals.setBurningModal}
          modals={modals}
          setModals={setModals}
        />
      )}
      {modals.diggingModal && (
        <DiggingCard
          onClose={setModals.setDiggingModal}
          modals={modals}
          setModals={setModals}
          lookupTitle={lookupTitle}
        />
      )}
    </>
  );
}
