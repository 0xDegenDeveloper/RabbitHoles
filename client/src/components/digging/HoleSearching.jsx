import { faRotateBack } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { StyledBox } from "../../pages/DiggingPage";
import { useNavigate } from "react-router-dom";

export default function HoleSearching() {
  const navigate = useNavigate();
  return (
    <StyledBox className="dark-box-600w">
      <h2>Verifying...</h2>
      <h4>A hole can be dug only once</h4>
      <div className="btn-container top-right">
        <FontAwesomeIcon
          icon={faRotateBack}
          onClick={() => {
            navigate(`/`);
          }}
        ></FontAwesomeIcon>
      </div>
    </StyledBox>
  );
}
