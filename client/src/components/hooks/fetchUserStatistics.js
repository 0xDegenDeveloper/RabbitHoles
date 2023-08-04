import sample from "../../assets/sample-data.json";
import fetchGlobalStatistics from "./fetchGlobalStatistics";
import fetchHolesData from "./fetchHoleData";
import { useAccount } from "@starknet-react/core";
import fetchUserArchive from "./fetchUserArchive";

export default function fetchUserStatistics(user) {
  // const { address } = useAccount();
  // if (!address) return { holes: [], rabbits: [] };
  // const holeKeys = Object.keys(sample).filter((key) => parseInt(key) !== 0);
  // const holes = fetchHolesData(
  //   user == "0x1234...5678" || user == address ? holeKeys : []
  // );
  // let rabbits = [];
  // for (let hole in holes) {
  //   for (let rabbit in holes[hole].rabbits) {
  //     rabbits.push(holes[hole].rabbits[rabbit]);
  //   }
  // }
  // return { holes, rabbits };
  /// get user holes, rabbits, depth #
  // const { holes, rabbits, depth } = fetchGlobalStatistics();
  // const userArchive = fetchUserArchive(user);
  // let depth = 0;
  // for (let hole in userArchive.holes) {
  //   totalDepth += userArchive.holes[hole].depth;
  // }
  // return {
  //   holes: userArchive.holes.length,
  //   rabbits: userArchive.rabbits.length,
  //   depth,
  // };
}
