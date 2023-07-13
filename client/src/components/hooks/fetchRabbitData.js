import sample from "../../assets/sample-data.json";

export default function fetchRabbitData(rabbitId) {
  let rabbit = sample[0].rabbits[0];
  for (const key in sample) {
    if (sample.hasOwnProperty(key)) {
      const rabbits = sample[key].rabbits;

      for (let i = 0; i < rabbits.length; i++) {
        if (parseInt(rabbits[i].id) == parseInt(rabbitId)) {
          rabbit = rabbits[i];
          break;
        }
      }
    }
  }
  return {
    msg: rabbit.msg,
    id: rabbit.id,
    burner: rabbit.burner,
    timestamp: rabbit.timestamp,
  };
}
