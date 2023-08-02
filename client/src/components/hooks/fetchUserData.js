import sample from "../../assets/sample-data.json";
import fetchHolesData from "./fetchHoleData";
import { useAccount } from "@starknet-react/core";

export default function fetchUserData(user) {
  const { address } = useAccount();
  const holeKeys = Object.keys(sample).filter((key) => parseInt(key) !== 0);
  const holes = fetchHolesData(
    user == "0x1234...5678" || user == address ? holeKeys : []
  );

  let rabbits = [];
  for (let hole in holes) {
    for (let rabbit in holes[hole].rabbits) {
      rabbits.push(holes[hole].rabbits[rabbit]);
    }
  }

  // holeKeys;
  //   .flatMap((key) => {
  //     const hole = sample[key];
  //     return hole.rabbits.map((rabbit, rabbitIndex) => ({
  //       global_id: rabbit.id,
  //       msg: rabbit.msg,
  //       id: rabbitIndex + 1,
  //       hole_id: parseInt(key),
  //       title: hole.title,
  //     }));
  //   })
  //   .sort((a, b) => a.global_id - b.global_id);

  return { holes, rabbits };
}
