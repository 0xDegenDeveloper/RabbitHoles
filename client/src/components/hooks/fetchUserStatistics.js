import sample from "../../assets/sample-data.json";
import fetchGlobalStatistics from "./fetchGlobalStatistics";
import fetchHolesData from "./fetchHoleData";
import { useAccount } from "@starknet-react/core";

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

  return { holes: 0, rabbits: 0, depth: 0 };
}
