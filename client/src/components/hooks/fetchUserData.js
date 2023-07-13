import sample from "../../assets/sample-data.json";

export default function fetchUserData(holeId) {
  const holeKeys = Object.keys(sample).filter((key) => parseInt(key) !== 0);

  const holes = holeKeys
    .map((key) => {
      const hole = sample[key];
      return {
        id: parseInt(key),
        title: hole.title,
        depth: hole.rabbits.length + 11,
      };
    })
    .sort((a, b) => a.id - b.id);

  const rabbits = holeKeys
    .flatMap((key) => {
      const hole = sample[key];
      return hole.rabbits.map((rabbit, rabbitIndex) => ({
        global_id: rabbit.id,
        msg: rabbit.msg,
        id: rabbitIndex + 1,
        hole_id: parseInt(key),
        title: hole.title,
      }));
    })
    .sort((a, b) => a.global_id - b.global_id);

  return { holes, rabbits };
}
