import sample from "../../assets/sample-data.json";
import fetchGlobalStatistics from "./fetchGlobalStatistics";
import fetchHolesData from "./fetchHoleData";
import { useAccount } from "@starknet-react/core";
import fetchUserStatistics from "./fetchUserStatistics";

export default function fetchUserArchive(user) {
  if (!user)
    return {
      holes: [],
      rabbits: [],
      totalHoles: 0,
      totalRabbits: 0,
      totalDepth: 0,
    };
  const globalStats = fetchUserStatistics(user);

  const holeKeys = Object.keys(sample).filter((key) => parseInt(key) !== 0);
  const holes = fetchHolesData(holeKeys);

  let rabbits = [];
  for (let hole in holes) {
    for (let rabbit in holes[hole].rabbits) {
      rabbits.push(holes[hole].rabbits[rabbit]);
    }
  }

  /// replace with contract call

  return {
    holes,
    rabbits,
    totalHoles: globalStats.holes,
    totalRabbits: globalStats.rabbits,
    totalDepth: globalStats.depth,
  };
}
