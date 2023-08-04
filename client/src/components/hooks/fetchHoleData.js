import sample from "../../assets/sample-data.json";
import fetchRabbitsData from "./fetchRabbitData";

export function fetchHoleData(holeId) {
  holeId = sample[holeId] ? parseInt(holeId) : 0;
  const holeData = sample[holeId];
  const rabbitIds = holeData.rabbits.map((rabbit) => rabbit.id);
  const rabbits = fetchRabbitsData(rabbitIds);
  const depth = rabbits.reduce(
    (totalDepth, rabbit) => totalDepth + rabbit.depth,
    0
  );

  return {
    title: holeData.title,
    digs: rabbitIds.length,
    depth,
    digger: holeData.digger,
    timestamp: holeData.timestamp,
    rabbits,
    id: holeId,
  };
}

export default function fetchHolesData(holeIds) {
  /// make into 1 call when contract connection is made

  return holeIds.map((holeId) => fetchHoleData(holeId));
}
