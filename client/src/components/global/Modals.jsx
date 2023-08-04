import AccountModal from "../cards/AccountCard";
import BurnModal from "../cards/BurningCard";
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
}) {
  return (
    <>
      {modals.accountModal && (
        <AccountModal
          onClose={setModals.setAccountModal}
          modal={modals.accountModal}
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
        />
      )}
      {modals.rabbitModal && (
        <RabbitModal
          onClose={setModals.setRabbitModal}
          modals={modals}
          useJump={useJump}
          setIsHoles={setIsHoles}
          globalStatistics={globalStatistics}
        />
      )}
      {modals.infoModal && (
        <FlowModal
          modal={modals.infoModal}
          onClose={setModals.setInfoModal}
          mobile={mobile}
        />
      )}
      {modals.burningModal && (
        <BurnModal onClose={setModals.setBurningModal} modals={modals} />
      )}
    </>
  );
}
