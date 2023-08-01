import sample from "../../assets/sample-data.json";
import { stringToFelts } from "../utils/Utils";

export function fetchRabbitData(rabbitId) {
  let rabbit;
  let holeId;

  for (const key in sample) {
    const foundRabbit = sample[key].rabbits.find(
      ({ id }) => parseInt(id) === parseInt(rabbitId)
    );
    if (foundRabbit) {
      rabbit = foundRabbit;
      holeId = key;
      break;
    }
  }

  rabbit = rabbit || sample[0].rabbits[0];

  const depth = stringToFelts(rabbit.msg).length;

  return {
    msg: rabbit.msg,
    id: rabbit.id,
    burner: rabbit.burner,
    timestamp: rabbit.timestamp,
    depth,
    holeId,
  };
}

export default function fetchRabbitsData(rabbitIds) {
  // console.log("fetching rabbit array");
  return rabbitIds.map((rabbitId) => {
    // console.log(rabbitId);
    return fetchRabbitData(rabbitId);
  });
}
