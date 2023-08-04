import sample from "../../assets/sample-data.json";
import fetchHolesData from "./fetchHoleData";
import { useAccount } from "@starknet-react/core";
import fetchUserStatistics from "./fetchUserStatistics";

export default function fetchUserArchive(user) {
  //   if (!user)
  //     return {
  //       holes: [],
  //       rabbits: [],
  //       totalHoles: 0,
  //       totalRabbits: 0,
  //       totalDepth: 0,
  //     };

  /// use this when using contract calls
  //   const globalStats = fetchUserStatistics(user);

  const holeKeys = Object.keys(sample).filter((key) => parseInt(key) !== 0);
  const holes = fetchHolesData(holeKeys);

  let rabbits = [];
  let totalHoles = 0;
  let totalRabbits = 0;
  let totalDepth = 0;
  for (let hole in holes) {
    totalHoles += 1;
    for (let rabbit in holes[hole].rabbits) {
      totalRabbits += 1;
      totalDepth += holes[hole].rabbits[rabbit].depth;
      rabbits.push(holes[hole].rabbits[rabbit]);
    }
  }

  /// replace with contract call

  return {
    holes,
    rabbits,
    totalHoles,
    totalRabbits,
    totalDepth,
  };
}
